# Wise Companion — Implementation Plan (MVP)

## Purpose

This document breaks the MVP into **small, reviewable PR slices** with clear acceptance criteria. It is designed to work well with Cursor AI: each task is scoped, testable, and maps directly to code changes.

## How to maintain this doc

- Update this doc when **scope, sequencing, acceptance criteria, or architecture** changes.
- Treat it as the stable reference for “what we’re building” and “what done means.”
- The day-to-day execution checklist lives in `docs/TODO.md`.

## MVP Decisions (Locked)

- **App type**: Menu bar app
- **Auto-launch**: enabled by default (user can disable)
- **Attribution**: original-only (no famous quotes/attribution in MVP)
- **Cost controls**: Economy/Premium toggle; strict token limits; no repeated auto-retries
- **Freshness boundary**: once per **local calendar day** (local `YYYY-MM-DD`)

## Milestone 0 — Repo & Foundations

### M0.1 Add baseline project structure

- **Scope**: Create a macOS SwiftUI app project skeleton (menu bar-capable).
- **Acceptance criteria**:
  - App builds locally.
  - App runs and shows a minimal UI surface (placeholder text).
- **Notes**: Prefer SwiftUI lifecycle (`@main`) with an app delegate bridge if needed for status item.

### M0.2 Add basic docs + developer workflow

- **Scope**: Ensure docs are discoverable and keep a lightweight workflow (no heavy process).
- **Acceptance criteria**:
  - `docs/PRD.md`, `docs/TECHNICAL_DESIGN.md`, `docs/IMPLEMENTATION_PLAN.md` exist.
  - README (optional) tells how to run/build.
  - GitHub Actions CI builds the app on PRs and pushes to `main` (no code signing).

## Milestone 1 — Menu Bar Shell & UI Surface

### M1.1 Menu bar status item

- **Scope**: Add menu bar icon that opens the main surface.
- **Acceptance criteria**:
  - App appears in the menu bar when running.
  - Clicking the icon opens the content surface.
  - Quit action is available (via menu or system).
- **Test plan**:
  - Launch app → confirm status item appears.
  - Click status item repeatedly → no crashes, no duplicate windows.

### M1.2 Main quote view (static)

- **Scope**: Build the main quote UI with placeholder content.
- **Acceptance criteria**:
  - Layout matches PRD: quote, context, footer (date + settings affordance).
  - No scrolling required for typical content (long content gracefully wraps).
- **Test plan**:
  - Resize window/popover → text wraps and remains readable.

### M1.3 Settings surface (skeleton)

- **Scope**: Add Settings UI entry point and placeholder fields.
- **Acceptance criteria**:
  - Settings can be opened from the main UI.
  - Settings contains placeholders for: prompt, API key, mode toggle, auto-launch toggle.

## Milestone 2 — Local Persistence & Daily Freshness

### M2.1 Preferences store

- **Scope**: Persist prompt text, Economy/Premium mode, and auto-launch toggle.
- **Acceptance criteria**:
  - Changes persist across app restarts.
  - Defaults: mode = Economy (or “balanced default”), auto-launch = ON.
- **Test plan**:
  - Set values → restart app → values preserved.

### M2.2 Daily policy (local date key)

- **Scope**: Implement `dateKey` calculation using local calendar day (`YYYY-MM-DD`).
- **Acceptance criteria**:
  - `dateKey` matches local day regardless of time of day.
  - Unit tests cover at least: “same day” and “next day” behavior (using injected calendar/clock).

### M2.3 Quote cache store

- **Scope**: Persist today’s quote/context with `dateKey` and metadata.
- **Acceptance criteria**:
  - If cached dateKey == today, app shows cached content immediately.
  - If cached dateKey != today, cache is treated as stale.
  - If cached dateKey == today but **mode changed** (Economy/Premium), cache is treated as stale and regenerated.
- **Test plan**:
  - Manually simulate cache file contents; confirm UI behavior matches.
  - Unit tests for read/write/overwrite.
  - Unit test: same day but mode change invalidates cache (regenerate / overwrite).

## Milestone 3 — Keychain & Login Item

### M3.1 Keychain wrapper for API key

- **Scope**: Store/retrieve/delete API key in Keychain; never log key.
- **Acceptance criteria**:
  - User can save key, key persists across restarts.
  - User can remove key; subsequent calls treat key as missing.
  - No key is written to disk preferences.
