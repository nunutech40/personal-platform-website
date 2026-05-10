---
name: pbp-building-admin-forms
description: Builds admin CRUD forms, tables, validation states, draft/publish actions, and settings forms. Use when implementing any admin-managed content workflow.
---

# Building Admin Forms

## Principle

Admin UI should be boring, fast, and hard to misuse. Prefer clear tables and changeset-backed forms over clever interfaces.

For standard CRUD resources, use `pbp-building-admin-backpex-resources` first. Use this skill for custom admin workflows that need more than default Backpex forms, such as a Markdown post editor, media picker, preview action, or publish/archive workflow.

Use `pbp-coding-elixir-functionally` with this skill when implementing form events, validation, or save flows.

Use `docs/standards/CODING_AND_TESTING_STANDARDS.md` for minimum admin form tests.

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
3. Use Backpex LiveResource for normal index/new/edit/delete screens.
4. Render a custom changeset-backed form only when Backpex is not enough.
5. Support save draft and publish/activate where relevant.
6. Prefer archive over hard delete.
7. Redirect or show success state after save.
8. Add LiveView/form tests.

## Admin UI Library Rules

- Backpex owns standard CRUD tables/forms; do not recreate those screens manually.
- The admin layout is `PersonalBrandWeb.Layouts.admin`; it must remain separate from public layouts.
- The admin shell should look like a standard CMS: left sidebar, topbar breadcrumb/actions, light content surface, readable tables.
- Use daisyUI/Tailwind classes for custom controls, but keep color fixes scoped under `.admin-shell`.
- Never edit `deps/backpex` templates for app-specific styling. Use resource callbacks, layout slots, or app CSS overrides.
- Verify contrast manually after table/form changes. Text inside Backpex tables must not render dark-on-dark or light-on-light.

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
- For posts, MVP editor direction is Markdown-first with preview, SEO fields, status, and publish controls.
- For resource forms, prefer a main content area plus a right settings panel when custom layout is justified.

## Done Checklist

- [ ] Route requires admin
- [ ] Index table exists
- [ ] New/edit form exists
- [ ] Changeset validation shown
- [ ] Draft/publish/archive action works
- [ ] Save flow uses explicit success/error tuples
- [ ] Tests cover success and failure paths
- [ ] Auth boundary is tested for protected admin routes
- [ ] Admin table/form readability checked in browser
- [ ] No public old-web CSS leaks into admin UI
