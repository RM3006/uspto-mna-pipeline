/* ---------------------------------------------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Create Table to store raw xml data.
   ---------------------------------------------------------------------------------------------------------------------
*/

USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create table to store raw XML content
-- Use VARIANT data type to efficiently store semi-structured XML data
CREATE TABLE IF NOT EXISTS patent_assignment_xml (
    file_name VARCHAR,
    xml_content VARIANT,
    loaded_at TIMESTAMP_NTZ DEFAULT to_timestamp_ntz(convert_timezone('Europe/Paris', current_timestamp()))
);
