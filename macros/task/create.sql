{% macro create_task(relation, settings) -%}
CREATE OR REPLACE TASK {{ relation }}
  WAREHOUSE = {{ settings.warehouse or 'ANALYTICAL_WH' }}
{%- if settings.schedule %}
  SCHEDULE = '{{ settings.schedule }}'
{%- endif -%}
{%- if settings.allow_overlapping_execution %}
  ALLOW_OVERLAPPING_EXECTUION = {{ settings.allow_overlapping_execution }}
{%- endif -%}
{%- if settings.user_task_timeout_ms %}
  USER_TASK_TIMEOUT_MS = {{ settings.user_task_timeout_ms }}
{%- endif -%}
{%- if settings.suspend_task_after_num_failures %}
  SUSPEND_TASK_AFTER_NUM_FAILURES = {{ settings.suspend_task_after_num_failures }}
{%- endif -%}
{%- if settings.error_integration %}
  ERROR_INTEGRATION = {{ settings.error_integration }}
{%- endif -%}
{%- if settings.comment %}
  COMMENT = '{{ settings.comment }}'
{%- endif -%}
{%- if settings.after %}
  AFTER {{ settings.after }}
{%- endif -%}
{%- if settings.finalize %}
  FINALIZE = '{{ settings.finalize }}'
{%- endif -%}
{%- if settings.when %}
  WHEN {{ settings.when }}
{%- endif %}
AS
{%- endmacro %}