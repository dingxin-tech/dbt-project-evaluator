-- This model finds all cases where a model is NOT in the appropriate subdirectory:
    -- For staging models: The files should be in nested in the staging folder in a subfolder that matches their source parent's name.
    -- For non-staging models: The files should be nested closest to their appropriate folder.  
{% set directory_pattern = get_directory_pattern() %}
 
select * from (
    select * from (
    select distinct
        child as resource_name,
        child_resource_type as resource_type,
        child_model_type as model_type,
        child_file_path as current_file_path,
        'models{{ directory_pattern }}' || '{{ var("staging_folder_name") }}' || '{{ directory_pattern }}' || parent_source_name || '{{ directory_pattern }}' || child_file_name as change_file_path_to
    from (
    select
        child,
        child_resource_type,
        child_model_type,
        child_file_path,
        child_directory_path,
        child_file_name,
        parent_source_name
    from (
    select * from {{ ref('int_all_dag_relationships') }}
    where not child_is_excluded
) as all_dag_relationships
    where parent_resource_type = 'source'
    and child_resource_type = 'model'
    and child_model_type = 'staging'
) as staging_models
    where child_directory_path not like '%' || parent_source_name || '%'
) as inappropriate_subdirectories_staging
    union all
    select * from (
    select
        all_graph_resources.resource_name,
        all_graph_resources.resource_type,
        all_graph_resources.model_type,
        all_graph_resources.file_path as current_file_path,
        'models' || '{{ directory_pattern }}...{{ directory_pattern }}' || folders.folder_name_value || '{{ directory_pattern }}...{{ directory_pattern }}' || all_graph_resources.file_name as change_file_path_to
    from (
    select * from {{ ref('int_all_graph_resources') }}
    where not is_excluded
) as all_graph_resources
    left join (
    select * from {{ ref('stg_naming_convention_folders') }}
) as folders
        on folders.model_type = all_graph_resources.model_type
    where all_graph_resources.model_type <> all_graph_resources.model_type_folder
) as innappropriate_subdirectories_non_staging_models
)
where 1=1
{{ filter_exceptions() }}
 

