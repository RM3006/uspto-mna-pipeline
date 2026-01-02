
    
    

select
    patent_sk as unique_field,
    count(*) as n_records

from USPTO_DB.ANALYTICS_analytics.dim_patents
where patent_sk is not null
group by patent_sk
having count(*) > 1


