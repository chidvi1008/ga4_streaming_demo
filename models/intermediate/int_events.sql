-- models/int_events.sql
{{ config(materialized='incremental', unique_key='event_id') }}

with src as (
  select event_id, user_id, event_name, source, medium, campaign, event_timestamp, ingestion_time
  from {{ ref('stg_events') }}
)

{% if is_incremental() %}
, recent as (
  select *
  from src
  where event_timestamp >= (
    select coalesce(max(event_timestamp), timestamp_sub(current_timestamp(), interval 24 hour))
    from {{ this }}
  )
)
select * from recent
{% else %}
select * from src
{% endif %}
