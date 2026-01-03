/* ---------------------------------------------------------------------------------------------------------------------
   BOOTSTRAP SCRIPT (MANUAL RUN ONLY)
   Run as: ACCOUNTADMIN
   Description: Configures the CI/CD Role required for GitHub Actions automation.
   ---------------------------------------------------------------------------------------------------------------------
*/

USE ROLE SECURITYADMIN;

-- 1. Create dedicated role for CI/CD pipeline operations
CREATE ROLE IF NOT EXISTS CI_CD_ROLE;

-- 2. Grant role management privileges to allow role creation and grant modification
GRANT CREATE ROLE ON ACCOUNT TO ROLE CI_CD_ROLE;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE CI_CD_ROLE;

-- 3. Grant system administration privileges to the role
GRANT ROLE SYSADMIN TO ROLE CI_CD_ROLE;

-- 4. Grant usage privileges on the compute warehouse
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE CI_CD_ROLE;

-- 5. Assign the CI/CD role to the current user for testing purposes
SET my_user = CURRENT_USER();
GRANT ROLE CI_CD_ROLE TO USER IDENTIFIER($my_user);

-- Grants on project dedicated role
-- 6. Grant warehouse usage and operation privileges to allow scaling and execution
GRANT USAGE, OPERATE ON WAREHOUSE USPTO_WH TO ROLE USPTO_ROLE;

-- 7. Grant database privileges to allow monitoring and schema creation
GRANT USAGE, MONITOR ON DATABASE USPTO_DB TO ROLE USPTO_ROLE;
GRANT CREATE SCHEMA ON DATABASE USPTO_DB TO ROLE USPTO_ROLE;

-- 8. Grant full privileges on the raw schema to allow object management
GRANT ALL PRIVILEGES ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;

-- 9. Grant automatic privileges on all future schemas created in the database
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE USPTO_DB TO ROLE USPTO_ROLE;

-- 10. Grant account-level privileges for task execution
GRANT EXECUTE TASK ON ACCOUNT TO ROLE USPTO_ROLE;
-- Grant managed task execution privileges (excluded from linting due to parser limitations)
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE USPTO_ROLE; -- noqa: PRS

-- 11. Grant privileges required for Snowpipe and Stream creation
GRANT CREATE PIPE ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;
GRANT CREATE STREAM ON SCHEMA USPTO_DB.RAW TO ROLE USPTO_ROLE;
