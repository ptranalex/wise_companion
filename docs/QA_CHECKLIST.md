# Wise Companion — Manual QA Checklist (MVP)

## PR5 — Auto-launch on login
- Toggle “Launch on login” ON → quit app → logout/login → app should auto-start.
- Toggle “Launch on login” OFF → quit app → logout/login → app should not auto-start.
- If toggling fails, verify macOS System Settings → Login Items to confirm current state.

## PR4 — Keychain API key
- Open Settings → enter API key → Save → quit app → relaunch → key should still be present.
- Remove key → relaunch → key should be absent and QuoteView should show missing-key callout.


