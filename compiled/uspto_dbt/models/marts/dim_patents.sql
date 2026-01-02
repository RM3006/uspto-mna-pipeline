

/*
    Dimension: dim_patents
    Grain: One row per unique Patent Document Number.
    Description: Contains static attributes of a patent (Date, Title, Country).
*/

WITH
    unique_patents AS (
        SELECT
            document_number,
            document_date,
            country,
            kind_code,
            invention_title,
            reel_number,
            frame_number
        FROM USPTO_DB.ANALYTICS_staging.stg_patent_properties

        -- Deduplicate: Keep only the entry from the most recent assignment (Highest Reel No)
        QUALIFY
            ROW_NUMBER()
                OVER (
                    PARTITION BY document_number
                    ORDER BY reel_number DESC, frame_number DESC
                )
            = 1
    )

SELECT
    -- Surrogate Key (Primary Key for the Dimension)
    document_number,

    -- Natural Key
    document_date,

    -- Attributes
    country,
    kind_code,
    invention_title,
    MD5(document_number) AS patent_sk,

    TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()))
        AS loaded_at

FROM unique_patents