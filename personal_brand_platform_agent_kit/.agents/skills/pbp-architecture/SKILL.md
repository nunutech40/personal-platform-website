---
name: pbp-architecture
description: Use when creating, reviewing, or changing the project architecture for the Personal Brand Platform. Ensures the project stays Phoenix-first, MVP-first, themeable, and commerce-ready without overengineering.
---

# Personal Brand Platform Architecture Skill

## Use This Skill When

Use this skill when the task involves:

- deciding project structure
- creating Phoenix contexts
- adding new modules
- adding routes
- changing database boundaries
- deciding whether something belongs in MVP
- planning future Midtrans commerce
- preventing scope creep

## Core Architecture Rule

Build a Phoenix LiveView monolith first.

```txt
Phoenix LiveView app
├── Public Website
├── Admin Dashboard
├── Theme System
├── Content Management
└── Future Commerce
```

Do not split frontend and backend unless the user explicitly asks.

## Current Prototype Note

The project root may contain a static dummy UI prototype:

```txt
index.html
styles.css
src/app.js
server.mjs
package.json
```

Treat this as a temporary UI/data-contract reference. It is useful for validating routes, old_web_classic styling, dummy admin shape, theme switching behavior, and product `checkout_url` flow.

Do not mistake it for the final architecture. When implementing the real MVP, port the prototype into Phoenix LiveView, contexts, seed data, and theme modules.

## Stack

```txt
Language: Elixir
Framework: Phoenix + LiveView
Database: Supabase Postgres
Storage: Supabase Storage
Styling: Tailwind + small theme CSS files
MVP Payment: Midtrans Payment Link via products.checkout_url
Future Payment: Midtrans API/Snap + webhook
```

## Context Boundaries

Use contexts:

```txt
Accounts
Identity
Portfolio
Content
Catalog
Media
Settings
Themes
Commerce
```

### Accounts

Admin users, login, sessions, authorization.

### Identity

The site owner profile: name, headline, bio, social links.

### Portfolio

Projects, work list, project details, case studies.

### Content

Writing/blog posts, tags, published/draft status.

### Catalog

Products, product listing, checkout_url, product metadata.

### Media

Supabase Storage wrapper, uploaded files, media records.

### Settings

site_settings, active theme, featured IDs, homepage copy.

### Themes

Theme registry and theme data contract.

### Commerce

Future orders, payments, Midtrans webhook, shipping, digital entitlements.

## Hard Rules

1. Do not couple content data to a specific theme.
2. Do not build full ecommerce in MVP.
3. Do not build cart/customer accounts unless explicitly requested.
4. Do not add a separate JS frontend unless explicitly requested.
5. Public pages should render from database content.
6. Admin dashboard should manage content without direct DB edits.
7. Product pages should support `checkout_url` for Midtrans Payment Link first.
8. Future commerce tables may be planned, but should not block MVP.

## Recommended Folder Structure

```txt
lib/personal_brand/
  accounts/
  identity/
  portfolio/
  content/
  catalog/
  media/
  settings/
  themes/
  commerce/

lib/personal_brand_web/
  live/public/
  live/admin/
  components/
  themes/
```

## Decision Checklist

Before implementing a feature, answer:

```txt
Is this needed for portfolio MVP?
Is it needed for admin CRUD?
Is it needed for theme switching?
Can it be added later without rewriting?
Does it keep data separate from presentation?
```

If the answer is no for MVP, document it as future work.

## Task Progress

When completing architecture tasks:

- [ ] Identify the context
- [ ] Check if it is MVP or future
- [ ] Add modules in the correct context
- [ ] Keep data and theme separate
- [ ] Avoid unnecessary frontend/backend split
- [ ] Update docs if architecture changes
