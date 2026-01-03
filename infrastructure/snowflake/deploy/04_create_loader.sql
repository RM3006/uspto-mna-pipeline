/* ---------------------------------------------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Create Procedure and Task to load xml data from Stage to raw Table.
   ---------------------------------------------------------------------------------------------------------------------
*/

USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- Create a file format to split large XML files into manageable text chunks
CREATE OR REPLACE FILE FORMAT uspto_xml_splitter_fmt
TYPE = 'CSV'
COMPRESSION = GZIP
FIELD_DELIMITER = NONE
RECORD_DELIMITER = '</patent-assignment>' -- split the file at the closing XML tag
SKIP_HEADER = 0
TRIM_SPACE = FALSE;

-- Create Stored Procedure to load chunks, clean data, and parse into XML
CREATE OR REPLACE PROCEDURE load_patent_xml_proc()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    -- 1. Create a temporary table to hold raw text chunks before parsing
    CREATE OR REPLACE TEMPORARY TABLE raw_xml_chunks_temp (
        raw_chunk VARCHAR,
        file_name VARCHAR
    );

    -- 2. Load data from stage into temp table and capture source filenames
    INSERT INTO raw_xml_chunks_temp (raw_chunk, file_name)
        SELECT 
            $1,                 -- The raw text chunk
            metadata$filename   -- The dynamic filename from S3
        FROM @uspto_raw_stage
    (
    FILE_FORMAT => 'uspto_xml_splitter_fmt',
    PATTERN => '.*.gz'
    )
    WHERE metadata$filename NOT IN (SELECT DISTINCT file_name FROM uspto_db.raw.patent_assignment_xml)
    ;

    -- 3. Parse text chunks into XML and insert valid records into the final table
    INSERT INTO uspto_db.raw.patent_assignment_xml (xml_content, file_name)
    SELECT 
        PARSE_XML(
            -- Locate the start of the tag and remove preceding header artifacts
            SUBSTR(raw_chunk, CHARINDEX('<patent-assignment>', raw_chunk)) 
            -- Re-append the closing tag consumed by the delimiter during splitting
            || '</patent-assignment>'
        ),
        file_name
    FROM raw_xml_chunks_temp
    WHERE raw_chunk LIKE '%<patent-assignment%'; -- Filter out file footers or invalid chunks

    RETURN 'XML data loaded successfully via chunking.';
END;
$$;

-- 4. Schedule task to execute the loading procedure on the last day of every month at 01:00 AM Paris time
CREATE OR REPLACE TASK load_patent_xml_task
    WAREHOUSE = uspto_wh
    SCHEDULE = 'USING CRON 0 1 L * * Europe/Paris'
AS
    CALL load_patent_xml_proc();

-- 5. Resume the task to enable the schedule
ALTER TASK load_patent_xml_task RESUME;
