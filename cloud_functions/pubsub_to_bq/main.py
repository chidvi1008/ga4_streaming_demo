import base64
import json
from datetime import datetime
from google.cloud import bigquery
from flask import Request

BQ_TABLE = "sylvan-client-475418-b8.realtime_demo.stg_events"
client = bigquery.Client()

def pubsub_to_bq(request: Request):
    """
    Handles Pub/Sub messages via CloudEvents for Cloud Run HTTP service.
    """
    try:
        envelope = request.get_json()
        if not envelope:
            print("No JSON payload received")
            return "Bad Request: no JSON", 400

        # Extract message from CloudEvent
        if 'message' in envelope:
            payload_b64 = envelope['message']['data']
        elif 'data' in envelope:
            payload_b64 = envelope['data']
        else:
            print("No message data found in envelope")
            return "Bad Request: no message", 400

        payload = base64.b64decode(payload_b64).decode('utf-8')
        msg = json.loads(payload)

    except Exception as e:
        print("decode error:", e)
        return f"decode error: {e}", 400

    row = {
        "event_id": msg.get("event_id"),
        "user_id": msg.get("user_id"),
        "event_name": msg.get("event_name"),
        "source": msg.get("source"),
        "medium": msg.get("medium"),
        "campaign": msg.get("campaign"),
        "event_timestamp": datetime.utcnow().isoformat(),
        "ingestion_time": datetime.utcnow().isoformat()
    }

    errors = client.insert_rows_json(BQ_TABLE, [row])
    if errors:
        print("BQ insert errors:", errors)
        return f"BigQuery insert errors: {errors}", 500
    else:
        print(f"Inserted: {row['event_id']}")
        return f"Inserted: {row['event_id']}", 200
