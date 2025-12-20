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