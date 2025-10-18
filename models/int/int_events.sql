-- models/int/int_events.sql
{{ config(
    materialized='incremental',
    unique_key='event_id'
) }}

with new_events as (
  select *
  from `sylvan-client-475418-b8.realtime_demo.stg_events`
  {% if is_incremental() %}
    where ingestion_time > (
      select coalesce(max(ingestion_time), timestamp_sub(current_timestamp(), interval 24 hour))
      from {{ this }}
    )
  {% endif %}
)

select *(except rn)
from (
    select *,
           row_number() over(partition by event_id order by ingestion_time desc) as rn
    from new_events
)
where rn = 1