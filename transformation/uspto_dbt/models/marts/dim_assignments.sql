{{config(materialized='table')}}

WITH source as (
    SELECT
    reel_number,
    frame_number,
    recorded_date,
    conveyance_text,
    page_count
    FROM
    {{ref('stg_patent_assignments')}}
)

SELECT
    --Surrogate Key (composite)
    MD5(reel_number || frame_number) as assignment_sk,

    --Natural keys
    reel_number,
    frame_number,

    --Attributes
    recorded_date,
    conveyance_text,
    page_count,
    to_timestamp_ntz(convert_timezone('Europe/Paris',current_timestamp())) as loaded_at
FROM
    source

