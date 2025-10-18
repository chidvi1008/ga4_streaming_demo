-- models/stg_events.sql
select
  event_id,
  user_id,
  event_name,
  source,
  medium,
  campaign,
  SAFE_CAST(event_timestamp AS TIMESTAMP) AS event_timestamp,
  SAFE_CAST(ingestion_time AS TIMESTAMP) AS ingestion_time
from `{{ var('sylvan-client-475418-b8') }}.realtime_demo.stg_events`