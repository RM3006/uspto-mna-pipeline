{{ config(materialized='table') }}

/* Optimizes performance by pre-extracting nodes before flattening. */
WITH
    source AS (
        SELECT
        -- Extract unique identifiers early to minimize data volume in downstream operations
            XMLGET(
                XMLGET(xml_content, 'assignment-record'), 'reel-no'
            ):"$"::VARCHAR AS reel_number,
            XMLGET(
                XMLGET(xml_content, 'assignment-record'), 'frame-no'
            ):"$"::VARCHAR AS frame_number,

            -- Pre-extract the 'patent-properties' node once per file to speed up flattening
            XMLGET(xml_content, 'patent-properties'):"$" AS properties_node
        FROM {{ source('uspto', 'patent_assignment_xml') }}
        -- Deduplicate records based on content hash
        QUALIFY
            ROW_NUMBER()
                OVER (PARTITION BY MD5(xml_content) ORDER BY loaded_at DESC)
            = 1
    ),

    flattened_patents AS (
        SELECT
            source.reel_number,
            source.frame_number,
            p.value AS patent_node
        FROM source,
            LATERAL FLATTEN(
                input =>
                CASE
                -- Handle both array and single-node structures using the pre-extracted node
                    WHEN IS_ARRAY(source.properties_node) THEN source.properties_node
                    WHEN
                        source.properties_node IS NOT NULL
                        THEN ARRAY_CONSTRUCT(source.properties_node)
                    ELSE ARRAY_CONSTRUCT()
                END
            ) AS p
    )

SELECT
    reel_number,
    frame_number,

    -- Extract detailed patent attributes from the flattened node
    XMLGET(XMLGET(patent_node, 'document-id'), 'doc-number'):"$"::VARCHAR
        AS document_number,
    XMLGET(XMLGET(patent_node, 'document-id'), 'country'):"$"::VARCHAR
        AS country,
    XMLGET(XMLGET(patent_node, 'document-id'), 'kind'):"$"::VARCHAR
        AS kind_code,
    XMLGET(patent_node, 'invention-title'):"$"::VARCHAR AS invention_title,

    -- Extract and cast the document date
    TRY_TO_DATE(
        XMLGET(XMLGET(patent_node, 'document-id'), 'date'):"$"::VARCHAR,
        'YYYYMMDD'
    ) AS document_date

FROM flattened_patents
WHERE document_number IS NOT NULL
