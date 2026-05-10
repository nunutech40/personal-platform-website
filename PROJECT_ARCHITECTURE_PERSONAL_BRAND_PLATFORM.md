# Project Architecture — Personal Brand Platform

## Current Repository State

Status per 2026-05-10:

```txt
The repository currently contains a runnable static dummy UI prototype.
The target architecture is still Phoenix LiveView + Supabase.
```

Current prototype files:

```txt
index.html
styles.css
src/app.js
server.mjs
package.json
README.md
```

Current prototype responsibilities:

```txt
index.html  -> browser entry point
styles.css  -> old_web_classic styling and placeholder future theme styles
src/app.js  -> dummy data contract, simple router, page renderers, admin mock, theme switching
server.mjs  -> local static server and SPA fallback
```

This prototype should be treated as a UI/data-contract reference, not as the final application architecture.

When Phoenix is created, port the prototype into:

```txt
src/app.js data        -> seeds + contexts + LiveView assigns
styles.css            -> assets/css/app.css + assets/css/themes/*
public route renderers -> lib/personal_brand_web/live/public/*
admin mock renderers   -> lib/personal_brand_web/live/admin/*
theme switcher         -> PersonalBrandWeb.Themes + Settings context
```

## 0. Purpose

Build a personal brand platform for Nunu Nugraha that works as:

1. Portfolio / work showcase
2. Writing / blog
3. Product catalog for digital and physical products
4. Admin-managed content system
5. Themeable public website where the same data can be rendered with different visual themes

The first public theme is:

```txt
old_web_classic
```

A retro “old HTML” personal website aesthetic: serif fonts, blue links, plain layout, thin rules, minimal CSS, human, simple, readable.

---

## 1. Recommended Architecture

Use a simple Phoenix-first architecture.

```txt
Browser
  ↓
Phoenix LiveView App
  ├── Public Website
  ├── Admin Dashboard
  ├── Theme Renderer
  ├── Content Management
  └── Commerce Preparation
  ↓
Supabase Postgres
  ↓
Supabase Storage
```

### Why this architecture

The user cares most about Elixir, simplicity, and future extensibility.

So the best architecture is:

```txt
Phoenix LiveView monolith
```

Not separate frontend + backend for MVP.

This keeps the project simple:

```txt
One Elixir app
One routing system
One auth/admin system
One database layer
One deployment unit
```

Supabase is used mainly as:

```txt
Postgres database
File/image storage
optional auth later
```

Phoenix owns the product logic.

---

## 2. High-Level System Diagram

```txt
┌─────────────────────────────────────────────┐
│ Browser                                     │
│ Public Visitor / Admin                      │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│ Phoenix LiveView App                        │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Public Site                             │ │
│ │ / /work /writing /products /about /now  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Admin Dashboard                         │ │
│ │ /admin/projects/posts/products/settings │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Theme System                            │ │
│ │ old_web_classic / future themes         │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Contexts                                │ │
│ │ Identity / Content / Catalog / Settings │ │
│ │ Commerce / Media                        │ │
│ └─────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│ Supabase                                    │
│ Postgres + Storage                          │
└─────────────────────────────────────────────┘
```

---

## 3. Phoenix Contexts

Use Phoenix contexts to avoid a messy codebase.

```txt
lib/personal_brand/
  accounts/
  identity/
  content/
  catalog/
  media/
  settings/
  themes/
  commerce/
```

### Context responsibility

```txt
Accounts
- admin authentication
- users/admins
- sessions

Identity
- personal profile
- social links
- public bio

Content
- posts/writing
- tags
- post_tags

Portfolio
- projects/work
- project_tags
- case study fields

Catalog
- products
- product tags
- product metadata
- checkout_url for Midtrans Payment Link

Media
- media records
- Supabase Storage integration
- image/file metadata

Settings
- site_settings
- active_theme
- featured content ids
- homepage copy

Themes
- theme registry
- theme data contract
- theme renderer

Commerce
- future orders
- payments
- Midtrans proper integration
- webhook handling
- digital entitlement
- shipping
```

