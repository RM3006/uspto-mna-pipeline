-- ----------------------------------------------------------------------------
-- AUTOMATED DEPLOY: Stage and File Format
-- Runs automatically via CI-CD using uspto_role
-- ----------------------------------------------------------------------------
USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create format for GZIP compressed XML files
CREATE OR REPLACE FILE FORMAT xml_format
    TYPE = 'XML'
    COMPRESSION = GZIP            -- Explicitly tells Snowflake to expect .gz
    STRIP_OUTER_ELEMENT = TRUE
;

-- 2. Creating the Stage using the Integration
-- Note: usage on the integration was granted in the admin script
CREATE OR REPLACE STAGE uspto_raw_stage
  URL = 's3://uspto-data-lake-fbb0e73b/raw/'
  STORAGE_INTEGRATION = uspto_s3_int
  FILE_FORMAT = xml_format;