-- Data Quality Test: Validates that the assignee_name column contains no NULL values
SELECT *
FROM USPTO_DB.ANALYTICS_staging.stg_patent_assignees
WHERE assignee_name IS NULL