# Industry benchmarks

Source of truth for notification channel IDs and v1/v2 scope. Enforced by `tool/check_industry_benchmarks.dart`.

## Reference apps

- **Uber** — separate ride vs promo channels; silent push wakes app when realtime stream drops
- **Lyft** — live-activity style updates; avoid mixing promos with ride channel
- **DoorDash** — order updates vs marketing channels

## Canonical Android / iOS channel table

| Channel ID | User-visible name | Importance | Category | v1 |
|------------|-------------------|------------|----------|-----|
| `hovr_ride_status` | Ride updates | HIGH | TRANSPORT | Yes — FCM push |
| `hovr_ride_promo` | Offers & tips | LOW | PROMO | Constants only |
| `hovr_local_default` | App alerts | HIGH | STATUS | Yes — local |

## v1 vs v2

| Feature | v1 | v2 |
|---------|----|----|
| Local show / cancel | Yes | — |
| FCM push display | Yes | — |
| pushEvents stream | Yes | — |
| Notification grouping | — | Yes |
| Rich images | — | Yes |
| Android FGS for BG location | — | Yes |
| Live Activities | — | Yes |

## FCM payload keys (host)

- `rideId`, `screen`, `action`, `dedupe_id`, `messageId`

## Token lifecycle

- Register on splash + `pushEvents` type `token`
- Re-register on login/logout
- Server stores token + timestamp; prune stale tokens

## Official references

- [FCM token management](https://firebase.google.com/docs/cloud-messaging/manage-tokens)
- [Android FGS types](https://developer.android.com/develop/background-work/services/fgs/service-types)
- [FCM images (iOS)](https://firebase.google.com/docs/cloud-messaging/ios/send-image)
