# Project Architecture — Personal Brand Platform

## Current Repository State

Status per 2026-05-10:

```txt
The repository currently contains a runnable static dummy UI prototype.
The target architecture is still Phoenix LiveView + PostgreSQL.
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
PostgreSQL
  ↓
Media storage adapter
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

PostgreSQL is used as:

```txt
primary relational database
Ecto persistence layer
```

Phoenix owns the product logic.

Media files are handled through a storage adapter owned by the Phoenix app:

```txt
MVP: local disk storage
Future: S3-compatible object storage if needed
```

### Why PostgreSQL Directly

Use PostgreSQL directly for the final MVP.

Reasoning:

```txt
- Ecto maps naturally to PostgreSQL without extra platform assumptions.
- Phoenix keeps ownership of business logic, auth, admin flows, and validation.
- Local development is simpler with local PostgreSQL or Docker PostgreSQL.
- Media upload can start with local disk storage and later move behind an S3-compatible adapter.
- The project avoids platform-specific auth, RLS, storage, service-role, and hosted-backend behavior until there is a clear need.
```

This does not block future adapters. If the project later needs hosted Postgres, managed backups, object storage, or external APIs, those should be added behind the existing context/integration boundaries.

---

## 1.1 Elixir / Functional Programming Philosophy

The backend should be written in an Elixir-first, functional style.

Detailed coding and testing rules live in:

```txt
docs/standards/CODING_AND_TESTING_STANDARDS.md
```

Core rules:

```txt
Data in, data out.
Business rules in contexts.
Validation in changesets.
Side effects at the edges.
Rendering receives assigns; it does not fetch data.
```

Architecture boundaries:

```txt
LiveView      -> orchestrates UI state and calls context APIs
Context       -> owns business rules and persistence orchestration
Schema        -> defines fields, relations, and changesets
Component     -> renders assigns only
Theme module  -> renders shared data contract only
Integration   -> wraps media storage, Midtrans, and other external APIs
```

Implementation preferences:

```txt
- small pure functions for transformations
- pipelines for readable data flow
- pattern matching over nested conditionals
- {:ok, value} / {:error, reason} for fallible operations
- explicit context APIs instead of direct Repo calls from LiveViews
- Ecto against PostgreSQL
- server-side wrappers for media storage and Midtrans
```

This project should not become a JavaScript-style frontend app with backend calls scattered through UI code. Phoenix contexts are the boundary; LiveView is the interface layer.

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
│ PostgreSQL                                  │
│ relational data source                      │
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
- paid product checkout metadata
- checkout_url fallback for manual payment links

Media
- media records
- media storage adapter integration
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
- orders
- access grants
- Midtrans Snap transaction creation
- Midtrans webhook handling
- post access tokens
- product fulfillment status
- future email/download/shipping automation
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
  live "/search", Public.SearchLive, :index
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
  live "/site-settings", SiteSettingRedirectLive, :index
  live "/site-settings/:id/edit", SiteSettingResource.Form, :edit
  live "/themes", ThemeSettingsLive, :index
end
```

`site_settings` is a singleton content/config resource. The index route redirects directly to the existing edit form; there is no public admin list/new/delete flow for this resource.

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

Commerce tables are present for the MVP: orders and access_grants support paid/tips post access and product purchases.

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
  ├── paid checkout copy and checkout_url fallback
  └── connects to orders/access grants for purchase flow

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
checkout state
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
checkout gate
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

`tech_stack` is rendered prominently on the public work detail page as `Tech & Libraries`, so it should include the real languages, frameworks, databases, admin libraries, UI libraries, and tooling used in that project.

### Admin posts

CRUD fields:

```txt
title
slug
excerpt
content_markdown
content_html
editor_type
editor_json
cover_image_id
og_image_id
status
tags
published_at
seo_title
seo_description
```

Current editor direction:

