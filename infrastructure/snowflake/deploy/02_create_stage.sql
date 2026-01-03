/* ---------------------------------------------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Create Stage and File Format.
   ---------------------------------------------------------------------------------------------------------------------
*/

USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create file format to handle GZIP compressed XML files
CREATE OR REPLACE FILE FORMAT xml_format
TYPE = 'XML'
COMPRESSION = GZIP            -- Explicitly define compression type for correct parsing
STRIP_OUTER_ELEMENT = TRUE;

-- 2. Create the external stage using the storage integration
-- Usage privileges on the integration object were granted in the admin setup script
CREATE OR REPLACE STAGE uspto_raw_stage
    URL = 's3://uspto-data-lake-fbb0e73b/raw/'
    STORAGE_INTEGRATION = uspto_s3_int
    FILE_FORMAT = xml_format;
