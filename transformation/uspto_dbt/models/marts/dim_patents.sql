{{ config(materialized='table') }}

/*
    Dimension: dim_patents
    Grain: One row per unique Patent Document Number.
    Description: Contains static attributes of a patent (Date, Title, Country).
*/

WITH unique_patents AS (
    SELECT
        document_number,
        document_date,
        country,
        kind_code,
        invention_title,
        reel_number, 
        frame_number
    FROM {{ ref('stg_patent_properties') }}
    
    -- Deduplicate: Keep only the entry from the most recent assignment (Highest Reel No)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY document_number ORDER BY reel_number DESC, frame_number DESC) = 1
)

SELECT
    -- Surrogate Key (Primary Key for the Dimension)
    MD5(document_number) AS patent_sk,

    -- Natural Key
    document_number,

    -- Attributes
    document_date,
    country,
    kind_code,
    invention_title,
    
    to_timestamp_ntz(convert_timezone('Europe/Paris', current_timestamp())) AS loaded_at

FROM unique_patents