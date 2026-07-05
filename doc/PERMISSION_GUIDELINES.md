# Permission guidelines

| Concern | Owner |
|---------|-------|
| First-launch permission UX (blocking alerts) | `hovr_device_permissions` |
| Check before display | `hovr_local_and_push_notification` |
| On-demand permission when posting fails | `requestNotificationPermission()` / `postLocal()` |
| Register for remote (iOS) | `hovr_device_permissions` after grant |

`showLocal` returns `false` when the OS denies display. Use `postLocal()` to request permission and retry once, or call `requestNotificationPermission()` explicitly before posting.

Host apps may still rely on `hovr_device_permissions` for splash-time prompts; the plugin permission API is for recovery when a post fails.
