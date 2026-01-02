# Step 1: Use the official Airflow base image
FROM apache/airflow:2.10.4

# Step 2: Switch to root to install all system dependencies at once
USER root

# Step 3: Install git and essential build tools for dbt and Snowflake
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         git \
         libpq-dev \
         build-essential \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Step 4: Switch back to the airflow user for Python package management
USER airflow

# Step 5: Create a virtual environment specifically for dbt
# Step 6: Install dbt-snowflake in the isolated venv to avoid dependency conflicts
RUN python -m venv /opt/airflow/dbt_venv && \
    /opt/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-snowflake==1.8.0

# Step 7: Install astronomer-cosmos in the main Airflow environment
# Cosmos acts as the "bridge" and needs to live where Airflow can see it
RUN pip install --no-cache-dir astronomer-cosmos
