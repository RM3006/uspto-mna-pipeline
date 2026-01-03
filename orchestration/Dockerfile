# 1. Define the base image
# Use the official Airflow image with the specific version tag
FROM apache/airflow:2.10.4

# 2. Switch user permissions
# Switch to root to perform system-level package installations
USER root

# 3. Install system dependencies
# Update package lists and install build tools required for dbt and Snowflake
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         git \
         libpq-dev \
         build-essential \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 4. Revert user permissions
# Switch back to the airflow user for Python package management
USER airflow

# 5. Create isolated environment for dbt
# Create a dedicated virtual environment to avoid dependency conflicts with Airflow
# Install the dbt-snowflake adapter within this isolated environment
RUN python -m venv /opt/airflow/dbt_venv && \
    /opt/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-snowflake==1.8.0

# 6. Install Cosmos provider
# Install astronomer-cosmos in the main environment to enable Airflow-dbt integration
RUN pip install --no-cache-dir astronomer-cosmos