---

## 4. Suggested Folder Structure

Current repo note:

```txt
The current static prototype does not use this Phoenix folder structure yet.
Use the structure below for the next implementation phase.
```

```txt
personal_brand_platform/
├── assets/
│   ├── css/
│   │   ├── app.css
│   │   └── themes/
│   │       ├── old_web_classic.css
│   │       ├── simple.css
│   │       ├── us_builder.css
│   │       └── premium_dark.css
│   └── js/
│       └── app.js
│
├── config/
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── runtime.exs
│
├── lib/
│   ├── personal_brand/
│   │   ├── accounts/
│   │   ├── identity/
│   │   ├── portfolio/
│   │   ├── content/
│   │   ├── catalog/
│   │   ├── media/
│   │   ├── settings/
│   │   ├── themes/
│   │   ├── commerce/
│   │   └── repo.ex
│   │
│   ├── personal_brand_web/
│   │   ├── components/
│   │   │   ├── core_components.ex
│   │   │   ├── admin_components.ex
│   │   │   └── old_web_components.ex
│   │   │
│   │   ├── controllers/
│   │   ├── live/
│   │   │   ├── public/
│   │   │   │   ├── home_live.ex
│   │   │   │   ├── work_live.ex
│   │   │   │   ├── work_detail_live.ex
│   │   │   │   ├── writing_live.ex
│   │   │   │   ├── writing_detail_live.ex
│   │   │   │   ├── products_live.ex
│   │   │   │   ├── product_detail_live.ex
│   │   │   │   ├── about_live.ex
│   │   │   │   └── now_live.ex
│   │   │   │
│   │   │   └── admin/
│   │   │       ├── dashboard_live.ex
│   │   │       ├── project_index_live.ex
│   │   │       ├── project_form_live.ex
│   │   │       ├── post_index_live.ex
│   │   │       ├── post_form_live.ex
│   │   │       ├── product_index_live.ex
│   │   │       ├── product_form_live.ex
│   │   │       ├── media_live.ex
│   │   │       ├── site_settings_live.ex
│   │   │       └── theme_settings_live.ex
│   │   │
│   │   ├── themes/
│   │   │   ├── theme_registry.ex
│   │   │   ├── theme_contract.ex
│   │   │   └── old_web_classic/
│   │   │       ├── home.ex
│   │   │       ├── work.ex
│   │   │       ├── writing.ex
│   │   │       ├── products.ex
│   │   │       ├── about.ex
│   │   │       └── now.ex
│   │   │
│   │   ├── router.ex
│   │   └── endpoint.ex
│   │
│   └── personal_brand_web.ex
│
├── priv/
│   ├── repo/
│   │   ├── migrations/
│   │   └── seeds.exs
│   └── static/
│
├── test/
│   ├── personal_brand/
│   └── personal_brand_web/
│
├── .agents/
│   └── skills/
│
├── mix.exs
└── README.md
```

---

## 5. Route Architecture

### Public routes

```elixir
scope "/", PersonalBrandWeb do
  pipe_through :browser

  live "/", Public.HomeLive, :index
  live "/work", Public.WorkLive, :index
  live "/work/:slug", Public.WorkDetailLive, :show

  live "/writing", Public.WritingLive, :index
  live "/writing/:slug", Public.WritingDetailLive, :show

  live "/products", Public.ProductsLive, :index
  live "/products/:slug", Public.ProductDetailLive, :show

  live "/about", Public.AboutLive, :index
  live "/now", Public.NowLive, :index
  live "/contact", Public.ContactLive, :index
end
```

### Admin routes

