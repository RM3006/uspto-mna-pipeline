

/* ---------------------------------------------------------------------------------------------------------------------
   Dimension: dim_patents
   Grain: One row per unique Patent Document Number.
   Description: Stores static attributes of a patent such as publication date, title, and country of origin.
   ---------------------------------------------------------------------------------------------------------------------
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

        -- Deduplicate records by retaining only the entry from the most recent assignment
        -- Order by Reel and Frame number descending to identify the latest record
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