- Admin Writing uses a Markdown-first editor powered by EasyMDE.
- `content_markdown` remains the canonical editable source.
- `content_html` should be generated from Markdown and sanitized before public rendering.
- `editor_json` is reserved for a future block editor and should not be required while the product is still Markdown-first.
- `cover_image_id` feeds article cards and fallback social image.
- `og_image_id` overrides cover image for social sharing when present.
- Body images are stored as Markdown image references inside `content_markdown`, not as a separate gallery table in the first phase.
- Body image URLs may reference local Media records by URL or external `https://` images. Multiple images can appear anywhere in the text because Markdown image syntax is positional.
- A future Media insert control should write the selected Media URL into the editor at the cursor position.

Post detail SEO contract:

```txt
title tag        -> seo_title || title
meta description -> seo_description || excerpt
og:image         -> og_image_id || cover_image_id
canonical        -> /writing/:slug
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
paid_excerpt
paywall_cta
payment_provider
checkout_mode
fulfillment_type
download_media_id
requires_shipping
cover_image_id
gallery_images
status
featured
```

For MVP, product detail uses an internal checkout form. `checkout_url` is only the manual payment-link fallback when Midtrans Snap is not configured.

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

Use internal checkout first. Midtrans Snap is used when `MIDTRANS_SERVER_KEY` is configured; manual `checkout_url` remains a fallback for payment links.

```txt
Product page
↓
Checkout gate + buyer email
↓
orders.kind = product_purchase
↓
Midtrans Snap or products.checkout_url fallback
↓
webhook/order status
↓
manual or future automated fulfillment
```

For writing monetization, free posts use support links while gated posts use Midtrans:

```txt
Free post
↓
Full article
↓
Optional Saweria / Buy Me Coffee CTA from site_settings
```

```txt
Tips/Paid post preview
↓
Email + selected amount/fixed price
↓
Midtrans checkout
↓
Midtrans HTTP notification/webhook
↓
order marked paid
↓
access token unlocks /writing/:slug
```

No customer login is required for the first paid-content implementation. Access is granted through a private token link.

### Why this is enough for MVP

The project focus is portfolio first.

MVP needs products to be purchasable without customer accounts, while keeping fulfillment simple enough to operate manually.

### Future commerce proper

Later upgrade to:

```txt
receipt/access email
download page/file delivery
customer account or library if needed
shipping address/courier integration
richer payment reporting
```

Provider rule:

```txt
Midtrans is the only payment provider planned.
Xendit is not used unless the user explicitly adds a Xendit account later.
Saweria and Buy Me Coffee are donation/support links only.
```

Do not add carts, subscriptions, or customer accounts unless specifically requested.

---

## 12. Deployment Architecture

### Simple deployment

```txt
Phoenix app → Fly.io / Render / Railway
PostgreSQL → managed Postgres, VPS Postgres, or local Docker for development
Media storage → local disk for MVP, S3-compatible storage later
Assets → Phoenix static assets
```

### Environment variables

```txt
DATABASE_URL
SECRET_KEY_BASE
PHX_HOST
UPLOAD_STORAGE_DRIVER
UPLOADS_DIR
MIDTRANS_SERVER_KEY
MIDTRANS_ENV
```

If Midtrans keys are missing, checkout falls back to manually configured `checkout_url` where available.

---

## 13. Testing Strategy

Testing is mandatory for backend behavior. Use the detailed standard:

```txt
docs/standards/CODING_AND_TESTING_STANDARDS.md
```

### Unit tests

```txt
contexts
schema changesets
theme registry
slug generation
content queries
status transitions
featured fallback
storage/Midtrans wrappers with mocked boundaries
```

### LiveView tests

```txt
homepage renders active theme
work list renders projects
post detail renders published post
product detail renders checkout link
admin CRUD creates content
theme setting updates active_theme
invalid forms show changeset errors
unauthenticated admin access is blocked
```

### Manual QA

```txt
homepage has navigation
all public pages have footer
mobile layout readable
admin forms save correctly
paid/tips/product checkout creates orders and does not expose secrets
health route returns ok
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
11. Product commerce checkout support
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
