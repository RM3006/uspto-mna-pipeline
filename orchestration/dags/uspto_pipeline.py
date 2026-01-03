import os
import pendulum
from airflow import DAG
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig

# 1. Define the timezone configuration
# Set the local timezone to Europe/Paris for scheduling purposes
local_tz = pendulum.timezone("Europe/Paris")

# 2. Establish dynamic file paths
# Define the Airflow home directory using environment variables or a default path
AIRFLOW_HOME = os.getenv("AIRFLOW_HOME", "/opt/airflow")

# Construct the absolute path to the dbt project directory
# This ensures the pipeline locates the project regardless of the environment
DBT_PROJECT_PATH = os.path.join(AIRFLOW_HOME, "transformation/uspto_dbt")

# 3. Configure the dbt execution environment
# Point to the isolated virtual environment executable created in the Dockerfile
DBT_EXECUTABLE_PATH = os.path.join(AIRFLOW_HOME, "dbt_venv/bin/dbt")

# 4. Set up Cosmos configurations
# Define the profile configuration to map the dbt project to the Snowflake connection
profile_config = ProfileConfig(
    profile_name="uspto_dbt",
    target_name="prod",
    profiles_yml_filepath="/home/airflow/.dbt/profiles.yml"
)

# Define the execution configuration to use the specific dbt binary
execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE_PATH,
)

# 5. Define failure handling logic
def on_dag_failure(context):
    # Extract relevant task and execution details from the Airflow context
    task_instance = context.get('task_instance')
    dag_id = context.get('dag').dag_id
    task_id = task_instance.task_id
    execution_date = context.get('execution_date')
    
    # Log a high-visibility alert message containing failure details
    print("=" * 60)
    print(f"🚨 ALERT: DAG [{dag_id}] FAILED 🚨")
    print(f"Task: {task_id}")
    print(f"Execution Date: {execution_date}")
    print(f"Log URL: {task_instance.log_url}")
    print("=" * 60)

# 6. Initialize the Cosmos DAG
# Create the DAG instance integrating the project, profile, and execution configs
# Schedule the DAG to run daily at 06:00 AM Paris time
uspto_cosmos_dag = DbtDag(
    project_config=ProjectConfig(DBT_PROJECT_PATH),
    profile_config=profile_config,
    execution_config=execution_config,
    dag_id="uspto_cosmos_pipeline",
    start_date=pendulum.datetime(2024, 1, 1, tz=local_tz),
    schedule_interval='0 6 * * *',
    catchup=False,
    on_failure_callback=on_dag_failure
)