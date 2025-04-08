select
        parent,
        child, -- the model with potentially long run time / compilation time, improve performance by breaking the upstream chain of views
        distance,
        path
    from {{ ref('int_all_dag_relationships') }}
    where distance <> 0
    and not parent_is_excluded
    and not child_is_excluded
    and is_dependent_on_chain_of_views
    and child_resource_type = 'model'
    and distance > {{ var('chained_views_threshold') }}

{{ filter_exceptions() }}

order by distance desc