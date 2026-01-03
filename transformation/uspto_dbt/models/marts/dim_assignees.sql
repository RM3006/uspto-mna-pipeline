{{ config(materialized='table') }}

/* ---------------------------------------------------------------------------------------------------------------------
   Dimension: dim_assignees
   Grain: One row per unique Assignee Name.
   Description: Stores static attributes of the assignee including address and location details.
   ---------------------------------------------------------------------------------------------------------------------
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
        FROM {{ ref('stg_patent_assignees') }}
        WHERE assignee_name IS NOT NULL
    ),

    deduplicated_assignees AS (
        SELECT
        -- Standardize assignee names to uppercase to resolve simple duplicates
            {{ clean_assignee_name('assignee_name') }} AS assignee_name_clean,
            --address_1,
            city,
            state,
            country
        FROM source
        -- Deduplicate records by retaining the address information from the most recent assignment
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
