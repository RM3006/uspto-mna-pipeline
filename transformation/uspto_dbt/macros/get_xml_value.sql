/* ---------------------------------------------------------------------------------------------------------------------
   MACRO: Get XML Value
   Description: Safely extracts text values from XML nodes, handling both array and single-node structures.
   ---------------------------------------------------------------------------------------------------------------------
*/
{% macro get_xml_value(xml_column, tag_name) %}
CASE
    -- 1. Handle array structures using the custom UDF to avoid subquery errors
    WHEN IS_ARRAY({{ xml_column }}) THEN
    uspto_db.raw.get_xml_array_value({{ xml_column }}, '{{ tag_name }}')
    -- 2. Handle standard single nodes using native XMLGET and cast to text
    ELSE GET(XMLGET({{ xml_column }}, '{{ tag_name }}'),'$')::VARCHAR
END

{% endmacro %}