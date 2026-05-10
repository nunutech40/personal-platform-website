---
name: pbp-modeling-content-data
description: Models reusable content data for profile, projects, posts, products, tags, media, and settings. Use when writing migrations, schemas, seed data, changesets, or query contracts.
---

# Modeling Content Data

## Principle

Model content by what it is, not by how one theme displays it.

Use `pbp-coding-elixir-functionally` with this skill when writing schemas, changesets, context APIs, and query functions.

## When To Use

Use this when:

- creating migrations
- creating Ecto schemas
- adding fields
- writing seed data
- defining relationships
- designing query functions
- changing the data contract used by themes

## Core Entities

```txt
profiles
site_settings
themes
projects
posts
products
media
tags
project_tags
post_tags
product_tags
```

## Workflow

1. Check whether the field belongs to profile, settings, project, post, product, media, tag, or future commerce.
2. Add migration with indexes, foreign keys, and constraints.
3. Add Ecto schema and changeset validation.
4. Add context functions for public and admin use.
5. Keep filtering and data shaping in context/query functions, not LiveViews.
6. Add or update seed data.
7. Add tests for validation and public filtering.

## Modeling Rules

- Slugs are unique per content table.
- Published slugs should not change automatically.
- Tags are shared across content types through join tables.
- `site_settings.active_theme` references the theme key.
- Products use `checkout_url` for MVP payment links.
- Future order/payment tables should not block the content MVP.
- Use Ecto against Supabase Postgres; do not bypass contexts from UI code.
- Prefer explicit context functions such as `list_published_posts/0` over generic Repo access.

## Elixir Data Rules

- Changesets are the boundary for external/admin input.
- Query functions should have intention-revealing names.
- Pure helpers should handle slug normalization and fallback selection.
- Functions that can fail should return changesets or `{:ok, value}` / `{:error, reason}` tuples.

## Done Checklist

- [ ] Migration exists
- [ ] Schema and changeset exist
- [ ] Indexes/constraints exist
- [ ] Context API exists
- [ ] Public query functions hide draft content
- [ ] Seed data updated if needed
- [ ] Tests cover validation and relationships
