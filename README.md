# USPTO M&A Analysis Pipeline

## Project Overview

This project implements an end-to-end data engineering pipeline designed to ingest, transform, and analyze patent assignment data from the United States Patent and Trademark Office (USPTO).

The primary objective is to detect Mergers and Acquisitions (M&A) activity by tracking the transfer of intellectual property rights between entities. By parsing semi-structured XML data containing legal assignment records, the pipeline reconstructs the history of patent ownership, allowing for the identification of corporate acquisition strategies and technology transfer trends.

### Value Proposition
* **Complex Data Parsing:** Demonstrates the ability to flatten and structure hierarchical XML data at scale using Snowflake's native variant capabilities.
* **Modern Data Architecture:** Implements a production-grade ELT (Extract, Load, Transform) pattern, leveraging cloud-native storage and compute.
* **Automated Quality Assurance:** Enforces strict code quality and data integrity standards through continuous integration pipelines and automated testing.

---

## System Architecture

The project is organized into distinct logical domains, each managed by specific tools and workflows.

### 1. Infrastructure as Code (IaC)
The underlying infrastructure is provisioned programmatically to ensure reproducibility and prevent configuration drift.

* **Cloud Layer (AWS):** Managed via **Terraform**. This layer provisions the Data Lake (S3), configuring lifecycle policies, versioning, and strict IAM roles to securely allow external systems to read and write raw data.
* **Data Warehouse Layer (Snowflake):** Managed via **SnowSQL** and versioned SQL scripts. This layer defines the Role-Based Access Control (RBAC) model, compute warehouses, and storage integrations required to mount the S3 Data Lake as an external stage.

### 2. Orchestration
The pipeline execution is managed by **Apache Airflow**, running in a containerized Docker environment.

* **Dynamic DAGs:** Utilizes the **Astronomer Cosmos** library to automatically parse the dbt project and render it as a native Airflow Task Group. This ensures that the orchestration logic remains synchronized with the transformation logic without manual intervention.
* **Environment Isolation:** Transformation tasks execute within a dedicated Python virtual environment inside the Docker container, preventing dependency conflicts between Airflow system libraries and dbt adapters.

### 3. Transformation (dbt)
Data modeling is handled by **dbt (data build tool)**, transforming raw XML blobs into a structured Star Schema.

* **Staging Layer:** Flattens nested XML arrays (Assignees, Inventors) into relational rows and standardizes data types.
* **Marts Layer:** Implements a Star Schema architecture:
    * **Dimensions:** `dim_patents`, `dim_assignees`, `dim_assignments`.
    * **Facts:** `fct_assignment_bridge` links entities to patents via transactions.
* **Reporting Layer:** Generates denormalized views (`rpt_data_science_input`) optimized for downstream analytics and machine learning applications.

### 4. Continuous Integration & Deployment (CI/CD)
GitHub Actions workflows enforce quality standards and automate deployment processes.

* **Code Quality:** Triggers **SQLFluff** on every push to lint SQL files (models, macros, and infrastructure scripts) against defined style guides.
* **Infrastructure Deployment:** Monitors changes to the `infrastructure/snowflake` directory and automatically applies SQL scripts to the target Snowflake environment.
* **Documentation:** automatically generates the dbt Data Dictionary and publishes it to GitHub Pages, providing a live reference for the data model and lineage.

---

## Repository Structure

| Directory | Description |
| :--- | :--- |
| `/.github/workflows` | CI/CD pipeline definitions for linting, deployment, and documentation. |
| `/infrastructure/aws` | Terraform configurations for AWS S3 and IAM resources. |
| `/infrastructure/snowflake` | SQL scripts for Snowflake roles, databases, warehouses, and stages. |
| `/orchestration` | Docker configurations and Python DAGs for Airflow. |
| `/transformation/uspto_dbt` | The dbt project containing models, macros, tests, and documentation. |

## Documentation

For a detailed understanding of the data model, including column definitions and lineage dependencies, refer to the hosted Data Dictionary.

* **Live Documentation:** [View Project Documentation](https://rm3006.github.io/uspto-mna-pipeline/)