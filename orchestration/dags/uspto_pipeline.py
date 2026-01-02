import os
import pendulum
from airflow import DAG
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig

# 1. Define the timezone
# Europe/Paris is used for local scheduling
local_tz = pendulum.timezone("Europe/Paris")

# 2. Establish dynamic paths
# Step 1: Utilize the standard Airflow home environment variable
AIRFLOW_HOME = os.getenv("AIRFLOW_HOME", "/opt/airflow")

# Step 2: Construct the path to the dbt project relative to Airflow Home
# This ensures portability across different environments
DBT_PROJECT_PATH = os.path.join(AIRFLOW_HOME, "transformation/uspto_dbt")

# 3. Define the path to the dbt virtual environment executable
# This points to the isolated venv created in the Dockerfile
DBT_EXECUTABLE_PATH = os.path.join(AIRFLOW_HOME, "dbt_venv/bin/dbt")

# 4. Set up the configurations
# Step 1: Map the Snowflake profile and production target
profile_config = ProfileConfig(
    profile_name="uspto_dbt",
    target_name="prod",
    profiles_yml_filepath="/home/airflow/.dbt/profiles.yml"
)

# Step 2: Point to the virtual environment for dbt execution
execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE_PATH,
)

# 5. Define a function to handle failures
def on_dag_failure(context):
    # Step 1: Extract details from the Airflow context
    task_instance = context.get('task_instance')
    dag_id = context.get('dag').dag_id
    task_id = task_instance.task_id
    execution_date = context.get('execution_date')
    
    # Step 2: Print a high-visibility message to the logs
    print("=" * 60)
    print(f"🚨 ALERT: DAG [{dag_id}] FAILED 🚨")
    print(f"Task: {task_id}")
    print(f"Execution Date: {execution_date}")
    print(f"Log URL: {task_instance.log_url}")
    print("=" * 60)

# 6. Initialize the DbtDag
# Step 1: Assemble all configurations into the DbtDag instance
# Step 2: Set the schedule to 6:00 AM Paris time daily
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
