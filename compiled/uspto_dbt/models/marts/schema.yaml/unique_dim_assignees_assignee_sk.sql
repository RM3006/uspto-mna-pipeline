
    
    

select
    assignee_sk as unique_field,
    count(*) as n_records

from USPTO_DB.ANALYTICS_analytics.dim_assignees
where assignee_sk is not null
group by assignee_sk
having count(*) > 1


