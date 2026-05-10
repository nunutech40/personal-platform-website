---
name: pbp-managing-publishing-workflows
description: Manages content lifecycle rules such as drafts, publishing, archive states, slugs, featured items, tags, and public visibility. Use when implementing publish flows for any content type.
---

# Managing Publishing Workflows

## Principle

Admin can see work in progress. Public visitors only see intentionally public content.

Use `pbp-coding-elixir-functionally` with this skill when implementing status transitions, slug generation, or featured fallback logic.

## When To Use

Use this when:

- adding status fields
- implementing draft/publish/archive
- filtering public queries
- generating slugs
- selecting featured content
- adding tags
- building preview behavior

## Workflow

1. Define the status values for the content type.
2. Add public query filters.
3. Add admin query filters.
4. Generate slug from title when blank.
5. Keep published slugs stable.
6. Add featured selection with fallback behavior.
7. Test that drafts do not leak publicly.

## Functional Rules

- Implement slug normalization as a pure function.
- Implement status transition checks as pure functions where possible.
- Keep public visibility filters inside context/query functions.
- Return explicit errors for invalid transitions instead of silently changing status.

## Public Visibility

```txt
projects -> status == published
posts    -> status == published and published_at <= now
products -> status in active or coming_soon
```

## Featured Fallback

```txt
configured featured ids
  else latest published content
```

## Done Checklist

- [ ] Status values documented
- [ ] Public filters implemented
- [ ] Admin can manage drafts
- [ ] Slugs are unique and stable
- [ ] Featured fallback works
- [ ] Lifecycle rules are covered by pure/unit tests where possible
- [ ] Tests prevent draft leakage
