

WITH
    source AS (
        SELECT * FROM uspto_db.raw.patent_assignment_xml
        -- Deduplicate records based on content hash, keeping the most recently loaded version
        QUALIFY
            ROW_NUMBER()
                OVER (PARTITION BY MD5(xml_content) ORDER BY loaded_at DESC)
            = 1
    ),

    -- Flatten the XML structure to create one row per assignee per assignment
    flattened AS (
        SELECT
        -- Extract unique identifiers to maintain relationship with the parent record
            GET(
                XMLGET(XMLGET(source.xml_content, 'assignment-record'), 'reel-no'), '$'
            )::VARCHAR AS reel_number,
            GET(
                XMLGET(XMLGET(source.xml_content, 'assignment-record'), 'frame-no'),
                '$'
            )::VARCHAR AS frame_number,
            assignee.value AS assignee_node

        FROM source,
            -- Explode the 'patent-assignees' array into individual rows
            LATERAL FLATTEN(
                input => XMLGET(source.xml_content, 'patent-assignees'):"$",
                outer => true -- Retain records even if no assignees are present
            ) AS assignee
    )

SELECT
    reel_number,
    frame_number,

    -- Extract specific fields from the flattened assignee node using a macro helper
    
CASE
    -- 1. Handle array structures using the custom UDF to avoid subquery errors
    WHEN IS_ARRAY(assignee_node) THEN
    uspto_db.raw.get_xml_array_value(assignee_node, 'name')
    -- 2. Handle standard single nodes using native XMLGET and cast to text
    ELSE GET(XMLGET(assignee_node, 'name'),'$')::VARCHAR
END

 AS assignee_name,
    
CASE
    -- 1. Handle array structures using the custom UDF to avoid subquery errors
    WHEN IS_ARRAY(assignee_node) THEN
    uspto_db.raw.get_xml_array_value(assignee_node, 'city')
    -- 2. Handle standard single nodes using native XMLGET and cast to text
    ELSE GET(XMLGET(assignee_node, 'city'),'$')::VARCHAR
END

 AS city,
    
CASE
    -- 1. Handle array structures using the custom UDF to avoid subquery errors
    WHEN IS_ARRAY(assignee_node) THEN
    uspto_db.raw.get_xml_array_value(assignee_node, 'state')
    -- 2. Handle standard single nodes using native XMLGET and cast to text
    ELSE GET(XMLGET(assignee_node, 'state'),'$')::VARCHAR
END

 AS state,
    
CASE
    -- 1. Handle array structures using the custom UDF to avoid subquery errors
    WHEN IS_ARRAY(assignee_node) THEN
    uspto_db.raw.get_xml_array_value(assignee_node, 'country-name')
    -- 2. Handle standard single nodes using native XMLGET and cast to text
    ELSE GET(XMLGET(assignee_node, 'country-name'),'$')::VARCHAR
END

 AS country

FROM flattened
-- Filter results to retain valid JSON arrays or valid XML nodes
-- Exclude invalid artifacts generated during the flattening process
WHERE
    (IS_ARRAY(assignee_node) = true)
    OR (CHECK_XML(assignee_node::VARCHAR) IS null)