-- This test fails if any assignee name is NULL
SELECT *
FROM USPTO_DB.ANALYTICS_staging.stg_patent_assignees
WHERE assignee_name IS NULL