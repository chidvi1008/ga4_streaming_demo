-- models/mart_attribution.sql
{{ config(materialized='table') }}

with ranked as (
  select
    user_id,
    source,
    event_timestamp,
    ingestion_time,
    row_number() over (partition by user_id order by event_timestamp asc, ingestion_time asc) as rn_first,
    row_number() over (partition by user_id order by event_timestamp desc, ingestion_time desc) as rn_last
  from {{ ref('int_events') }}
  where user_id is not null
)

select
  user_id,
  max(case when rn_first = 1 then source end) as first_source,
  max(case when rn_last  = 1 then source end) as last_source,
  min(event_timestamp) as first_click_time,
  max(event_timestamp) as last_click_time,
  current_timestamp() as mart_build_time
from ranked
group by user_id
