{{ config(materialized='view') }}

/*
    Report: rpt_data_science_input
    Description: Denormalized view of the Star Schema for Data Science & Algorithmic use.
    Contains: One row per Patent-Assignee-Assignment link.
*/

SELECT
    -- 1. Patent Features
    p.document_number,
    p.document_date,
    p.country,
    p.kind_code,
    p.invention_title,

    -- 2. Assignee Features
    a.assignee_name,
    a.city AS assignee_city,
    a.state AS assignee_state,
    a.country AS assignee_country,

    -- 3. Assignment Features (Transaction Metadata)
    t.recorded_date,
    t.conveyance_text,
    t.reel_number,
    t.frame_number,

    -- 4. Calculated Features (e.g., Asset Age at time of transfer)
    DATEDIFF('day', p.document_date, t.recorded_date) AS days_since_publication

FROM {{ ref('fct_assignment_bridge') }} AS f
-- Join back to the Dimensions to fetch the text attributes
INNER JOIN {{ ref('dim_patents') }} AS p ON f.patent_sk = p.patent_sk
INNER JOIN {{ ref('dim_assignees') }} AS a ON f.assignee_sk = a.assignee_sk
INNER JOIN
    {{ ref('dim_assignments') }} AS t
    ON f.assignment_sk = t.assignment_sk
