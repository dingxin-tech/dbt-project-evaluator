select * from (
    select
        child
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where child_resource_type = 'model'
    -- only filter out excluded children nodes
    -- filtering parents could result in incorrectly flagging nodes that depend on excluded nodes
    and not child_is_excluded
    -- exclude required time spine
    and child != 'metricflow_time_spine'
) as model_relationships
    group by child
    having max(distance) = 0
) as final
where 1=1
{{ filter_exceptions() }}