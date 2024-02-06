{% macro resume_task(relation) %}
    {% set query %}
        ALTER TASK IF EXISTS {{ relation }} RESUME
    {% endset %}

    {% do run_query(query) %}
{% endmacro %}