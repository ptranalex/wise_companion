Wise Companion - Manual QA Checklist (MVP)

PR4 - Keychain API key

Step: Open Settings -> enter API key -> Save -> quit app -> relaunch -> key should still be present.
Step: Remove key -> relaunch -> key should be absent and QuoteView should show missing-key callout.

PR5 - Auto-launch on login

Step: Toggle "Launch on login" ON -> quit app -> logout/login -> app should auto-start.
Step: Toggle "Launch on login" OFF -> quit app -> logout/login -> app should not auto-start.
Step: If toggling fails, verify macOS System Settings -> Login Items to confirm current state.

PR7 - QuoteService + UI wiring

Step: With no API key saved, Quote popover should show the "OpenAI API key required" callout; Settings link works.
Step: With a valid API key saved, open popover -> shows loading state -> renders quote + context.
Step: Close popover during loading -> no error UI should appear; reopening should work normally.
Step: Reopen popover same day -> should load quickly from cache (usually minimal/no spinner).
Step: Flip Economy/Premium in Settings -> returning to quote should regenerate for the new mode.
Step: Offline/blocked network, open popover -> shows error + Retry button; Retry should attempt again (no infinite loop).
