from airflow import DAG
from airflow.operators.bash import BashOperator
import pendulum

# 1. Define the timezone
local_tz = pendulum.timezone("Europe/Paris")

# 2. Define the failure callback function
def print_failure_log(context):
    """
    Prints a standardized error message to the logs when a task fails.
    """
    task_instance = context['task_instance']
    task_id = task_instance.task_id
    dag_id = task_instance.dag_id
    log_url = task_instance.log_url
    
    # This message will appear in the Airflow Task Logs
    print(f"""
    ############################################################
    [CRITICAL FAILURE DETECTED]
    DAG: {dag_id}
    TASK: {task_id}
    TIME: {pendulum.now(local_tz)}
    
    ACTION REQUIRED:
    The dbt pipeline has stopped. Please check the logs above 
    to diagnose the Snowflake or dbt error.
    
    Direct Log Link: {log_url}
    ############################################################
    """)

# 3. Default settings for the DAG
default_args = {
    'owner': 'romen',
    'depends_on_past': False,
    
    # --- FAILURE HANDLING ---
    'retries': 2,
    'retry_delay': pendulum.duration(minutes=5),
    'on_failure_callback': print_failure_log, # Triggers the function above
    
    # Disable email alerts to keep it simple
    'email_on_failure': False,
    'email_on_retry': False,
}

# 4. Overall DAG set up
with DAG(
    dag_id='uspto_daily_pipeline',
    default_args=default_args,
    description='Runs dbt pipeline for USPTO data',
    schedule_interval='0 6 * * *', 
    start_date=pendulum.datetime(2024, 1, 1, tz=local_tz),
    catchup=False,
    tags=['dbt', 'snowflake'],
) as dag:

    # Task 1: Check dbt connectivity
    dbt_debug = BashOperator(
        task_id='dbt_debug',
        bash_command='cd /opt/airflow/dbt/uspto_dbt && dbt debug'
    )

    # Task 2: Run the Production Build
    dbt_build = BashOperator(
        task_id='dbt_build_prod',
        bash_command='cd /opt/airflow/dbt/uspto_dbt && dbt build --target prod'
    )
    # 5. Define dependency
    dbt_debug >> dbt_build