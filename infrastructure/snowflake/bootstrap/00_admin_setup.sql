-- 1. Create a specialized role for your CI/CD pipeline
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS ci_cd_role;

-- 2. Give it the power to "Hire" (Security Admin privileges)
GRANT CREATE ROLE ON ACCOUNT TO ROLE ci_cd_role;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE ci_cd_role; 
-- (MANAGE GRANTS is powerful: allows modifying privileges it doesn't own)

-- 3. Give it the power to "Build" (Sysadmin hierarchy)
GRANT ROLE SYSADMIN TO ROLE ci_cd_role;