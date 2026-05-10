---
name: pbp-phoenix-liveview
description: Use when implementing Phoenix LiveView public pages, admin pages, forms, routes, assigns, and LiveView interactions for the Personal Brand Platform.
---

# Phoenix LiveView Implementation Skill

## Use This Skill When

Use this skill when implementing:

- public LiveViews
- admin LiveViews
- LiveView forms
- route modules
- assigns
- components
- navigation
- validation feedback

## Public LiveViews

Required MVP public LiveViews:

```txt
Public.HomeLive
Public.WorkLive
Public.WorkDetailLive
Public.WritingLive
Public.WritingDetailLive
Public.ProductsLive
Public.ProductDetailLive
Public.AboutLive
Public.NowLive
Public.ContactLive
```

## Admin LiveViews

Required MVP admin LiveViews:

```txt
Admin.DashboardLive
Admin.ProjectIndexLive
Admin.ProjectFormLive
Admin.PostIndexLive
Admin.PostFormLive
Admin.ProductIndexLive
Admin.ProductFormLive
Admin.MediaLive
Admin.SiteSettingsLive
Admin.ThemeSettingsLive
```

## Assign Rules

Every public page should assign:

```elixir
:profile
:site_settings
:active_theme
:page_title
```

Content pages assign their resource:

```elixir
:project
:post
:product
```

Index pages assign lists:

```elixir
:projects
:posts
:products
:tags
```

## Public Page Loading

Use context functions, not direct Repo calls in LiveViews.

Good:

```elixir
projects = Portfolio.list_published_projects()
```

Bad:

```elixir
Repo.all(Project)
```

## Admin Form Rules

Admin forms should:

- use changesets
- show validation errors
- support draft/publish
- redirect after successful save
- preserve form state after errors
- generate slug from title only when slug is blank

## Navigation Rules

Every public theme must expose links to:

```txt
Home
Work
Writing
Products
About
Now
```

Homepage must also include:

```txt
View all work
View all writing
View all products
```

## LiveView Component Rules

Use components for repeated UI:

```txt
public header
footer
old web section
old web link list
admin table
admin form input
media picker
status badge
theme preview
```

## Error Handling

For slug detail pages:

- if published item is not found, return 404
- draft content should not be public
- admin preview may show draft content only to admin

## Task Progress

- [ ] Add route
- [ ] Create LiveView module
- [ ] Load data through context
- [ ] Assign page title
- [ ] Render with selected theme/component
- [ ] Add tests
- [ ] Verify mobile layout
