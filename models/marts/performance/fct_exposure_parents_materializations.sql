select
        parent_resource_type,
        parent as parent_resource_name,
        child as exposure_name,
        parent_materialized as parent_model_materialization
from (
    select *
    from {{ ref('int_all_dag_relationships') }}
    where
        distance = 1
        and child_resource_type = 'exposure'
        and ((
                parent_resource_type = 'model'
                and parent_materialized in ('view', 'ephemeral')
            )
            or (
                parent_resource_type = 'source'
            )
    )
        -- no test on child_is_excluded because exposures are never excluded
        and not parent_is_excluded)
where 1=1
{{ filter_exceptions() }}