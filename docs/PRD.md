# Wise Companion — Product Requirements Document (PRD)

- **Product name (working)**: Wise Companion
- **Platform**: macOS (Apple Silicon + Intel)
- **Type**: Personal productivity / reflection (calm morning ritual)
- **App form factor**: **Menu bar app (popover anchored to the status item)**

## Problem Statement

Knowledge workers often start the day immediately in reactive mode (Slack, email, Jira, news), without grounding, intention, or reflection. There is no lightweight, calm ritual that appears at the right moment (morning), delivers meaningful insight, and adapts to the user’s current mindset.

## Product Vision

Wise Companion is a quiet macOS app that greets you each morning with:

- A thoughtful quote
- Brief context / interpretation
- Aligned with what you want to reflect on today

It is **not** noisy, gamified, addictive, or feed-based. It is a daily intellectual and emotional anchor.

## Target User

### Primary user

- Knowledge worker / builder / manager
- Starts day on a MacBook
- Values reflection, principles, long-term thinking

### User characteristics / assumptions

- Comfortable providing their own OpenAI API key
- Wants quality over quantity
- Prefers calm UX (not notifications, not feeds)

## Core User Journey (MVP)

### Morning First Open Flow

- User opens Mac in the morning
- Wise Companion launches (auto-launch on login **default**) and is available via the menu bar
- Clicking the menu bar icon opens a **popover** showing:
  - A generated quote
  - Supporting context / explanation
- User reads → closes window/popover → starts day

**No scrolling. No choices. No distraction.**

## MVP Features

### 1) Daily Quote Generation (Core)

- Generate **1 quote per local calendar day**
- Powered by OpenAI API

#### Inputs

- User-defined prompt (themes/mindset guidance)
- System-level tone preset (internal)
- Quality constraints (below)

#### Outputs

- **Quote**: 1–3 sentences
- **Context**: 2–4 sentences explaining meaning + application today

#### Content constraints

- Calm, grounded tone
- Avoid clichés
- **Original-only by default** (avoid famous quotes and attribution in MVP)
- Prefer original phrasing
- Non-repetitive (best-effort)

### 2) User Prompt Configuration

User can provide guidance such as:

- Topics (e.g., leadership, focus, family, patience)
- Tone (calm, direct, poetic, philosophical)
- Perspective (stoic, modern, Eastern, Western, practical)

Stored locally.

Example prompt:

> “Give me a calm, practical quote about leadership and patience, suitable for a morning reflection.”

### 3) OpenAI API Key Management

- User pastes their own OpenAI API key
- Stored securely in macOS Keychain
- App never logs or transmits the key elsewhere

### 4) Daily Freshness Logic (Caching)

- Generate only once per day
- Cache result locally
- Reopening app the same local day shows the same quote/context

#### Definition of “day”

- Use the user’s **local calendar day** (store a local `YYYY-MM-DD` alongside the cached quote)

### 5) Model Selection & Cost Controls (MVP)

- Default to a **balanced** model
- Keep output short and enforce **strict token limits**
- Expose a simple **Economy / Premium** toggle (not a full model list)
- Limit retries to avoid accidental spend

## Non-Goals (Out of Scope for MVP)

- Social sharing
- Quote feeds or infinite scroll
- Push notifications
- Streaks, gamification, analytics
- Multiple quotes per day

This restraint is intentional.

## UX & UI Principles

### Design philosophy

- Minimal
- Calm
- Fast
- Zero cognitive load

### UI layout (initial)

```text
“Quote text here”
— (optional attribution line; not used in MVP default policy)

Context / explanation paragraph

[Small footer: date | settings icon]
```

### Interaction rules

- App opens directly to quote
- No modal popups
- Settings hidden behind subtle icon

## Technical Requirements

- **Platform**: macOS
- **UI**: Swift / SwiftUI preferred
- **API**: OpenAI Chat Completions or Responses API
- **Storage (local)**:
  - Prompt
  - Last generated quote + context
  - Last generated local date (`YYYY-MM-DD`)
- **Secrets**: API key via Keychain

## Prompting Strategy (Initial)

### System prompt (example)

You are a wise, calm companion. Generate one original quote suitable for morning reflection, followed by a short explanation of how it can be applied today.

### User prompt

`{User-defined prompt}`

## Success Criteria (MVP)

- App UI opens in under **1 second**
- Quote consistently feels “worth reading” (qualitative)
- User keeps app installed after **1 week**
- Becomes part of morning routine (qualitative)

## Future Extensions (Not MVP)

- Quote history (journal-like)
- Multiple modes (Work / Life / Family)
- Time-based triggers
- Offline fallback quotes
- Reflection journaling
- Voice read-out
- iOS companion

## Open Questions (Next Iteration)

- Menu bar presentation: popover vs small window (readability, copy, accessibility)
- Onboarding: when/how to ask for API key + prompt with minimal friction
- Premium toggle definition: what changes besides model (tone, length caps, temperature, etc.)
