{% materialization task_table, adapter='snowflake', supported_languages=['sql']%}

  {% set original_query_tag = set_query_tag() %}

  {%- set identifier = model['alias'] -%}
  {%- set language = model['language'] -%}

  {% set grant_config = config.get('grants') %}
  {% set task_config = config.get('task') %}

  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set target_relation = api.Relation.create(identifier=identifier,
                                                schema=schema,
                                                database=database, type='table') -%}

  {% set task_identifier = task_config.name or target_relation.identifier %}
  {% set task_schema = task_config.schema or target_relation.schema %}
  {% set task_database = task_config.database or target_relation.database %}
  {% set task_relation = api.Relation.create(database=task_database, schema=task_schema, identifier=task_identifier) %}
  {{ pause_task(task_relation) }}

  -- Determine if this task is a root or child task
  {% if task_config.schedule and task_config.after %}
    {{ exceptions.raise_fail_fast_error("A task may not contain both the schedule and after argument. See `" ~ target_relation ~ "`") }}
  {% elif task_config.schedule %}
    {% set is_root = True %}
  {% elif task_config.after %}
    {% set is_root = False %}
  {% else %}
    {{ exceptions.raise_fail_fast_error("A task must specify either the schedule or after argument. See `" ~ target_relation ~ "`") }}
  {% endif %}

  {% if is_root %}
    {% set root_task = task_relation %}
  {% else %}
    {% set root_task = find_root_task(task_config.after) %}
    {{ pause_task(root_task) }}
  {% endif %}

  {{ run_hooks(pre_hooks) }}

  {#-- Drop the relation if it was a view to "convert" it in a table. This may lead to
    -- downtime, but it should be a relatively infrequent occurrence  #}
  {% if old_relation is not none and not old_relation.is_table %}
    {{ log("Dropping relation " ~ old_relation ~ " because it is of type " ~ old_relation.type) }}
    {{ drop_relation_if_exists(old_relation) }}
  {% endif %}

  {% call statement('main', language=language) -%}
      {{ create_task(task_relation, task_config) }}
      {{ create_table_as(false, target_relation, compiled_code, 'sql') }}
  {%- endcall %}

  {{ run_hooks(post_hooks) }}

  {% set should_revoke = should_revoke(old_relation, full_refresh_mode=True) %}
  {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}

  {% do persist_docs(target_relation, model) %}

  {% do unset_query_tag(original_query_tag) %}

  {{ return({'relations': [target_relation, task_relation]}) }}

{% endmaterialization %}
