{% macro pause_task(relation) %}
    {% set query %}
        ALTER TASK IF EXISTS {{ relation }} SUSPEND;
    {% endset %}

    {% do run_query(query) %}
{% endmacro %}