```elixir
scope "/admin", PersonalBrandWeb.Admin do
  pipe_through [:browser, :require_admin]

  live "/", DashboardLive, :index

  live "/projects", ProjectIndexLive, :index
  live "/projects/new", ProjectFormLive, :new
  live "/projects/:id/edit", ProjectFormLive, :edit

  live "/posts", PostIndexLive, :index
  live "/posts/new", PostFormLive, :new
  live "/posts/:id/edit", PostFormLive, :edit

  live "/products", ProductIndexLive, :index
  live "/products/new", ProductFormLive, :new
  live "/products/:id/edit", ProductFormLive, :edit

  live "/media", MediaLive, :index
  live "/site-settings", SiteSettingsLive, :edit
  live "/themes", ThemeSettingsLive, :index
end
```

### Future commerce routes

Do not build in MVP unless explicitly requested.

```elixir
scope "/", PersonalBrandWeb do
  pipe_through :browser

  live "/checkout/:product_slug", Commerce.CheckoutLive, :new
  live "/payment/success", Commerce.PaymentSuccessLive, :index
  live "/payment/pending", Commerce.PaymentPendingLive, :index
  live "/payment/failed", Commerce.PaymentFailedLive, :index
  live "/download/:token", Commerce.DownloadLive, :show
end

scope "/webhooks", PersonalBrandWeb do
  pipe_through :api

  post "/midtrans", WebhookController, :midtrans
end
```

---

## 6. Database Architecture

### Core MVP tables

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

### Commerce-ready future tables

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

### MVP-first approach

Build these first:

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

Add commerce tables later when moving from Midtrans Payment Link to proper Midtrans integration.

---

## 7. Database Relations

```txt
profiles
  └── one public profile for the site owner

site_settings
  ├── active_theme → themes.key
  ├── featured_project_ids
  ├── featured_post_ids
  └── featured_product_ids

themes
  └── stores available theme keys and metadata

projects
  ├── many-to-many tags via project_tags
  └── optional cover media

posts
  ├── many-to-many tags via post_tags
  └── optional cover media

products
  ├── many-to-many tags via product_tags
  ├── optional cover media
  ├── checkout_url for Midtrans Payment Link
  └── later connects to order_items

media
  └── shared image/file registry

future:
customers
  └── orders

orders
  ├── order_items
  ├── payments
  ├── shipping_addresses
  └── shipments

digital_entitlements
  ├── customer
  ├── product
  └── order
```

---

## 8. Theme System Architecture

### Core rule

```txt
Data must not be coupled to design.
```

The same data must render in different themes.

### Theme contract

Every theme must accept the same shape:

```elixir
%{
  profile: profile,
  site_settings: settings,
  projects: featured_projects,
  posts: featured_posts,
  products: featured_products,
  tags: tags,
  media: media
}
```

### Theme registry concept

```elixir
defmodule PersonalBrandWeb.Themes.ThemeRegistry do
  @themes %{
    "old_web_classic" => PersonalBrandWeb.Themes.OldWebClassic,
    "simple" => PersonalBrandWeb.Themes.Simple,
    "us_builder" => PersonalBrandWeb.Themes.USBuilder,
    "premium_dark" => PersonalBrandWeb.Themes.PremiumDark
  }

  def get_theme(key), do: Map.fetch(@themes, key)
end
```

### Rendering flow

```txt
User opens homepage
↓
HomeLive loads site_settings
↓
Read active_theme
↓
ThemeRegistry resolves theme module
↓
Load data contract
↓
Theme module renders homepage
```

### MVP theme

Only implement:

```txt
old_web_classic
```

Future themes should be easy to add.

---

## 9. Public Page Architecture

### Homepage

Must include:

```txt
global navigation
social links
intro/hero
start here links
featured work
recent writing
featured products
now section
footer
```

Important UX rule:

The homepage must always provide clear paths to:

```txt
/work
/writing
/products
/about
/now
```

### Work list

```txt
title
intro
tag filters
project list
project thumbnail or image
footer
```

### Work detail

