/* --------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Creates project-specific resources
   --------------------------------------------------------------------------------
*/

-- 1. Create the Project Role
CREATE ROLE IF NOT EXISTS uspto_role;
GRANT ROLE uspto_role TO ROLE SYSADMIN;

-- 2. Create Infrastructure
CREATE WAREHOUSE IF NOT EXISTS uspto_wh
    WITH WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS uspto_db;

-- 3. Permissions
GRANT USAGE ON WAREHOUSE uspto_wh TO ROLE uspto_role;
GRANT USAGE ON DATABASE uspto_db TO ROLE uspto_role;

-- 4. Schema Setup
USE DATABASE uspto_db;
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- 5. Project Role Access
GRANT USAGE ON ALL SCHEMAS IN DATABASE uspto_db TO ROLE uspto_role;
GRANT CREATE STAGE ON SCHEMA raw TO ROLE uspto_role;
GRANT CREATE TABLE ON SCHEMA raw TO ROLE uspto_role;
GRANT CREATE VIEW ON SCHEMA analytics TO ROLE uspto_role;

-- 6. Grant to Developer
-- 'developer_user' to be passed as an argument
GRANT ROLE uspto_role TO USER IDENTIFIER($developer_user);
