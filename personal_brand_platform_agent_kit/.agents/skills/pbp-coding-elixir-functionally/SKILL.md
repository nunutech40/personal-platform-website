---
name: pbp-coding-elixir-functionally
description: Applies Elixir/Phoenix functional programming style: pure transformations, explicit context APIs, changesets, pipelines, pattern matching, result tuples, and side-effect boundaries. Use before implementing backend logic, contexts, Ecto schemas, LiveViews, Supabase integrations, or commerce flows.
---

# Coding Elixir Functionally

## Principle

Elixir code should be data-in, data-out. Keep transformations pure where possible, make side effects explicit, and let contexts own business rules.

Project-wide code and test standards live in `docs/standards/CODING_AND_TESTING_STANDARDS.md`.

## When To Use

Use this when:

- writing Phoenix contexts
- writing Ecto schemas and changesets
- writing query functions
- handling uploads or external APIs
- implementing LiveView events
- adding commerce/payment logic
- refactoring duplicated logic

## Functional Design Rules

- Prefer small functions that transform data.
- Prefer pipelines for readable transformation steps.
- Prefer pattern matching over nested conditionals.
- Return `{:ok, value}` or `{:error, reason}` from operations that can fail.
- Keep validation in changesets or dedicated pure functions.
- Keep database, storage, network, and payment calls at the edge.
- Do not hide side effects inside theme or component modules.
- Do not put business rules directly in LiveView event handlers.

## Phoenix Boundary Rules

```txt
LiveView      -> orchestrates UI state and calls context APIs
Context       -> owns business rules and persistence orchestration
Schema        -> defines fields, relations, and changesets
Component     -> renders assigns, no data fetching
Theme module  -> renders the shared data contract, no database calls
Integration   -> wraps Supabase/Midtrans/API side effects
```

## Ecto Rules

- Use changesets for casting and validation.
- Use constraints in migrations and changesets.
- Use query functions with intention-revealing names.
- Avoid leaking raw Ecto query composition into LiveViews.
- Keep public visibility filters in context/query functions.

## Supabase Integration Rules

- Treat Supabase as Postgres + Storage infrastructure.
- Use Ecto for Postgres data access.
- Wrap Storage operations in a media/integration module.
- Keep Supabase service role keys server-side only.
- Return explicit success/error tuples from storage operations.

## Review Checklist

- [ ] Business rules live in contexts or pure functions
- [ ] Side effects are at clear boundaries
- [ ] LiveViews do not call Repo or external APIs directly
- [ ] Theme/components do not query data
- [ ] Failure paths return explicit tuples or changeset errors
- [ ] Tests cover pure rules and side-effect orchestration
