-- ----------------------------------------------------------------------------
-- ADMIN SETUP: Create Storage Integration
-- Manual Execution Required: Run as ACCOUNTADMIN
-- ----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

-- 1. Create Storage Integration object
CREATE OR REPLACE STORAGE INTEGRATION USPTO_S3_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
-- Replace with Terraform output AWS_IAM_SNOWFLAKE_ROLE value
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::056244392718:role/uspto_snowflake_reader_role'
-- Replace with Terraform output AWS_BUCKET_NAME value
STORAGE_ALLOWED_LOCATIONS = ('s3://uspto-data-lake-fbb0e73b/raw/');

-- 2. Grant usage to project role
GRANT USAGE ON INTEGRATION USPTO_S3_INT TO ROLE USPTO_ROLE;

-- 3. Retrieve IAM User for AWS Trust Policy
DESC STORAGE INTEGRATION USPTO_S3_INT;
