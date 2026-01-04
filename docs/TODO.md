# Wise Companion — TODO Queue (MVP)

This is the **single execution checklist** for building the MVP. Each top-level item is intended to be a small, reviewable PR.

## How to maintain this doc

- Update this checklist whenever “what we’re doing next” changes (split/merge PRs, add/remove subtasks, mark complete).
- If you discover a new requirement or change scope, update `docs/IMPLEMENTATION_PLAN.md` first, then reflect it here.

## Project hygiene (ongoing)

- [x] Add GitHub Actions CI to build the macOS app on PRs and pushes to `main`

## PR1 — Menu bar shell + main placeholder UI

- [x] Create macOS SwiftUI app shell (menu bar-capable)
- [x] Add menu bar status item (icon)
- [x] Click status item opens main surface (popover)
- [x] Add Quit action
- [x] Build `QuoteView` layout (placeholder content): quote, context, footer (date, settings affordance)
- [x] Manual test: clicking repeatedly does not create duplicate windows or crash

## PR2 — Settings UI + Preferences persistence

- [x] Add Settings surface reachable from main UI
- [x] Persist user prompt text locally
- [x] Persist Economy/Premium mode toggle locally
- [x] Persist auto-launch toggle locally (plumbing only; actual login item in PR5)
- [x] Manual test: preferences persist across app restart

## PR3 — Daily policy + quote cache store + tests

- [x] Implement local calendar `dateKey` (`YYYY-MM-DD`)
- [x] Implement quote cache store (read/write/overwrite) with metadata (`dateKey`, `mode`, timestamps)
- [x] Cache validation rules:
  - [x] Same day + same mode → show cached (no network)
  - [x] New day → regenerate and overwrite cache
  - [x] Same day but mode changed → regenerate and overwrite cache
- [x] Unit tests for:
  - [x] `dateKey` logic (same day / next day)
  - [x] cache read/write/overwrite
  - [x] cache invalidation on mode change

## PR4 — Keychain API key management + UX

- [ ] Implement Keychain wrapper (save/read/delete)
- [ ] Settings UI: API key entry/update + “Remove key”
- [ ] Main UI: missing-key state shows clear copy + “Open Settings”
- [ ] Manual test: key persists across restart; remove key works

## PR5 — Auto-launch (login item) + settings toggle

- [ ] Implement login item via `SMAppService` (preferred)
- [ ] Default ON for new installs (if allowed by OS); degrade gracefully otherwise
- [ ] Settings toggle enables/disables and stays consistent across restarts
- [ ] Manual test: toggle on/off + relogin behavior

## PR6 — OpenAI client + prompt template + parsing + tests

- [ ] Define prompt template enforcing: calm tone, original-only, avoid clichés, short output
- [ ] Define structured output contract (JSON with `quote`, `context`)
- [ ] Implement OpenAI client (async/await, timeouts, error mapping)
- [ ] Implement Economy/Premium config:
  - [ ] Balanced default model selection per mode
  - [ ] Strict max output tokens per mode
- [ ] Unit tests with mocks/fixtures for parsing + error mapping

## PR7 — QuoteService (cache-or-generate) + cancellation + UI wiring

- [ ] Implement `QuoteService.loadToday()` orchestration:
  - [ ] Check cache (dateKey + mode)
  - [ ] Generate if needed
  - [ ] Persist cache
- [ ] Wire `QuoteView` to service and render real data
- [ ] Cancellation: close surface cancels in-flight request (no repeated retries)
- [ ] Manual test: same day shows cached; mode flip regenerates; offline shows error + retry

## PR8 — UX polish + hardening + QA checklist

- [ ] Calm loading state (skeleton/spinner) without blocking modals
- [ ] Calm error states: Retry (user initiated), Open Settings (missing key)
- [ ] Minimal logging policy (no key, no prompts by default)
- [ ] Add `docs/QA_CHECKLIST.md` for manual regression checks
