/* ---------------------------------------------------------------------------------------------------------------------
   MACRO: Clean Assignee Name
   Description: Standardizes assignee names by removing whitespace and converting to uppercase for consistency.
   ---------------------------------------------------------------------------------------------------------------------
*/
{% macro clean_assignee_name(column_name) %}
UPPER(TRIM({{ column_name }}))
{% endmacro %}