
    
    

with child as (
    select patent_sk as from_field
    from USPTO_DB.ANALYTICS_analytics.fct_assignment_bridge
    where patent_sk is not null
),

parent as (
    select patent_sk as to_field
    from USPTO_DB.ANALYTICS_analytics.dim_patents
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


