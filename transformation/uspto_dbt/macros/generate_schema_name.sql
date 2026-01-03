/* ---------------------------------------------------------------------------------------------------------------------
   MACRO: Generate Schema Name
   Description: Dynamically determines the target schema name based on the deployment environment.
   ---------------------------------------------------------------------------------------------------------------------
*/
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    
    {# 1. Check if a custom schema is provided; default to the target schema if not #}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}

        {# 2. Production Environment: Use the custom schema name directly (e.g., 'analytics') #}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}

        {# 3. Development Environment: Append custom name to default schema (e.g., 'dbt_dev_analytics') #}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}