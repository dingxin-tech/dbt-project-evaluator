-- this model finds cases where a source has no children
select * from (
    select
        parent
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where parent_resource_type = 'source'
    and not parent_is_excluded
    and not child_is_excluded
) as source_relationships
    group by parent
    having max(distance) = 0
) as final
where 1=1
{{ filter_exceptions() }}