{{
    config(
        materialized='table'
    )
}}


WITH
    source AS (
        SELECT *
        FROM
            {{ source( 'uspto', 'patent_assignment_xml') }}
        -- Deduplicate records based on content hash, retaining the latest load
        QUALIFY
            ROW_NUMBER()
                OVER (PARTITION BY MD5(xml_content) ORDER BY loaded_at DESC)
            = 1
    ),

    -- Extract the root 'assignment-record' node to simplify downstream parsing
    xml_root AS (
        SELECT
            file_name,
            loaded_at,
            XMLGET(xml_content, 'assignment-record') AS record_node
        FROM source
    ),

    -- Parse specific fields from the extracted record node
    parsed AS (
        SELECT
            file_name,
            loaded_at,

            -- Extract core assignment metadata
            XMLGET(record_node, 'reel-no'):"$"::VARCHAR AS reel_number,
            XMLGET(record_node, 'frame-no'):"$"::VARCHAR AS frame_number,
            XMLGET(record_node, 'conveyance-text'):"$"::VARCHAR
                AS conveyance_text,
            XMLGET(record_node, 'page-count'):"$"::INTEGER AS page_count,

            -- Extract and cast dates, converting from XML string format to Date type
            TRY_TO_DATE(
                XMLGET(
                    XMLGET(record_node, 'recorded-date'), 'date'
                ):"$"::VARCHAR,
                'YYYYMMDD'
            ) AS recorded_date,
            TRY_TO_DATE(
                XMLGET(
                    XMLGET(record_node, 'last-update-date'), 'date'
                ):"$"::VARCHAR,
                'YYYYMMDD'
            ) AS last_update_date
        FROM xml_root
    )

SELECT *
FROM
    parsed
