{{
    config(
        materialized='table'
    )
}}


with source as (
SELECT 
*
FROM
{{source( 'uspto', 'patent_assignment_xml')}}
),

-- Step 1: Extracting the 'record_node' first. 
xml_root AS (
    SELECT
        file_name,
        loaded_at,
        XMLGET(xml_content, 'assignment-record') AS record_node
    FROM source
),

-- Step 2: Using 'record_node' to get the fields
parsed as (
    SELECT
        file_name,
        loaded_at,
        
        -- Extract High-Level Fields (using the logic we verified)
        XMLGET(record_node, 'reel-no'):"$" :: VARCHAR AS reel_number,
        XMLGET(record_node, 'frame-no'):"$" :: VARCHAR AS frame_number,
        XMLGET(record_node, 'conveyance-text'):"$" :: VARCHAR AS conveyance_text,
        XMLGET(record_node, 'page-count'):"$" :: INTEGER AS page_count,

        -- Dates require careful handling (XML dates often need casting)
        TRY_TO_DATE(XMLGET(XMLGET(record_node, 'recorded-date'), 'date'):"$"::VARCHAR, 'YYYYMMDD') AS recorded_date,
        TRY_TO_DATE(XMLGET(XMLGET(record_node, 'last-update-date'), 'date'):"$"::VARCHAR, 'YYYYMMDD') AS last_update_date
    FROM xml_root
)

SELECT
*
FROM
parsed