---
name: pbp-admin-cms
description: Use when building the admin dashboard, CRUD pages, forms, content management, media management, and theme settings for the Personal Brand Platform.
---

# Admin CMS Skill

## Use This Skill When

Use this skill when implementing:

- admin dashboard
- project CRUD
- post CRUD
- product CRUD
- media manager
- site settings
- theme settings
- admin forms
- admin tables

## Admin Goal

Admin should let the user manage the site without editing database manually.

## Required Admin Pages

```txt
/admin
/admin/projects
/admin/projects/new
/admin/projects/:id/edit
/admin/posts
/admin/posts/new
/admin/posts/:id/edit
/admin/products
/admin/products/new
/admin/products/:id/edit
/admin/media
/admin/site-settings
/admin/themes
```

## Admin Dashboard Must Show

```txt
project count
post count
product count
draft count
active theme
recent updates
quick actions
```

## CRUD Rules

Every CRUD index should have:

```txt
title
status
created/updated date
edit link
preview link
delete/archive action
new button
```

Every form should have:

```txt
save draft
publish/activate
cancel
validation errors
slug field
cover image picker if needed
```

## Project Form Fields

```txt
title
slug
summary
description
problem
solution
outcome
role
tech_stack
cover_media_id
demo_url
github_url
year
status
featured
published_at
```

## Post Form Fields

```txt
title
slug
excerpt
content
cover_media_id
status
tags
published_at
seo_title
seo_description
```

## Product Form Fields

```txt
title
slug
summary
description
product_type
price
currency
checkout_url
cover_media_id
gallery_images
status
featured
```

`checkout_url` should support Midtrans Payment Link for MVP.

## Site Settings Fields

```txt
site_name
headline
subheadline
active_theme
active_homepage_variant
primary_cta_text
primary_cta_url
secondary_cta_text
secondary_cta_url
social_links
featured_project_ids
featured_post_ids
featured_product_ids
```

## Theme Settings

Theme settings must show:

```txt
available themes
current active theme
theme description
theme data contract
preview
save button
```

## Admin Design

Admin can use plain HTML style too.

It should be:

```txt
simple
fast
boring
clear
stable
```

Do not over-design admin.

## Security Rules

- Admin routes must require authentication.
- Public visitors must not access drafts.
- Admin delete should preferably archive rather than hard delete.
- Do not expose service role keys to browser.

## Task Progress

- [ ] Protect admin route
- [ ] Load data through context
- [ ] Build changeset form
- [ ] Validate required fields
- [ ] Handle save/update/delete/archive
- [ ] Redirect or show success message
- [ ] Add tests for CRUD
