-- cases where a marts/intermediate model directly references a raw source
select
        parent,
        parent_resource_type,
        child,
        child_model_type
from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where distance = 1
    and not parent_is_excluded
    and not child_is_excluded
)
where parent_resource_type = 'source'
      and child_model_type in ('marts', 'intermediate')
