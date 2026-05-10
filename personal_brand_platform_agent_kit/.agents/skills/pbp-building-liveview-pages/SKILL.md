---
name: pbp-building-liveview-pages
description: Builds Phoenix LiveView pages with routing, assigns, loading states, slug detail pages, and reusable components. Use when implementing public pages or moving static prototype views into LiveView.
---

# Building LiveView Pages

## Principle

LiveViews load data through contexts, assign a small page contract, and render through shared components or theme modules.

Use `pbp-coding-elixir-functionally` with this skill when adding event handlers, context calls, or state transformations.

Use `docs/standards/CODING_AND_TESTING_STANDARDS.md` for minimum LiveView route/detail tests.

## When To Use

Use this when:

- adding public pages
- adding admin pages
- implementing slug detail routes
- moving static prototype pages to LiveView
- adding shared page components

## Workflow

1. Add route in the correct public/admin scope.
2. Create the LiveView module.
3. Load data through context functions, never direct Repo calls.
4. Assign `:page_title`, `:profile`, `:site_settings`, and page-specific data.
5. Render using components or theme module.
6. Handle not-found and draft visibility rules.
7. Add LiveView tests.

## Elixir/Phoenix Rules

- LiveView orchestrates state; it does not own business rules.
- `handle_event` should call context functions and handle `{:ok, result}` / `{:error, changeset}`.
- Build assigns from small pure helper functions when shaping page data.
- Components and theme modules receive assigns only; they do not fetch data.

## Route Pattern

```txt
index pages   -> list public content
detail pages  -> load by slug
admin pages   -> require admin auth
```

## Visibility Rules

- Public project/post detail pages must only show published content.
- Public product pages show active or coming soon products.
- Draft preview belongs behind admin auth.

## Done Checklist

- [ ] Route added
- [ ] LiveView created
- [ ] Context query used
- [ ] Event handlers delegate business logic to contexts
- [ ] 404/draft behavior handled
- [ ] Navigation remains visible
- [ ] Test added
