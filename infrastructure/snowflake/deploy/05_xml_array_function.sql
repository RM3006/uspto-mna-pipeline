/* ---------------------------------------------------------------------------------------------------------------------
   DEPLOYMENT SCRIPT (AUTOMATED)
   Run as: CI_CD_ROLE (via GitHub Actions)
   Description: Create Function to properly look up xml arrays.
   ---------------------------------------------------------------------------------------------------------------------
*/

USE ROLE uspto_role;
USE DATABASE uspto_db;
USE SCHEMA raw;

-- 1. Create helper function to search XML arrays efficiently
-- Use FILTER to avoid subquery errors commonly encountered with XMLGET
CREATE OR REPLACE FUNCTION get_xml_array_value(data VARIANT, tag_name VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
    GET( FILTER( data, x -> x:"@" = tag_name )[0], '$' )::VARCHAR
$$;
