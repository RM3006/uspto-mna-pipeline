/* ---------------------------------------------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Provision project-specific resources including roles, warehouses, and schemas.
   ---------------------------------------------------------------------------------------------------------------------
*/

-- 1. Create the project-specific role to isolate permissions
CREATE ROLE IF NOT EXISTS uspto_role;
GRANT ROLE uspto_role TO ROLE sysadmin;

-- 2. Create the compute warehouse with auto-suspend enabled to minimize costs
CREATE WAREHOUSE IF NOT EXISTS uspto_wh
WITH WAREHOUSE_SIZE = 'X-SMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS uspto_db;

-- 3. Grant usage privileges on infrastructure objects to the project role
GRANT USAGE ON WAREHOUSE uspto_wh TO ROLE uspto_role;
GRANT USAGE ON DATABASE uspto_db TO ROLE uspto_role;

-- 4. Create logical schemas to organize data by lifecycle stage
USE DATABASE uspto_db;
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

-- 5. Grant schema-level privileges to allow object creation and management
GRANT USAGE ON ALL SCHEMAS IN DATABASE uspto_db TO ROLE uspto_role;
GRANT CREATE STAGE ON SCHEMA raw TO ROLE uspto_role;
GRANT CREATE TABLE ON SCHEMA raw TO ROLE uspto_role;
GRANT CREATE FILE FORMAT ON SCHEMA raw TO ROLE uspto_role;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA uspto_db.raw TO ROLE uspto_role;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA uspto_db.raw TO ROLE uspto_role;
GRANT ALL ON SCHEMA staging TO ROLE uspto_role;
GRANT ALL ON SCHEMA analytics TO ROLE uspto_role;
-- 6. Grant the project role to the developer user (passed as variable)
-- This ensures the developer can access resources created by the CI/CD pipeline
GRANT ROLE uspto_role TO USER IDENTIFIER($developer_user);
