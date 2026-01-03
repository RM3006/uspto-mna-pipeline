# Snowflake Infrastructure

This directory contains the SQL scripts that define the objects, permissions, and logic within the Snowflake Data Warehouse. The scripts are organized to distinguish between one-time manual setup and automated deployments.

## Directory Structure

### Bootstrap (`/bootstrap`)
Contains scripts that must be run manually by an `ACCOUNTADMIN`.
* **00_admin_setup.sql:** Creates the `CI_CD_ROLE`, grants account-level privileges, and establishes the trust foundation for GitHub Actions.
* **01_storage_integration.sql:** Creates the `STORAGE INTEGRATION` object connecting Snowflake to the AWS S3 bucket using the ARN provided by Terraform.

### Automated Scripts
These scripts are executed automatically by the CI/CD pipeline in alphanumeric order.

* **01_project_setup.sql:** Provisions the project-specific role (`uspto_role`), warehouse (`uspto_wh`), database, and schemas (`raw`, `staging`, `analytics`).
* **02_create_stage.sql:** Defines the external stage `uspto_raw_stage` and the XML file format.
* **03_create_raw_tables.sql:** Creates the target table `patent_assignment_xml` using the `VARIANT` data type.
* **04_create_loader.sql:** Deploys the stored procedure and logic to chunk, parse, and load large XML files.
* **05_xml_array_function.sql:** Deploys helper User Defined Functions (UDFs) for efficient XML parsing.

## Design Principles
* **Idempotency:** All scripts use `CREATE OR REPLACE` or `IF NOT EXISTS` to allow safe re-execution.
* **Separation of Concerns:** Data is logically separated into `RAW` (ingest), `STAGING` (clean), and `ANALYTICS` (consumption) schemas.