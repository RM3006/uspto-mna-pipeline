USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- Create a format to split the large XML file into text chunks
CREATE OR REPLACE FILE FORMAT uspto_xml_splitter_fmt
    TYPE = 'CSV'
    COMPRESSION = GZIP
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '</patent-assignment>' -- Splits file at the closing tag
    SKIP_HEADER = 0
    TRIM_SPACE = FALSE;

-- Stored Procedure to load chunks, clean them, and parse into XML
CREATE OR REPLACE PROCEDURE load_patent_xml_proc()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    -- 1. Create temporary table for raw text chunks
    CREATE OR REPLACE TEMPORARY TABLE raw_xml_chunks_temp (
        raw_chunk VARCHAR,
        file_name VARCHAR
    );

    -- 2. Load data and capture the specific filename for each chunk
    INSERT INTO raw_xml_chunks_temp (raw_chunk, file_name)
        SELECT 
            $1,                 -- The text chunk
            metadata$filename   -- The dynamic filename from S3
        FROM @uspto_raw_stage
    (
    FILE_FORMAT => 'uspto_xml_splitter_fmt',
    PATTERN => '.*.gz'
    )
    WHERE metadata$filename NOT IN (SELECT DISTINCT file_name FROM uspto_db.raw.patent_assignment_xml)
    ;

    -- 3. Clean, parse, and insert into final table
    INSERT INTO uspto_db.raw.patent_assignment_xml (xml_content, file_name)
    SELECT 
        PARSE_XML(
            -- Locate start of tag and remove preceding header junk
            SUBSTR(raw_chunk, CHARINDEX('<patent-assignment>', raw_chunk)) 
            -- Re-append the closing tag consumed by the delimiter
            || '</patent-assignment>'
        ),
        file_name
    FROM raw_xml_chunks_temp
    WHERE raw_chunk LIKE '%<patent-assignment%'; -- Filter out footers

    RETURN 'XML data loaded successfully via chunking.';
END;
$$;

-- 4. Create task triggering the procedure every last day of the month at 01:00 AM Paris, Europe timezone
CREATE OR REPLACE TASK load_patent_xml_task
    WAREHOUSE = uspto_wh
    SCHEDULE = 'USING CRON 0 1 L * * Europe/Paris'
AS
    CALL load_patent_xml_proc()
;

-- 5. Resume the Task
ALTER TASK load_patent_xml_task RESUME;