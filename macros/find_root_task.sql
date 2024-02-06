{% macro find_root_task(task) -%}
  {% set query %}
      DESC TASK {{ task }};
      SELECT parse_json("task_relations")['Predecessors'][0]::varchar AS PARENT FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
  {% endset %}
  {% set parent_task %}
      {{ run_query(query).columns[0].values()[0]}}
  {% endset %}
  {% if parent_task|length > 0 %}
      find_root_task(parent_task)
  {% endif %}
  {{ return(parent_task) }}
{%- endmacro %}