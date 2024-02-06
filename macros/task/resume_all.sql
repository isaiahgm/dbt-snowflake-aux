{% macro resume_all_tasks(relation) %}
    {% set query %}
        CALL system$task_dependents_enable('{{ relation }}');
    {% endset %}

    {% do run_query(query) %}
{% endmacro %}