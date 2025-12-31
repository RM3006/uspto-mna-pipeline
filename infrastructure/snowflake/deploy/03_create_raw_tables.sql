USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create table to store raw XML content
-- VARIANT column handles semi-structured XML data
CREATE OR REPLACE TABLE patent_assignment_xml (
    file_name VARCHAR,
    xml_content VARIANT,
    loaded_at TIMESTAMP_NTZ DEFAULT to_timestamp_ntz(convert_timezone('Europe/Paris', current_timestamp()))
);

