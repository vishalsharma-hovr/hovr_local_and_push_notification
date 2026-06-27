# Channel contract

## MethodChannel: `hovr_local_and_push_notification`

| Method | Required args | Optional args | Result | Errors |
|--------|---------------|---------------|--------|--------|
| `getFcmToken` | — | — | `String?` | `FCM_ERROR`, `FIREBASE_NOT_INITIALIZED` |
| `showLocal` | `id`, `title`, `body` | `playSound`, `delaySeconds` | `bool` | `MISSING_ARG`, `INVALID_ARG` |
| `cancelLocal` | `id` | — | `null` | `MISSING_ARG` |
| `cancelAllLocal` | — | — | `null` | — |

## EventChannel: `hovr_local_and_push_notification/push`

```json
{
  "type": "message | token | tap",
  "title": "string | null",
  "body": "string | null",
  "data": {},
  "token": "string | null",
  "messageId": "string | null"
}
```

Validation: `id` ≤ 64, `title` ≤ 128, `body` ≤ 512, `delaySeconds` in `[1, 3600]`.

Channel IDs: see [INDUSTRY_BENCHMARKS.md](INDUSTRY_BENCHMARKS.md).

Run `dart run tool/check_channel_contract.dart` after changes.
