USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Helper Function: Searches arrays efficiently using FILTER (avoids subquery errors)
CREATE OR REPLACE FUNCTION get_xml_array_value(data VARIANT, tag_name VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
    GET( FILTER( data, x -> x:"@" = tag_name )[0], '$' )::VARCHAR
$$;