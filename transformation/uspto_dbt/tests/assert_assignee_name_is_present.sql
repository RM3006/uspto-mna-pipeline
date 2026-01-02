-- This test fails if any assignee name is NULL
SELECT *
FROM {{ ref('stg_patent_assignees') }}
WHERE assignee_name IS NULL
