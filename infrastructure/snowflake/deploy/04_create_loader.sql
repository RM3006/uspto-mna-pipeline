USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create Procedure (The Logic)
-- Encapsulates the COPY INTO command for reusability
CREATE OR REPLACE PROCEDURE load_patent_xml_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Load data from stage into raw table
    -- PATTERN ensures only .zip files are processed
    -- ON_ERROR skips bad files to prevent pipeline failure
    COPY INTO patent_assignment_xml (file_name, xml_content)
    FROM (
        SELECT 
            metadata$filename, 
            $1
        FROM @uspto_raw_stage
    )
    FILE_FORMAT = (TYPE = 'XML' STRIP_OUTER_ELEMENT = TRUE)
    PATTERN = '.*.zip'
    ON_ERROR = 'SKIP_FILE';

    RETURN 'Data Load Completed Successfully';
END;
$$;

-- 2. Create Task (The Schedule)
-- triggers the procedure every last day of the month at 01:00 AM Paris, Europe timezone
CREATE OR REPLACE TASK load_patent_xml_task
    WAREHOUSE = uspto_wh
    SCHEDULE = '0 1 L * * Europe/Paris'
AS
    CALL load_patent_xml_proc();

-- 3. Resume the Task
-- Tasks are created in 'SUSPENDED' state by default
ALTER TASK load_patent_xml_task RESUME;