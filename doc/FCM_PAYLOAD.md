# FCM payload

```json
{
  "notification": { "title": "Driver arriving", "body": "ETA 3 min" },
  "data": {
    "rideId": "abc123",
    "type": "driver_arriving",
    "screen": "ride",
    "dedupe_id": "ride-abc-arriving",
    "messageId": "msg-1"
  }
}
```

Data-only fallback: `data.title`, `data.body`.

Server: set `android.ttl` / `apns-expiration` for time-sensitive rides.

Topic: `all_riders` (host subscribes in splash).
