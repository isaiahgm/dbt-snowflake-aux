# DBT Snowflake Aux
Auxiliary Macros for the [DBT Snowflake Adapter](https://github.com/dbt-labs/dbt-snowflake). 
Adds a task [Snowflake Task](https://docs.snowflake.com/en/user-guide/tasks-intro) materialization option and other macros to assist in deploying task DAGs in Snowflake from DBT.

## Installation Instructions
Follow the installation instructs found [here](https://docs.getdbt.com/docs/build/packages#how-do-i-add-a-package-to-my-project) to add DBT Snowflake Aux to your project. 

Include the following in either dependencies.yml or packages.yml
```yaml
packages:
  - git: "https://github.com/isaiahgm/dbt-snowflake-aux.git"
    revision: v0.1.0
```

## How to Use
The primary feature of this package adds the "task_table" materialization option. This package also adds a number of macros to simplify deploying and executing tasks.
### Task Table Materialization
Use the task table materialization by first creating a table model in your DBT project like this:
```sql
{{
    config(
        materialized = 'table',
    )
}}
SELECT CURRENT_TIMESTAMP
     , CURRENT_USER
     , 'test-' || UUID_STRING()
```
Once you have written the `SELECT` query for your table, it can be converted into a task table by modifying the config block:
```sql
{{
    config(
        materialized = 'task_table',
        task={'name': 'TASK_1',
              'schedule': 'USING CRON 0 0 * * * America/Los_Angeles'},
    )
}}
SELECT CURRENT_TIMESTAMP AS COL_1
     , CURRENT_USER AS COL_2
     , 'test-' || UUID_STRING() AS COL_3
```
This will create a task that will create a table from the `SELECT` query at the specified cadence. 
Reference the `CREATE TASK` page in the [snowflake docs](https://docs.snowflake.com/en/sql-reference/sql/create-task) for more information about the parameters that can be included in the task config. The full list of parameters that can be included in the task config block are as follows:
```sql
{{
    config(
        materialized = 'task_table',
        task={'database': 'DATABASE',
              'schema': 'SCHEMA',
              'name': 'TASK_1',
              'warehouse': 'WAREHOUSE',
              'schedule': 'USING CRON 0 0 * * * America/Los_Angeles',
              'after': 'DATABASE.SCHEMA.TASK_0', --Mutually exclusive with schedule
              'allow_overlapping_execution': False,
              'user_task_timeout_ms': 3600000,
              'suspend_task_after_num_failures': 10,
              'error_integration': 'NOTIFICATION_INTEGRATION',
              'comment': '',
              'finalize': '...',
              'when': '...'},
    )
}}
```

### Activate Root Task
By default, Snowflake tasks are created in a suspended state and will not run until activated by the user. 
Additionally, a task can only be edited while suspended, so any task DAGs updated by DBT will be disabled before the edits are made.

To simplify resuming tasks after creation / updates, use the `activate_root_task` macro in this package by including an on-run-end hook in your `dbt_project.yml`:

```yaml
on-run-end:
  - "{{ activate_root_task('DATABASE.SCHEMA.TASK_1'[, 'DATABASE.SCHEMA.TASK_2']) }}"
```
This macro accepts an arbitrary number of arguments, so it can activate multiple task trees at once. 
You only need to provide the root task name and this macro will resume the entire DAG.

### Execute Root Task
If you want dbt to execute a task DAG, use the `execute_root_task` macro. 
This can be used an on-run-end hook to automatically run a DAG when making updates or run on its own with dbt run-operation.

This macro accepts root task names in the same pattern as the `activate_root_task` macro.

## Resources:
- Learn more about Snowflake Tasks [in the docs](https://docs.snowflake.com/en/user-guide/tasks-intro)
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
