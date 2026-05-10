---
name: pbp-content-workflow
description: Use when implementing content workflows, publishing logic, slugs, tags, featured content, draft/published states, and public visibility.
---

# Content Workflow Skill

## Use This Skill When

Use this skill when handling:

- projects
- posts
- products
- status fields
- publishing
- drafts
- featured content
- tags
- slugs
- public visibility

## Status Rules

Public pages show only public content.

Use:

```txt
draft
published
archived
```

For products:

```txt
draft
active
coming_soon
archived
```

## Public Visibility

### Projects

Show when:

```txt
status == "published"
```

### Posts

Show when:

```txt
status == "published"
published_at <= now
```

### Products

Show when:

```txt
status in ["active", "coming_soon"]
```

## Drafts

Drafts are visible only in admin.

Admin preview may show drafts if user is authenticated.

## Slug Rules

- Generate from title.
- Slug is unique per table.
- Do not auto-change published slug.
- If slug conflict exists, append suffix.
- Use slug for public detail pages.

## Featured Content

Homepage uses:

```txt
site_settings.featured_project_ids
site_settings.featured_post_ids
site_settings.featured_product_ids
```

Fallback if not configured:

```txt
latest published projects
latest published posts
featured active products
```

## Tags

Tags are shared across projects, posts, and products.

Use join tables:

```txt
project_tags
post_tags
product_tags
```

## Content Quality Rules

Every public item should have:

```txt
title
slug
summary/excerpt
status
published_at or active status
SEO metadata when relevant
```

## Task Progress

- [ ] Add status field
- [ ] Add public query filtering
- [ ] Add slug generation
- [ ] Add tag support
- [ ] Add featured selection
- [ ] Add admin draft/publish actions
- [ ] Test public pages do not leak drafts
