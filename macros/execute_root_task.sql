{% macro execute_root_task() %}

  {% if execute %}
  {{ log("========== Execute Tasks ===========", info=True) }}
  {% for x in varargs -%}
    {% do log(x, info=True) %}
    {{ snowflake__execute_task(x) }}
  {% endfor %}
  {{ log("(Check Snowflake for DAG run status)", info=True) }}
  {{ log("====================================", info=True) }}
  {% endif %}

{% endmacro %}
