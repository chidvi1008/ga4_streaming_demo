
---

## **WORKLOAD.md**

```markdown
# GA4 Streaming Demo - Workload

## 1. Cloud Functions
- **generate_events**
  - Generates 5–20 sample GA4 events every invocation.
  - Publishes to `ga4_events` Pub/Sub topic.
- **pubsub_to_bq**
  - Subscribes to `ga4_events` topic.
  - Inserts incoming events into `stg_events` table in BigQuery.
  - Handles decoding, logging, and error reporting.

## 2. BigQuery
- **stg_events**
  - Raw events from Pub/Sub (auto-created in BigQuery ingestion if using direct ingestion).
- **int_events**
  - Deduplicated incremental events from `stg_events`.
- **mart_attribution**
  - Aggregated metrics for each user:
    - First / Last attribution
    - 14-day activity
    - Channel breakdown

## 3. dbt Pipeline
- Incremental materialization for `int_events`.
- Aggregation for `mart_attribution`.
- Tests:
  - `not_null`
  - `unique`
- Documentation:
  - Column descriptions in `schema.yml`.
- Scheduling:
  - dbt Cloud job or Cloud Scheduler triggers.

## 4. Visualization
- Metrics dashboards powered by `mart_attribution`.

## 5. Orchestration
- Pub/Sub → BigQuery ingestion → dbt incremental → mart aggregation.
- Dashboards auto-refresh with latest data.

## 6. Notes
- Cloud Functions, Pub/Sub, BigQuery, and dbt all versioned in GitHub.
- Incremental logic ensures historical data is preserved.
