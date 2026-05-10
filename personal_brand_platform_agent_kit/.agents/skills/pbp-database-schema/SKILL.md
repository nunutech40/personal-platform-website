---
name: pbp-database-schema
description: Use when designing or modifying the Supabase Postgres schema, Ecto schemas, migrations, relations, and ERD for the Personal Brand Platform.
---

# Database Schema Skill

## Use This Skill When

Use this skill when the task involves:

- creating migrations
- creating Ecto schemas
- defining relationships
- adding fields
- changing content models
- planning commerce tables
- writing seed data

## MVP Tables

Create these first:

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

## Future Commerce Tables

Do not build these in MVP unless asked:

```txt
customers
orders
order_items
payments
product_files
digital_entitlements
shipping_addresses
shipments
```

## Table Responsibilities

### profiles

Stores the site owner identity.

Fields:

```txt
id
name
headline
bio
avatar_media_id
location
email
x_url
github_url
linkedin_url
created_at
updated_at
```

### site_settings

Controls global site configuration and active theme.

Fields:

```txt
id
site_name
headline
subheadline
active_theme
active_homepage_variant
primary_cta_text
primary_cta_url
secondary_cta_text
secondary_cta_url
social_links JSONB
featured_project_ids UUID[]
featured_post_ids UUID[]
featured_product_ids UUID[]
created_at
updated_at
```

### themes

Stores available themes.

Fields:

```txt
id
key
name
description
status
preview_media_id
created_at
updated_at
```

### projects

Portfolio/work entries.

Fields:

```txt
id
title
slug
summary
description
problem
solution
outcome
role
tech_stack TEXT[]
cover_media_id
demo_url
github_url
year
status
featured
published_at
created_at
updated_at
```

### posts

Writing/blog entries.

Fields:

```txt
id
title
slug
excerpt
content
cover_media_id
status
published_at
reading_time
seo_title
seo_description
created_at
updated_at
```

### products

Product catalog.

Fields:

```txt
id
title
slug
summary
description
product_type
price
currency
checkout_url
cover_media_id
status
featured
created_at
updated_at
```

For MVP, `checkout_url` is used for Midtrans Payment Link.

### media

Shared file/image registry.

Fields:

```txt
id
file_name
file_url
storage_path
mime_type
size_bytes
alt_text
created_at
updated_at
```

### tags

Shared tags.

Fields:

```txt
id
name
slug
created_at
updated_at
```

## Join Tables

```txt
project_tags(project_id, tag_id)
post_tags(post_id, tag_id)
product_tags(product_id, tag_id)
```

Use unique indexes for each pair.

## Status Values

Use atoms/enums at application level.

Recommended status values:

```txt
draft
published
archived
```

Product status:

```txt
draft
active
archived
coming_soon
```

Product type:

```txt
digital
physical
service
experimental
```

## Slug Rules

- Slugs must be unique per table.
- Generate from title.
- Allow manual override.
- Never change slug automatically after publish unless admin explicitly does it.

## Relationship Rules

```txt
projects many-to-many tags
posts many-to-many tags
products many-to-many tags
projects/posts/products optionally belong to media cover
site_settings.active_theme points to themes.key
```

## Commerce Readiness

When adding proper Midtrans integration later:

```txt
orders has many order_items
orders has many payments
customers has many orders
products has many order_items
digital_entitlements belongs to customer, product, order
shipments belongs to order
```

## Migration Checklist

- [ ] Use UUID primary keys if project uses UUID.
- [ ] Add timestamps.
- [ ] Add indexes for slug fields.
- [ ] Add indexes for status and published_at.
- [ ] Add foreign keys for relationships.
- [ ] Add unique indexes for join tables.
- [ ] Add changesets with validation.
- [ ] Add seed data for development.
