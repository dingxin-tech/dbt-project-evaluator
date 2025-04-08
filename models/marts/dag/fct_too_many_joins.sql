select * from (
    select
        child as resource_name,
        child_file_path as file_path,
        cast(count(distinct parent) as {{ dbt.type_int() }}) as join_count
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where not child_is_excluded
    and child_resource_type = 'model'
) as all_dag_relationships
    where distance = 1
    group by resource_name, file_path
    having count(distinct parent) >= {{ var('too_many_joins_threshold') }}
) as final
where 1=1
{{ filter_exceptions() }}
