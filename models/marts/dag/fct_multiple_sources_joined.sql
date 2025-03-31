select * from (
    select
        child,
        {{ dbt.listagg(
            measure='parent',
            delimiter_text="', '",
            order_by_clause='order by parent' if target.type in ['snowflake','redshift','duckdb','trino','maxcompute'])
        }} as source_parents
    from (
    select distinct
        child,
        parent
    from {{ ref('int_all_dag_relationships') }}
    where distance = 1
    and parent_resource_type = 'source'
    and not parent_is_excluded
    and not child_is_excluded
    order by child,parent
) as direct_source_relationships
    group by child
    having count(*) > 1
) as multiple_sources_joined
where 1=1
{{ filter_exceptions() }}