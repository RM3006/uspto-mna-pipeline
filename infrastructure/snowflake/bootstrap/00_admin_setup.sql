/* --------------------------------------------------------------------------------
   BOOTSTRAP SCRIPT (MANUAL RUN ONLY)
   Run as: ACCOUNTADMIN
   Description: Sets up the CI/CD Role needed for GitHub Actions.
   --------------------------------------------------------------------------------
*/

USE ROLE SECURITYADMIN;

-- 1. Create the specialized role for the pipeline
CREATE ROLE IF NOT EXISTS ci_cd_role;

-- 2. Grant privileges to manage roles
GRANT CREATE ROLE ON ACCOUNT TO ROLE ci_cd_role;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE ci_cd_role;

-- 3. Grant privileges to manage objects (Build)
GRANT ROLE SYSADMIN TO ROLE ci_cd_role;

-- 4. Grant usage on the warehouse 
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ci_cd_role;

-- 5. Assign this role to relevant user
SET my_user = CURRENT_USER();
GRANT ROLE ci_cd_role TO USER identifier($my_user);

-- Grants on project dedicated role
-- 6. Warehouse (Run & Scale)
-- OPERATE allows the role to start/stop the warehouse if needed
GRANT USAGE, OPERATE ON WAREHOUSE uspto_wh TO ROLE uspto_role;

-- 7. Database (Create new layers)
-- CREATE SCHEMA is critical for dbt (which creates 'staging', 'marts' schemas automatically)
GRANT USAGE, MONITOR ON DATABASE uspto_db TO ROLE uspto_role;
GRANT CREATE SCHEMA ON DATABASE uspto_db TO ROLE uspto_role;

-- 8. Schema Level (The "Builder" Access)
-- "ALL PRIVILEGES" covers: Tables, Views, Stages, File Formats, Procedures, Functions, Sequences
GRANT ALL PRIVILEGES ON SCHEMA uspto_db.raw TO ROLE uspto_role;

-- 9. Future Proofing (Automatic Grants)
-- Ensures any NEW schema created by anyone else is also accessible
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE uspto_db TO ROLE uspto_role;

-- 10. Automation Privileges (The missing link for your error)
-- EXECUTE TASK is an ACCOUNT-level privilege. You cannot grant it on a specific database.
GRANT EXECUTE TASK ON ACCOUNT TO ROLE uspto_role;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE uspto_role; -- Required if you switch to Serverless Tasks

-- 11. Pipe Privileges (For Snowpipe/Streams later)
GRANT CREATE PIPE ON SCHEMA uspto_db.raw TO ROLE uspto_role;
GRANT CREATE STREAM ON SCHEMA uspto_db.raw TO ROLE uspto_role;

