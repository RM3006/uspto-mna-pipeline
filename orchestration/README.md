# Orchestration (Airflow)

This directory contains the logic for scheduling and managing the end-to-end data pipeline using **Apache Airflow**.

## Configuration

The Airflow environment is containerized using Docker to ensure consistency between development and production environments.

* **`docker-compose.yaml`:** Defines the multi-container architecture, including the Airflow Scheduler, Webserver, Worker, Postgres (metadata database), and Redis (broker).
* **`Dockerfile`:** Extends the official Airflow image to include:
    * System dependencies (`libpq-dev`, `git`).
    * A dedicated virtual environment (`dbt_venv`) for `dbt-snowflake` to avoid dependency conflicts.
    * The `astronomer-cosmos` library for integrating dbt DAGs.

## Pipeline Logic

### `uspto_pipeline.py`
This script defines the primary DAG (`uspto_cosmos_pipeline`).
* **Schedule:** Runs daily at 06:00 Europe/Paris time.
* **Framework:** Uses **Cosmos** to render the dbt project as a native Airflow Task Group.
* **Failure Handling:** Includes a custom callback function to log high-visibility alerts upon task failure.

## Environment Variables
The pipeline relies on a `.env` file (generated or manually created) to inject Snowflake credentials and AWS configuration into the containers at runtime.