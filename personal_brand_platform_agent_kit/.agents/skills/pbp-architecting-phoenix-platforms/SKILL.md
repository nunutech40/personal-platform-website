---
name: pbp-architecting-phoenix-platforms
description: Structures Phoenix-first applications with clear contexts, route boundaries, and MVP scope. Use when creating the Phoenix project, adding modules, deciding ownership, or preventing frontend/backend over-splitting.
---

# Architecting Phoenix Platforms

## Principle

Use Phoenix LiveView as the MVP monolith. Keep business logic in contexts, rendering in LiveViews/components, and infrastructure behind explicit modules.

Use `pbp-coding-elixir-functionally` together with this skill when architecture decisions affect context APIs, side-effect boundaries, or domain rules.

## When To Use

Use this when:

- creating the Phoenix app
- adding a new context
- deciding where a module belongs
- adding route scopes
- moving prototype code into Phoenix
- reviewing whether a task is MVP or future

## Workflow

1. Identify the domain: accounts, identity, portfolio, content, catalog, media, settings, themes, or commerce.
2. Define the public context API before implementing UI.
3. Put business rules in the context, not in LiveView.
4. Put rendering in LiveView/components/theme modules.
5. Put Supabase Storage, Midtrans, and other external calls behind integration modules.
6. Keep public routes and admin routes separate.
7. Keep future commerce planned but out of MVP unless requested.
8. Update architecture docs when boundaries change.

## Architecture Checklist

```txt
Does this belong in a context?
Can this be a pure function?
Where is the side effect?
What is the explicit success/error shape?
Does this keep data separate from presentation?
```

## Prototype Porting Map

```txt
src/app.js data        -> seeds + contexts + LiveView assigns
styles.css            -> assets/css/app.css + assets/css/themes/*
public renderers      -> lib/*_web/live/public/*
admin renderers       -> lib/*_web/live/admin/*
theme switcher        -> Settings context + Themes registry
```

## Done Checklist

- [ ] Context boundary is named
- [ ] Context API is explicit
- [ ] LiveView does not call Repo directly
- [ ] External side effects are wrapped
- [ ] Public/admin route ownership is clear
- [ ] MVP/future scope is documented
- [ ] Data is not coupled to a theme
