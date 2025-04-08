select * from (
    select
        triad_relationships.*,
        case
            when single_use_resources.parent is not null then true
            else false
        end as is_loop_independent
    from (
    select
        rejoined.parent,
        rejoined.child,
        direct_child.parent as parent_and_child
    from (
    select
        parent,
        child
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where parent_resource_type not in ('exposure', 'metric')
    and child_resource_type not in ('exposure', 'metric')
    and not parent_is_excluded
    and not child_is_excluded
) as all_relationships
    group by parent,child
    having (sum(case when distance = 1 then 1 else 0 end) >= 1
        and sum(case when distance = 2 then 1 else 0 end) >= 1)
) as rejoined
    left join (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where parent_resource_type not in ('exposure', 'metric')
    and child_resource_type not in ('exposure', 'metric')
    and not parent_is_excluded
    and not child_is_excluded
) as direct_child
        on rejoined.child = direct_child.child
        and direct_child.distance = 1
    left join (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where parent_resource_type not in ('exposure', 'metric')
    and child_resource_type not in ('exposure', 'metric')
    and not parent_is_excluded
    and not child_is_excluded
) as direct_parent
        on rejoined.parent = direct_parent.parent
        and direct_parent.distance = 1
    where direct_child.parent = direct_parent.child
) as triad_relationships
    left join (
    select
        parent
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where parent_resource_type not in ('exposure', 'metric')
    and child_resource_type not in ('exposure', 'metric')
    and not parent_is_excluded
    and not child_is_excluded
) as all_relationships
    where distance = 1
    group by parent
    having count(*) = 1
) as single_use_resources
        on triad_relationships.parent_and_child = single_use_resources.parent
) as final
where is_loop_independent

{{ filter_exceptions() }}
