USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- Create table to store raw XML content
-- VARIANT column handles semi-structured XML data
CREATE OR ALTER TABLE patent_assignment_xml (
    file_name VARCHAR,
    loaded_at TIMESTAMP_NTZ DEFAULT to_timestamp_ntz(convert_timezone('Europe/Paris',  current_timestamp())),
    xml_content VARIANT
)
;