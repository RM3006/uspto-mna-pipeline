
    
    

select
    assignment_sk as unique_field,
    count(*) as n_records

from USPTO_DB.ANALYTICS_analytics.dim_assignments
where assignment_sk is not null
group by assignment_sk
having count(*) > 1


