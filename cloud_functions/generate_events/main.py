import json
import random
import uuid
from google.cloud import pubsub_v1

PROJECT_ID = "sylvan-client-475418-b8"
TOPIC_ID = "ga4_events"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

SOURCES = ["google", "facebook", "email", "direct"]
MEDIA = ["organic", "cpc", "email"]
EVENTS = ["page_view", "product_view", "add_to_cart", "purchase"]

def generate_event(request):
    n = random.randint(5, 20)
    count = 0
    for _ in range(n):
        event_data = {
            "event_id": str(uuid.uuid4()),
            "user_id": str(random.randint(1000, 9999)),
            "event_name": random.choice(EVENTS),
            "source": random.choice(SOURCES),
            "medium": random.choice(MEDIA),
            "campaign": random.choice(["", "summer_sale", "launch"])
        }
        data = json.dumps(event_data).encode("utf-8")
        future = publisher.publish(topic_path, data)
        future.result()  # wait for publish confirmation
        count += 1
    return f"✅ Published {count} events to {TOPIC_ID}"
