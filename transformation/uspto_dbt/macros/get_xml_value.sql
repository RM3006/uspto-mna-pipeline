{% macro get_xml_value(xml_column, tag_name) %}
CASE
    WHEN IS_ARRAY({{ xml_column }}) THEN
    uspto_db.raw.get_xml_array_value({{ xml_column }}, '{{ tag_name }}')
    ELSE GET(XMLGET({{ xml_column }}, '{{ tag_name }}'),'$')::VARCHAR
END

{% endmacro %}
