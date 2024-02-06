{% macro execute_task(relation) %}
    {% set query %}
        EXECUTE TASK {{ relation }};
    {% endset %}

    {% do run_query(query) %}
{% endmacro %}