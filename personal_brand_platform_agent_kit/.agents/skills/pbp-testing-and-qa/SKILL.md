---
name: pbp-testing-and-qa
description: Verifies Phoenix contexts, LiveViews, theme rendering, responsive behavior, accessibility, and commerce-link behavior. Use before finishing any implementation task or when reviewing regressions.
---

# Testing And QA

## Principle

Every shipped slice should prove both behavior and navigation. Visual simplicity is not an excuse for broken flows.

Use this together with `pbp-coding-elixir-functionally` to verify both pure rules and side-effect orchestration.

Detailed test policy lives in `docs/standards/CODING_AND_TESTING_STANDARDS.md`.

## When To Use

Use this when:

- finishing a feature
- reviewing a change
- adding public routes
- adding admin forms
- changing themes
- changing content visibility
- adding checkout links

## Test Layers

```txt
context tests  -> schemas, changesets, query rules
LiveView tests -> routes, assigns, forms, redirects
unit tests     -> pure slug/status/theme resolver functions
integration   -> storage/Midtrans wrappers with mocked boundaries
theme QA       -> navigation, readability, responsive layout
manual QA      -> click through public/admin flows
```

## Required Checks

- Homepage links to Work, Writing, Products, About, and Now.
- Detail pages work by slug.
- Drafts do not appear publicly.
- Product Buy Now uses `checkout_url`.
- Invalid theme key falls back safely.
- Mobile layout has no horizontal overflow.
- Admin forms show validation errors.
- Context functions return expected success/error shapes.
- Side-effect wrappers are tested without leaking secrets.

## Done Checklist

- [ ] Relevant automated tests pass
- [ ] Pure function tests cover core rules
- [ ] Backend slices include unit/context tests
- [ ] LiveView/admin behavior changes include LiveView tests
- [ ] Public route manually checked
- [ ] Admin path manually checked if touched
- [ ] Theme switching checked if touched
- [ ] Mobile/responsive checked if UI changed
- [ ] Docs updated if behavior changed
