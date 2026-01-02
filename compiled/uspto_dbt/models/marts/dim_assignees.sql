

/*
    Dimension: dim_assignees
    Grain: One row per unique Assignee Name.
    Description: Contains static attributes of the assignee (Address, Location).
*/
WITH
    source AS (
        SELECT
            assignee_name,
            city,
            state,
            country,
            reel_number,
            frame_number
        FROM USPTO_DB.ANALYTICS_staging.stg_patent_assignees
        WHERE assignee_name IS NOT NULL
    ),

    deduplicated_assignees AS (
        SELECT
        -- Normalize name to uppercase to catch basic duplicates (e.g., "Google" vs "GOOGLE")
            
UPPER(TRIM(assignee_name))
 AS assignee_name_clean,
            --address_1,
            city,
            state,
            country
        FROM source
        -- Deduplicate: Retain the address from the most recent assignment
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(assignee_name))
            ORDER BY reel_number DESC, frame_number DESC
        ) = 1
    )

SELECT
    -- Surrogate Key
    assignee_name_clean AS assignee_name,

    -- Attributes
    city,
    state,
    country,
    MD5(assignee_name_clean) AS assignee_sk,

    TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()))
        AS loaded_at

FROM deduplicated_assignees