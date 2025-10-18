-- models/mart/mart_attribution.sql
{{ config(
    materialized='incremental',
    unique_key='user_id'
) }}

-- Step 1: consider last 14 days of events from int_events
with events_14d as (
    select *
    from {{ ref('int_events') }}
    where event_timestamp >= timestamp_sub(current_timestamp(), interval 14 day)
),

-- Step 2: compute first click per user
first_click as (
    select *
    from (
        select *,
               row_number() over(partition by user_id order by event_timestamp asc) as rn
        from events_14d
    )
    where rn = 1
),

-- Step 3: compute last click per user
last_click as (
    select *
    from (
        select *,
               row_number() over(partition by user_id order by event_timestamp desc) as rn
        from events_14d
    )
    where rn = 1
)

-- Step 4: merge first and last clicks for each user
select
    f.user_id,
    f.event_timestamp as first_click_ts,
    l.event_timestamp as last_click_ts,
    f.source as first_source,
    l.source as last_source,
    f.medium as first_medium,
    l.medium as last_medium,
    f.campaign as first_campaign,
    l.campaign as last_campaign
from first_click f
join last_click l
  on f.user_id = l.user_id