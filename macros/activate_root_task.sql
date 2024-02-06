{% macro activate_root_task() %}

  {% if execute %}
  {{ log("========== Activate Tasks ==========", info=True) }}
  {% for x in varargs -%}
    {% do log(x, info=True) %}
    {{ snowflake__resume_all_tasks(x) }}
  {% endfor %}
  {{ log("====================================", info=True) }}
  {% endif %}

{% endmacro %}
