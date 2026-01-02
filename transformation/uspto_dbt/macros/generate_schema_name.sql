{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    
    {%- if custom_schema_name is none -%}
        {{ default_schema }}

        {# LOGIC: If Prod, use the clean name (e.g., 'analytics') #}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}

        {# LOGIC: If Dev, append it to the user schema (e.g., 'dbt_dev_analytics') #}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
