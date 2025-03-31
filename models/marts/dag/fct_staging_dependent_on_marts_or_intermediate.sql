-- cases where a staging model depends on a marts/intermediate model
-- data should flow from raw -> staging -> intermediate -> marts
select * from (
    select
        parent,
        parent_model_type,
        child,
        child_model_type
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where distance = 1
    and parent_resource_type = 'model'
    and child_resource_type = 'model'
    and not parent_is_excluded
    and not child_is_excluded
) as direct_model_relationships
    where child_model_type = 'staging'
    and parent_model_type in ('marts', 'intermediate')
) as final
where 1=1
{{ filter_exceptions() }}