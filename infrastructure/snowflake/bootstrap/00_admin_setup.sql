/* --------------------------------------------------------------------------------
   BOOTSTRAP SCRIPT (MANUAL RUN ONLY)
   Run as: ACCOUNTADMIN
   Description: Sets up the CI/CD Role needed for GitHub Actions.
   --------------------------------------------------------------------------------
*/

USE ROLE SECURITYADMIN;

-- 1. Create the specialized role for the pipeline
CREATE ROLE IF NOT EXISTS CI_CD_ROLE;

-- 2. Grant privileges to manage roles
GRANT CREATE ROLE ON ACCOUNT TO ROLE CI_CD_ROLE;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE CI_CD_ROLE;

-- 3. Grant privileges to manage objects (Build)
GRANT ROLE SYSADMIN TO ROLE CI_CD_ROLE;

-- 4. Grant usage on the warehouse 
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE CI_CD_ROLE;

-- 5. Assign this role to relevant user
SET my_user = CURRENT_USER();
GRANT ROLE CI_CD_ROLE TO USER IDENTIFIER($my_user);

-- Grants on project dedicated role
-- 6. Warehouse (Run & Scale)
-- OPERATE allows the role to start/stop the warehouse if needed
GRANT USAGE, OPERATE ON WAREHOUSE USPTO_WH TO ROLE USPTO_ROLE;

-- 7. Database (Create new layers)
-- CREATE SCHEMA is critical for dbt (which creates 'staging', 'marts' schemas automatically)
GRANT USAGE, MONITOR ON DATABASE USPTO_DB TO ROLE USPTO_ROLE;
GRANT CREATE SCHEMA ON DATABASE USPTO_DB TO ROLE USPTO_ROLE;

-- 8. Schema Level (The "Builder" Access)
-- "ALL PRIVILEGES" covers: Tables, Views, Stages, File Formats, Procedures, Functions, Sequences
GRANT ALL PRIVILEGES ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;

-- 9. Future Proofing (Automatic Grants)
-- Ensures any NEW schema created by anyone else is also accessible
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE USPTO_DB TO ROLE USPTO_ROLE;

-- 10. Automation Privileges (The missing link for your error)
-- EXECUTE TASK is an ACCOUNT-level privilege. You cannot grant it on a specific database.
GRANT EXECUTE TASK ON ACCOUNT TO ROLE USPTO_ROLE;
-- MANAGED TASK currently not recognized by sqlfluff so we add a condition to exclude the line of code below from the sqlfluff checks
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE USPTO_ROLE; -- noqa: PRS

-- 11. Pipe Privileges (For Snowpipe/Streams later)
GRANT CREATE PIPE ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;
GRANT CREATE STREAM ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;