```txt
breadcrumb
title
subtitle
role
stack
year
status
overview
problem
solution
outcome
links
gallery
```

### Writing list

```txt
title
intro
RSS link
tag filters
post list
popular tags
footer
```

### Writing detail

```txt
breadcrumb
title
metadata
article content
related posts
footer
```

### Products list

```txt
title
intro
digital products
physical/experimental products
price
checkout link
footer
```

### Product detail

```txt
breadcrumb
title
subtitle
price
type
format
description
what is included
preview
FAQ
Buy Now link
```

### About

```txt
bio
what I do
tools I use
what I care about
now
social links
```

### Now

```txt
currently building
currently learning
current focus
recent updates
```

---

## 10. Admin Page Architecture

### Admin dashboard

```txt
summary counts
recent updates
draft content
quick actions
active theme
```

### Admin projects

CRUD fields:

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
cover_image_id
demo_url
github_url
status
featured
published_at
```

### Admin posts

CRUD fields:

```txt
title
slug
excerpt
content
cover_image_id
status
tags
published_at
seo_title
seo_description
```

### Admin products

CRUD fields:

```txt
title
slug
summary
description
product_type
price
currency
checkout_url
cover_image_id
gallery_images
status
featured
```

For MVP, `checkout_url` is where Midtrans Payment Link goes.

### Admin site settings

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

### Admin themes

```txt
available themes
active theme
theme preview
theme data contract note
save theme button
```

---

## 11. Commerce Architecture

### MVP commerce

Use manual Midtrans Payment Link.

```txt
Product page
↓
Buy Now
↓
products.checkout_url
↓
Midtrans hosted payment page
↓
manual fulfillment
```

### Why this is enough for MVP

The project focus is portfolio first.

MVP only needs to show that products exist and can be purchased.

### Future commerce proper

Later upgrade to:

```txt
checkout page
orders
payments
Midtrans Snap/API
Midtrans webhook
digital entitlement
shipping flow
admin order management
```

Do not build the full commerce system in MVP unless specifically requested.

---

## 12. Deployment Architecture

### Simple deployment

```txt
Phoenix app → Fly.io / Render / Railway
Supabase → hosted Postgres + Storage
Assets → Phoenix static assets
```

### Environment variables

```txt
DATABASE_URL
SECRET_KEY_BASE
PHX_HOST
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
SUPABASE_STORAGE_BUCKET
MIDTRANS_SERVER_KEY
MIDTRANS_CLIENT_KEY
MIDTRANS_ENV
```

For MVP, Midtrans keys may not be needed if only using manually created Payment Links.

---

## 13. Testing Strategy

### Unit tests

```txt
contexts
schema changesets
theme registry
slug generation
content queries
```

### LiveView tests

```txt
homepage renders active theme
work list renders projects
post detail renders published post
product detail renders checkout link
admin CRUD creates content
theme setting updates active_theme
```

### Manual QA

```txt
homepage has navigation
all public pages have footer
mobile layout readable
admin forms save correctly
Buy Now link opens checkout_url
```

---

## 14. MVP Build Order

```txt
1. Phoenix project setup
2. Database connection
3. Core schema migrations
4. Seed data
5. Public old_web_classic layout
6. Public pages
7. Admin auth
8. Admin CRUD
9. Site settings
10. Theme switching
11. Product checkout_url support
12. Media upload
13. SEO/RSS polish
14. Responsive polish
```

---

## 15. Non-Goals for MVP

Do not build these first:

```txt
cart
customer login
automatic payment status
Midtrans webhook
shipping dashboard
download entitlement
drag-and-drop page builder
visual theme editor
multi-language
comment system
newsletter
advanced analytics
```

---

## 16. Success Criteria

The architecture is successful when:

```txt
content can be edited from admin
public site renders from database
old_web_classic theme works
active theme can be changed from DB
products have checkout links
new themes can be added without changing content tables
future Midtrans proper flow can be added without rewriting product catalog
```
