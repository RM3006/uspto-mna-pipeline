# Infrastructure Overview

This directory contains the code definition for the project's underlying architecture. The infrastructure is managed as code (IaC) to ensure reproducibility, version control, and automated deployment.

The infrastructure is divided into two primary domains:

## 1. Cloud Infrastructure (`/aws`)
Managed via **Terraform**. This section handles the provisioning of AWS resources required for the Data Lake, including S3 storage buckets and IAM (Identity and Access Management) roles required for secure external access.

## 2. Data Warehouse Infrastructure (`/snowflake`)
Managed via **SnowSQL** and raw SQL scripts. This section defines the Snowflake environment, including:
* **Role-Based Access Control (RBAC):** Custom roles for CI/CD and project developers.
* **Compute:** Warehouses with auto-suspend configurations.
* **Storage:** Databases, schemas, and external stages.
* **Integration:** Storage integrations linking Snowflake to the AWS Data Lake.

Refer to the specific subdirectories for detailed documentation on deployment and resource configuration.