- **Test plan**:
  - Save key → restart → still available.
  - Remove key → verify missing state.

### M3.2 Auto-launch on login (default ON)

- **Scope**: Configure login item via `SMAppService` (preferred).
- **Acceptance criteria**:
  - Default is ON for new installs (subject to platform constraints).
  - User can toggle OFF in Settings and it stays off.
  - App behaves gracefully if OS denies/changes permissions.
- **Test plan**:
  - Toggle on/off → relogin to verify behavior.

## Milestone 4 — OpenAI Integration (Generation)

### M4.1 Prompt template + structured output contract

- **Scope**: Define system prompt and require structured output (`quote`, `context`).
- **Acceptance criteria**:
  - Output is reliably parseable into quote/context.
  - Enforces “original-only”, calm tone, avoids clichés.
- **Notes**:
  - Prefer JSON response format (or equivalent) to avoid brittle parsing.

### M4.2 OpenAI client

- **Scope**: Implement network client with async/await, API key from Keychain, and timeouts.
- **Acceptance criteria**:
  - Requests succeed with valid key.
  - Clear error surfaced for: missing key, invalid key, offline, quota/rate limit.
  - No automatic infinite retries.
- **Test plan**:
  - Mock client for unit tests (fixtures for valid/invalid responses).

### M4.3 Economy / Premium toggle behavior

- **Scope**: Wire mode toggle to client configuration (model + token limits).
- **Acceptance criteria**:
  - Economy/Premium changes take effect on next generation.
  - Strict max output tokens enforced per mode.
  - Mode used is saved into quote metadata.
- **Test plan**:
  - Flip mode → generate → verify metadata and request config.

### M4.4 QuoteService (cache-or-generate)

- **Scope**: Orchestrate: load cache, check dateKey, generate if needed, persist.
- **Acceptance criteria**:
  - Same local day → no network call.
  - New day → generate exactly once and cache.
  - Cancellation works if user closes window mid-request.
- **Test plan**:
  - Unit tests with injected clock + mock OpenAI client.

## Milestone 5 — UX Polish, Error States, and Hardening

### M5.1 Loading and error UI states

- **Scope**: Add calm UI states for loading/error with appropriate actions.
- **Acceptance criteria**:
  - Missing key → “Open Settings” affordance.
  - Transient error → “Retry” button (user initiated).
  - No blocking modals on open.

### M5.2 Content hygiene & formatting

- **Scope**: Ensure quote/context are readable and constrained.
- **Acceptance criteria**:
  - Quote never shows empty/whitespace content.
  - Context limited to desired length (truncate or re-request not in MVP; prefer prompt constraints).
  - Copy-to-clipboard (optional, nice-to-have) does not add clutter.

### M5.3 Observability (minimal)

- **Scope**: Add minimal error logging without leaking sensitive data.
- **Acceptance criteria**:
  - Logs include error category and request correlation id (if used), never API key.

## Milestone 6 — Release Readiness

### M6.1 Manual QA checklist

- **Scope**: Write a short manual test checklist for macOS behaviors.
- **Acceptance criteria**:
  - Covers: first run, key entry/removal, offline behavior, caching, mode toggle, auto-launch toggle.

### M6.2 Packaging (optional for MVP)

- **Scope**: Decide distribution path (local build, notarization later).
- **Acceptance criteria**:
  - App can be run by a developer/tester without special steps beyond building.

## Suggested PR Breakdown (Small Slices)

- PR1: Menu bar shell + main placeholder UI
- PR2: Settings UI + Preferences persistence
- PR3: Daily policy + quote cache store + tests
- PR4: Keychain API key management + UX
- PR5: Auto-launch (login item) + settings toggle
- PR6: OpenAI client + prompt template + parsing + tests
- PR7: QuoteService cache-or-generate + cancellation + UI wiring
- PR8: UX polish (loading/error), hardening, QA checklist

## Definition of Done (MVP)

- With valid API key and prompt set, app shows **one quote per local day**, cached and stable.
- Economy/Premium toggle changes generation behavior and remains cost-bounded.
- Auto-launch default works (or degrades gracefully) and can be disabled.
- No sensitive data is logged; API key is Keychain-only.
- App feels calm and fast: opens to content/loading immediately.
