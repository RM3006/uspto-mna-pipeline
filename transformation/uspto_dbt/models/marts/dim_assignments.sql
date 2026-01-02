{{ config(materialized='table') }}

WITH
    source AS (
        SELECT
            reel_number,
            frame_number,
            recorded_date,
            conveyance_text,
            page_count
        FROM
            {{ ref('stg_patent_assignments') }}
    )

SELECT
    --Surrogate Key (composite)
    reel_number,

    --Natural keys
    frame_number,
    recorded_date,

    --Attributes
    conveyance_text,
    page_count,
    MD5(reel_number || frame_number) AS assignment_sk,
    TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()))
        AS loaded_at
FROM
    source
