---
name: pbp-building-admin-forms
description: Builds admin CRUD forms, tables, validation states, draft/publish actions, and settings forms. Use when implementing any admin-managed content workflow.
---

# Building Admin Forms

## Principle

Admin UI should be boring, fast, and hard to misuse. Prefer clear tables and changeset-backed forms over clever interfaces.

Use `pbp-coding-elixir-functionally` with this skill when implementing form events, validation, or save flows.

## When To Use

Use this when:

- creating admin index pages
- creating new/edit forms
- adding validation errors
- adding draft/publish/archive actions
- editing site settings or theme settings
- wiring media pickers into forms

## Workflow

1. Protect the route with admin auth.
2. Use context functions and changesets.
3. Render a table for index pages.
4. Render a changeset-backed form for new/edit pages.
5. Support save draft and publish/activate where relevant.
6. Prefer archive over hard delete.
7. Redirect or show success state after save.
8. Add LiveView/form tests.

## Elixir Form Flow

```txt
params
  -> context changeset
  -> validation result
  -> {:ok, record} or {:error, changeset}
  -> LiveView assigns/redirect
```

Do not duplicate changeset validation in LiveView. The LiveView should present errors, not redefine business rules.

## Form Rules

- Generate slug from title only when slug is blank.
- Show validation errors near fields.
- Preserve user input after validation failure.
- Never expose service role keys or secret payment keys to the browser.
- Public previews of drafts must require admin auth.

## Done Checklist

- [ ] Route requires admin
- [ ] Index table exists
- [ ] New/edit form exists
- [ ] Changeset validation shown
- [ ] Draft/publish/archive action works
- [ ] Save flow uses explicit success/error tuples
- [ ] Tests cover success and failure paths
