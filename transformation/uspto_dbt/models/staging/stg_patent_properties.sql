{{ config(materialized='table')}}

/* Optimizes performance by pre-extracting nodes before flattening. */
WITH source AS (
    SELECT
        -- Extract keys early to avoid passing heavy XML blobs downstream
        XMLGET(XMLGET(xml_content, 'assignment-record'), 'reel-no'):"$"::VARCHAR AS reel_no,
        XMLGET(XMLGET(xml_content, 'assignment-record'), 'frame-no'):"$"::VARCHAR AS frame_no,
        
        -- Pre-calculate the node to flatten (Extract once per file)
        XMLGET(xml_content, 'patent-properties'):"$" AS properties_node
    FROM {{ source('uspto', 'patent_assignment_xml') }}
    -- Deduplicate before parsing to save compute resources
    QUALIFY ROW_NUMBER() OVER (PARTITION BY md5(xml_content) ORDER BY loaded_at DESC) = 1
),

flattened_patents AS (
    SELECT
        reel_no,
        frame_no,
        p.value AS patent_node
    FROM source,
    LATERAL FLATTEN(
        input => 
            CASE 
                -- Logic is now faster as it uses the pre-extracted node
                WHEN IS_ARRAY(properties_node) THEN properties_node
                WHEN properties_node IS NOT NULL THEN ARRAY_CONSTRUCT(properties_node)
                ELSE ARRAY_CONSTRUCT() 
            END
    ) p
)

SELECT
    reel_no,
    frame_no,

    -- Extract document details from the flattened patent node
    XMLGET(XMLGET(patent_node, 'document-id'), 'doc-number'):"$"::VARCHAR AS document_number,
    TRY_TO_DATE(XMLGET(XMLGET(patent_node, 'document-id'), 'date'):"$"::VARCHAR, 'YYYYMMDD') AS document_date,
    XMLGET(XMLGET(patent_node, 'document-id'), 'country'):"$"::VARCHAR AS country,
    XMLGET(XMLGET(patent_node, 'document-id'), 'kind'):"$"::VARCHAR AS kind_code,

    -- Extract invention title
    XMLGET(patent_node, 'invention-title'):"$"::VARCHAR AS invention_title

FROM flattened_patents
WHERE document_number IS NOT NULL