-- ---------------------------------------------------------------------------------------------------------------------
-- ADMIN SETUP: Create Storage Integration
-- Manual Execution Required: Run as ACCOUNTADMIN
-- ---------------------------------------------------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

-- 1. Create Storage Integration object to connect Snowflake with AWS S3
CREATE OR REPLACE STORAGE INTEGRATION USPTO_S3_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
-- Set the AWS Role ARN using the output from Terraform
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::056244392718:role/uspto_snowflake_reader_role'
-- Set the allowed S3 bucket location using the output from Terraform
STORAGE_ALLOWED_LOCATIONS = ('s3://uspto-data-lake-fbb0e73b/raw/');

-- 2. Grant usage privileges on the integration to the project role
GRANT USAGE ON INTEGRATION USPTO_S3_INT TO ROLE USPTO_ROLE;

-- 3. Retrieve the AWS IAM User and External ID for the trust policy configuration
DESC STORAGE INTEGRATION USPTO_S3_INT;
