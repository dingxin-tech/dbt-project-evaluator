select * from (
    select
        parent,
        parent_model_type,
        {{ dbt.listagg(
            measure = 'child',
            delimiter_text = "', '",
            order_by_clause = 'order by child' if target.type in ['snowflake','redshift','duckdb','trino','maxcompute'])
        }} as leaf_children
    from (
    select
        all_dag_relationships.parent,
        all_dag_relationships.parent_model_type,
        all_dag_relationships.child
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where not parent_is_excluded
    and not child_is_excluded
) as all_dag_relationships
    inner join (
    select
        parent
    from (
    select
        *
    from {{ ref('int_all_dag_relationships') }}
    where not parent_is_excluded
    and not child_is_excluded
) as all_dag_relationships
    where parent_resource_type = 'model'
    group by parent
    having max(distance) = 0
) as models_without_children
        on all_dag_relationships.child = models_without_children.parent
    where all_dag_relationships.distance = 1 and all_dag_relationships.child_resource_type = 'model'
    group by all_dag_relationships.parent,all_dag_relationships.parent_model_type,all_dag_relationships.child
    order by all_dag_relationships.parent,all_dag_relationships.parent_model_type,all_dag_relationships.child
) as model_fanout
    group by parent,parent_model_type
    having count(*) >= {{ var('models_fanout_threshold') }}
) as model_fanout_agg
where 1=1
{{ filter_exceptions() }}