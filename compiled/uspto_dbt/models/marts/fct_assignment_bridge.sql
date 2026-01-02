

/*
    Mart: fct_assignment_bridge
    Grain: One row per Assignee per Patent per Assignment.
*/

WITH
    patents AS (
        SELECT
            reel_number,
            frame_number,
            document_number
        FROM USPTO_DB.ANALYTICS_staging.stg_patent_properties
    ),

    assignees AS (
        SELECT
            reel_number,
            frame_number,
            assignee_name
        FROM USPTO_DB.ANALYTICS_staging.stg_patent_assignees
    )

SELECT
    MD5(p.reel_number || p.frame_number) AS assignment_sk,
    MD5(p.document_number) AS patent_sk,

    -- Use the same macro here to guarantee the keys match the Dimension
    MD5(
UPPER(TRIM(a.assignee_name))
) AS assignee_sk,

    TO_TIMESTAMP_NTZ(CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()))
        AS loaded_at

FROM patents AS p
INNER JOIN assignees AS a
    ON
        p.reel_number = a.reel_number
        AND p.frame_number = a.frame_number