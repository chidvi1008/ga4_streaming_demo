{{ config(
    materialized='incremental',
    unique_key='event_id'
) }}

with new_events as (
    select *
    from `realtime_demo.stg_events`
    {% if is_incremental() %}
    where ingestion_time > (
        select coalesce(max(ingestion_time), timestamp_sub(current_timestamp(), interval 24 hour))
        from {{ this }}
    )
    {% endif %}
),

ranked as (
    select
        event_id,
        user_id,
        event_name,
        source,
        medium,
        campaign,
        event_timestamp,
        ingestion_time,
        row_number() over(partition by event_id order by ingestion_time desc) as rn
    from new_events
)

select
    event_id,
    user_id,
    event_name,
    source,
    medium,
    campaign,
    event_timestamp,
    ingestion_time
from ranked
where rn = 1
