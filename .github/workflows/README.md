# CI/CD Workflows

This directory contains the GitHub Actions workflows that automate the testing, integration, and deployment pipelines for the USPTO M&A project. These workflows ensure code quality, infrastructure consistency, and documentation visibility.

## Workflow Descriptions

### 1. Deploy Snowflake Infrastructure (`deploy_infrastructure.yaml`)
* **Trigger:** Push to the `main` branch affecting the `infrastructure/snowflake` directory (excluding bootstrap scripts).
* **Purpose:** Automatically applies changes to the Snowflake environment using SnowSQL.
* **Process:**
    1.  Installs the SnowSQL CLI on an Ubuntu runner.
    2.  Authenticates using repository secrets.
    3.  Scans the infrastructure directory for `.sql` files.
    4.  Executes scripts in alphanumeric order to ensure dependency resolution.

### 2. SQL Quality Check (`sql_lint.yaml`)
* **Trigger:** Push or Pull Request to `main` or `orchestration` branches.
* **Purpose:** Enforces code standards and syntax correctness across the project.
* **Tooling:** Uses **SQLFluff** with the `dbt-snowflake` dialect.
* **Scope:**
    * Lints dbt models and tests.
    * Lints Jinja macros.
    * Lints raw Snowflake SQL infrastructure scripts.

### 3. Deploy dbt Docs (`deploy_docs.yaml`)
* **Trigger:** Push to the `main` branch.
* **Purpose:** Generates and hosts the project's data dictionary and lineage graph.
* **Process:**
    1.  Installs dbt dependencies.
    2.  Compiles the project and generates static HTML documentation (`dbt docs generate`).
    3.  Publishes the artifacts to the `gh-pages` branch for public hosting.

## Configuration
All sensitive credentials (passwords, account identifiers, roles) are managed via GitHub Repository Secrets and injected into the runner environment at runtime.