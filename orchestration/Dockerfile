# Start from the official Airflow image
FROM apache/airflow:2.10.4

# Switch to the 'airflow' user to install python packages
USER airflow

# Copy the requirements file into the container
COPY requirements.txt /requirements.txt

# Install dbt-snowflake
RUN pip install --no-cache-dir -r /requirements.txt

# (Optional) Upgrade pip just in case
RUN pip install --upgrade pip

# Installing Git for Airflow
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         git \
         libpq-dev \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow