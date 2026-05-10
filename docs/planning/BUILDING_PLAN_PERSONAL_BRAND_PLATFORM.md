# Building Plan — Personal Brand Platform

## Current Implementation Snapshot

Status per 2026-05-10:

```txt
Current repo contains a runnable static dummy UI prototype.
Final MVP target remains Phoenix LiveView + Supabase.
```

Prototype yang sudah dibuat:

```txt
- local static server via npm run dev
- homepage with active theme
- public routes for work, writing, products, about, now
- detail routes by slug for work/writing/products
- admin mock routes for dashboard, projects, posts, products, site settings, themes
- old_web_classic visual direction
- placeholder future themes: simple, us_builder, premium_dark
- theme switching stored in localStorage
- products with checkout_url for manual Midtrans Payment Link flow
```

Prototype ini adalah bridge untuk validasi UI/UX dan data contract. Saat masuk implementasi Phoenix, pindahkan data dummy dari `src/app.js` menjadi seed data, contexts, dan LiveView assigns.

Current prototype to final mapping:

```txt
src/app.js data.profile       -> profiles
src/app.js data.siteSettings  -> site_settings
src/app.js data.themes        -> themes
src/app.js data.projects      -> projects
src/app.js data.posts         -> posts
src/app.js data.products      -> products
localStorage active_theme     -> site_settings.active_theme
product.checkoutUrl           -> products.checkout_url
```

Current prototype coverage against phases:

```txt
Phase 0: partial local dev script only, Phoenix not created yet
Phase 1: not started, only dummy data exists
Phase 2: dummy public routes available
Phase 3: dummy old_web_classic available
Phase 4: dummy frontend theme switching available
Phase 5: admin mock available, real CRUD not started
Phase 6: checkout_url behavior available as external link
Phase 7+: not started
```

Next recommended step:

```txt
Create Phoenix project and port this prototype into LiveView components while preserving the data contract.
```

## AI Execution Workflow

Bagian ini adalah workflow untuk AI coding agent yang mengerjakan project dari fresh chat, new chat, atau meneruskan pekerjaan agent lain.

### Context Loading Rule

Agent tidak harus selalu membaca semua dokumen. Pakai aturan ini:

```txt
Fresh chat / no context:
  1. Read README.md
  2. Read Current Implementation Snapshot in this file
  3. Read docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md
  4. Read the target phase/slice in this file
  5. Read the relevant skill from personal_brand_platform_agent_kit/.agents/skills

Continuing same chat with known context:
  1. Do not reread all docs
  2. Check git status
  3. Read only files/sections touched by the task
  4. Read the relevant skill if the work type changed

New chat continuing a specific unfinished slice:
  1. Read README.md
  2. Read this AI Execution Workflow
  3. Read the specific Work Packet if provided by previous agent
  4. Read only the phase/slice section being continued
  5. Inspect current files and git status before editing
```

### Skill Selection

```txt
Elixir/FP backend implementation     -> pbp-coding-elixir-functionally
Project setup / context boundary     -> pbp-architecting-phoenix-platforms
Database, migrations, seed data      -> pbp-modeling-content-data
Public/admin LiveViews               -> pbp-building-liveview-pages
Admin CRUD forms                     -> pbp-building-admin-forms
Themes and old_web_classic UI        -> pbp-theming-public-interfaces
Draft/publish/slug/tag logic         -> pbp-managing-publishing-workflows
Images/uploads/media library         -> pbp-handling-media-assets
Buy Now / checkout_url / Midtrans    -> pbp-integrating-external-checkout
Verification before finishing        -> pbp-testing-and-qa
```

### Build Loop

Setiap AI task harus mengikuti loop ini:

```txt
1. Identify phase and slice
2. Load only required context
3. Inspect current implementation
4. Make the smallest coherent change
5. Run relevant tests/checks
6. Update docs only if behavior/architecture/build order changed
7. Leave a handoff note if the slice is incomplete
```

### Work Packet Format

Gunakan format ini saat memberikan task ke AI lain atau saat memecah pekerjaan untuk new chat:

```txt
Work Packet
Phase:
Slice:
Goal:
Read first:
Relevant skill:
Files likely touched:
Do not touch:
Acceptance checks:
Handoff note required:
```

Example:

```txt
Work Packet
Phase: Phase 2 - Public Website Basic
Slice: Work list and work detail
Goal: Port /work and /work/:slug from static prototype to Phoenix LiveView.
Read first: README.md, this workflow, Phase 2, Public Pages section, docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md route architecture.
Relevant skill: pbp-building-liveview-pages, pbp-theming-public-interfaces
Files likely touched: router, public LiveViews, portfolio context, old_web components, tests
Do not touch: future commerce tables, unrelated admin CRUD
Acceptance checks: /work lists published projects; /work/:slug 404s missing/draft; nav remains visible
Handoff note required: yes if not all tests pass
```

### Work Breakdown for Multi-Agent / New Chat Execution

Pecah implementasi menjadi slice kecil berikut. Satu agent sebaiknya mengambil satu slice saja kecuali user meminta lebih.

```txt
Slice 0.1 - Repo and Phoenix setup
  Phase: 0
  Skill: pbp-coding-elixir-functionally, pbp-architecting-phoenix-platforms
  Output: Phoenix app runs locally, static prototype preserved or porting plan documented

Slice 1.1 - Core identity/settings/theme schema
  Phase: 1
  Skill: pbp-coding-elixir-functionally, pbp-modeling-content-data
  Output: profiles, site_settings, themes migrations/schemas/seeds

Slice 1.2 - Content/catalog/media/tag schema
  Phase: 1
  Skill: pbp-coding-elixir-functionally, pbp-modeling-content-data
  Output: projects, posts, products, media, tags, join tables

Slice 2.1 - Public layout and homepage
  Phase: 2 and 3
  Skill: pbp-building-liveview-pages, pbp-theming-public-interfaces
  Output: / renders old_web_classic homepage from seed/context data

Slice 2.2 - Work pages
  Phase: 2
  Skill: pbp-building-liveview-pages, pbp-managing-publishing-workflows
  Output: /work and /work/:slug

Slice 2.3 - Writing pages
  Phase: 2
  Skill: pbp-building-liveview-pages, pbp-managing-publishing-workflows
  Output: /writing and /writing/:slug

Slice 2.4 - Product pages and external checkout
  Phase: 2 and 6
  Skill: pbp-building-liveview-pages, pbp-integrating-external-checkout
  Output: /products and /products/:slug with Buy Now using checkout_url

Slice 2.5 - About, now, contact
  Phase: 2
  Skill: pbp-building-liveview-pages, pbp-theming-public-interfaces
  Output: /about, /now, /contact

Slice 4.1 - Theme resolver
  Phase: 4
  Skill: pbp-theming-public-interfaces
  Output: active_theme selects theme module with fallback

Slice 5.1 - Admin auth and dashboard
  Phase: 5
  Skill: pbp-architecting-phoenix-platforms, pbp-building-admin-forms
  Output: protected /admin with counts and quick actions

Slice 5.2 - Admin projects
  Phase: 5
  Skill: pbp-building-admin-forms, pbp-managing-publishing-workflows
  Output: project index/new/edit/archive/publish

Slice 5.3 - Admin posts
  Phase: 5
  Skill: pbp-building-admin-forms, pbp-managing-publishing-workflows
  Output: post index/new/edit/archive/publish

Slice 5.4 - Admin products
  Phase: 5 and 6
  Skill: pbp-building-admin-forms, pbp-integrating-external-checkout
  Output: product CRUD including checkout_url and status

Slice 5.5 - Admin site settings and theme settings
  Phase: 5
  Skill: pbp-building-admin-forms, pbp-theming-public-interfaces
  Output: edit homepage copy, featured IDs, active_theme

Slice 7.1 - Media upload and picker
  Phase: 7
  Skill: pbp-handling-media-assets
  Output: Supabase upload, media library, alt text, cover selection

Slice 8.1 - SEO, RSS, sitemap
  Phase: 8
  Skill: pbp-testing-and-qa
  Output: meta tags, OG data, sitemap, robots, writing RSS
```

### Handoff Note Format

Jika agent berhenti sebelum semua selesai, tulis handoff note di final response atau di docs bila user meminta:

```txt
Handoff
Completed:
Changed files:
Checks run:
Known issues:
Next recommended slice:
Context to read next:
```

### Definition of Done for Every Slice

```txt
- slice is scoped and does not include unrelated refactors
- data remains separate from theme
- public/admin behavior is documented if changed
- relevant tests or manual QA are run
- no draft content leaks publicly
- product checkout remains external-link only until future commerce phase
- git status is clean after commit when user asks to commit
```

## Purpose

Dokumen ini adalah execution plan untuk membangun **Personal Brand Platform** milik Nunu Nugraha.

Website ini bukan hanya portfolio. Website ini akan menjadi:

1. Portfolio untuk menampilkan karya/project.
2. Writing/blog untuk catatan, artikel, dan build-in-public.
3. Product catalog untuk produk digital/fisik.
4. Personal brand hub.
5. Themeable website: data tetap sama, tampilan bisa diganti-ganti.

Fokus awal adalah membangun MVP yang bisa dipakai dulu:

> portfolio + writing + product catalog + admin dashboard + theme switching.

Commerce dengan Midtrans disiapkan sejak konsep awal, tapi proper payment integration tidak wajib dibangun di MVP pertama.

---

# 1. Product Direction

## 1.1 Core Idea

Website harus memisahkan **content/data** dari **theme/presentation**.

Artinya:

```txt
Same data.
Different theme.
```

Data seperti profile, projects, posts, products, dan media harus tetap sama.

Theme bisa berubah dari:

```txt
old_web_classic
```

menjadi:

```txt
simple
us_builder
premium_dark
```

tanpa perlu menginput ulang content.

---

## 1.2 MVP Goal

MVP harus memungkinkan:

### Public user dapat:

- Membuka homepage.
- Melihat daftar work/projects.
- Membuka detail project/case study.
- Membaca tulisan/blog.
- Melihat produk.
- Membuka detail produk.
- Membuka about page.
- Membuka now page.
- Klik tombol buy yang mengarah ke Midtrans Payment Link/manual checkout URL.

### Admin dapat:

- Login ke admin dashboard.
- Menambah, mengedit, dan menghapus project.
- Menambah, mengedit, dan menghapus blog post.
- Menambah, mengedit, dan menghapus product.
- Upload dan memilih media.
- Mengatur profile/site settings.
- Memilih active theme.

---

## 1.3 Non-Goals untuk MVP

Jangan bangun ini dulu di MVP:

- Cart system.
- User/customer account.
- Automatic Midtrans webhook.
- Automatic digital download delivery.
- Order tracking.
- Shipping management.
- Invoice generator.
- Email automation.
- Advanced analytics.
- Comment system.
- Newsletter.
- Multi-language.
- Visual page builder.
- Drag-and-drop theme editor.

---

# 2. Recommended Stack

## 2.1 Main Stack

```txt
Frontend/Public UI: Phoenix LiveView
Backend: Elixir / Phoenix
Database: Supabase Postgres
Storage: Supabase Storage
Styling: Tailwind CSS or simple CSS
Payment MVP: Midtrans Payment Link via checkout_url
Payment Future: Midtrans API + webhook
```

## 2.2 Reasoning

Frontend disarankan memakai **Phoenix LiveView** supaya stack tetap sederhana dan dekat dengan Elixir.

Karena owner project lebih peduli Elixir dan tidak ingin menambah kompleksitas frontend terlalu cepat, maka LiveView cukup untuk:

- Public website.
- Admin dashboard.
- Form CRUD.
- Theme rendering.
- Basic interactivity.

Next.js/React belum wajib kecuali nanti butuh frontend experience yang sangat kompleks.

---

# 3. Core Architecture

## 3.1 High-Level Architecture

```txt
User / Admin
   ↓
Phoenix LiveView App
   ↓
Phoenix Contexts / Business Logic
   ↓
Supabase Postgres + Supabase Storage
```

## 3.2 Payment MVP Architecture

```txt
User opens product page
   ↓
Clicks Buy Now
   ↓
Redirects to products.checkout_url
   ↓
User pays via Midtrans Payment Link
   ↓
Fulfillment is handled manually
```

## 3.3 Future Payment Architecture

```txt
User clicks Buy Now
   ↓
Checkout page inside website
   ↓
Phoenix creates order
   ↓
Phoenix requests transaction to Midtrans
   ↓
User pays via Midtrans
   ↓
Midtrans sends webhook to Phoenix
   ↓
Phoenix updates payment/order status
   ↓
If digital product: create download entitlement
   ↓
If physical product: create shipment/fulfillment flow
```

---

# 4. Database Plan

## 4.1 MVP Tables

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

## 4.2 Commerce-Ready Future Tables

Design these in TRD, but implementation can be delayed:

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

---

# 5. MVP Database Schema

## 5.1 profiles

Purpose: menyimpan data personal utama.

Fields:

```txt
id
name
headline
bio
avatar_url
location
email
x_url
github_url
linkedin_url
created_at
updated_at
```

Notes:

- Gunakan `profiles`, bukan `users`, karena ini bukan user account system.
- `profiles` merepresentasikan public identity pemilik website.
- `users` nanti bisa dipakai untuk admin/auth kalau dibutuhkan.

---

## 5.2 site_settings

Purpose: menyimpan konfigurasi website dan active theme.

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
social_links
featured_project_ids
featured_post_ids
featured_product_ids
created_at
updated_at
```

Important:

`active_theme` adalah kunci theme switching.

Example:

```txt
active_theme = old_web_classic
```

---

## 5.3 themes

Purpose: menyimpan daftar theme yang tersedia.

Fields:

```txt
id
name
slug
description
is_active
is_enabled
preview_image_url
created_at
updated_at
```

Example rows:

```txt
old_web_classic
simple
us_builder
premium_dark
```

---

## 5.4 projects

Purpose: menyimpan portfolio/work/case study.

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
tech_stack
cover_image_url
demo_url
github_url
year
status
featured
published_at
created_at
updated_at
```

Status values:

```txt
draft
published
archived
```

---

## 5.5 posts

Purpose: menyimpan blog/writing.

Fields:

```txt
id
title
slug
excerpt
content
cover_image_url
status
reading_time
published_at
seo_title
seo_description
created_at
updated_at
```

Status values:

```txt
draft
published
archived
```

---

## 5.6 products

Purpose: menyimpan product catalog untuk produk digital/fisik.

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
cover_image_url
gallery_images
status
featured
created_at
updated_at
```

Product type values:

```txt
digital
physical
service
experimental
```

Status values:

```txt
draft
active
archived
coming_soon
```

Important MVP field:

```txt
checkout_url
```

Untuk MVP, field ini bisa diisi Midtrans Payment Link.

---

## 5.7 media

Purpose: menyimpan metadata file/gambar dari Supabase Storage.

Fields:

```txt
id
file_name
file_url
mime_type
size_bytes
alt_text
created_at
updated_at
```

---

## 5.8 tags

Purpose: tag umum untuk projects, posts, dan products.

Fields:

```txt
id
name
slug
created_at
updated_at
```

---

## 5.9 Pivot Tables

### project_tags

```txt
project_id
tag_id
created_at
```

### post_tags

```txt
post_id
tag_id
created_at
```

### product_tags

```txt
product_id
tag_id
created_at
```

---

# 6. Future Commerce Database Schema

These tables are not required in MVP but should be planned for future Midtrans proper integration.

## 6.1 customers

```txt
id
name
email
phone
created_at
updated_at
```

---

## 6.2 orders

```txt
id
order_number
customer_id
customer_name
customer_email
customer_phone
total_amount
currency
status
payment_provider
payment_reference
created_at
updated_at
```

Status values:

```txt
pending
paid
failed
expired
cancelled
refunded
```

---

## 6.3 order_items

```txt
id
order_id
product_id
product_title_snapshot
quantity
unit_price
subtotal
created_at
```

Why snapshot fields?

Product name/price might change later. Order history must remain accurate.

---

## 6.4 payments

```txt
id
order_id
provider
provider_order_id
transaction_id
payment_type
gross_amount
transaction_status
fraud_status
va_number
payment_url
raw_payload
paid_at
expired_at
created_at
updated_at
```

Provider value:

```txt
midtrans
```

---

## 6.5 product_files

For digital products.

```txt
id
product_id
file_name
file_url
file_size
version
created_at
updated_at
```

---

## 6.6 digital_entitlements

For digital product access after successful payment.

```txt
id
customer_id
product_id
order_id
access_token
expires_at
download_limit
download_count
created_at
updated_at
```

---

## 6.7 shipping_addresses

For physical products.

```txt
id
order_id
recipient_name
phone
address_line_1
address_line_2
city
province
postal_code
country
created_at
updated_at
```

---

## 6.8 shipments

```txt
id
order_id
courier
tracking_number
shipping_status
shipped_at
delivered_at
created_at
updated_at
```

Shipping status values:

```txt
pending
packed
shipped
delivered
returned
```

---

# 7. Public Pages

## 7.1 Required Public Routes

```txt
/
/work
/work/:slug
/writing
/writing/:slug
/products
/products/:slug
/about
/now
/contact
```

---

## 7.2 Homepage

Purpose: entry point utama untuk personal brand platform.

Must include:

```txt
- clear navigation
- hero/profile intro
- start here links
- featured work
- recent writing
- featured products
- now section
- footer
```

Important UX rule:

Homepage harus punya jalan masuk ke halaman lain.

Required links:

```txt
Home | Work | Writing | Products | About | Now
```

Section links:

```txt
View all work
View all writing
View all products
About me
```

---

## 7.3 Work List Page

Route:

```txt
/work
```

Must include:

```txt
- title: Work
- short intro
- project list
- filter by tag/category
- project title
- project summary
- year
- tech stack
- link to detail page
```

---

## 7.4 Work Detail Page

Route:

```txt
/work/:slug
```

Must include:

```txt
- breadcrumb
- title
- subtitle/summary
- role
- stack
- year
- status
- overview
- problem
- solution
- outcome
- screenshots/media
- links: demo, GitHub, etc
```

---

## 7.5 Writing List Page

Route:

```txt
/writing
```

Must include:

```txt
- title: Writing
- intro sentence
- post list
- category/tag filter
- RSS link optional
- post title
- date
- excerpt
```

---

## 7.6 Writing Detail Page

Route:

```txt
/writing/:slug
```

Must include:

```txt
- breadcrumb
- article title
- metadata: published date, read time, tags
- article content
- related posts
```

---

## 7.7 Products List Page

Route:

```txt
/products
```

Must include:

```txt
- title: Products
- intro sentence
- digital products section
- physical/experimental products section
- product name
- short description
- price
- status
- link to detail page
```

---

## 7.8 Product Detail Page

Route:

```txt
/products/:slug
```

Must include:

```txt
- breadcrumb
- title
- summary
- price
- product type
- preview image
- description
- what is included
- FAQ optional
- Buy Now link
```

Buy Now behavior in MVP:

```txt
If product.checkout_url exists:
  render Buy Now link to checkout_url
Else:
  render Contact / Coming Soon state
```

---

## 7.9 About Page

Route:

```txt
/about
```

Must include:

```txt
- short bio
- what I do
- what I care about
- tools I use
- social links
```

---

## 7.10 Now Page

Route:

```txt
/now
```

Must include:

```txt
- currently building
- currently learning
- current focus
- recent experiments
```

---

## 7.11 Contact Page

Route:

```txt
/contact
```

Must include:

```txt
- email
- social links
- collaboration note
```

---

# 8. Admin Pages

## 8.1 Required Admin Routes

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

---

## 8.2 Admin Dashboard

Route:

```txt
/admin
```

Must include:

```txt
- total projects
- total posts
- total products
- draft count
- active theme
- recent updates
- quick actions
```

---

## 8.3 Admin Projects

Must support:

```txt
- create project
- edit project
- delete/archive project
- publish/unpublish project
- set featured
- attach cover image
- attach screenshots/media
- manage tags
```

Fields:

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
cover_image_url
demo_url
github_url
year
status
featured
published_at
tags
```

---

## 8.4 Admin Posts

Must support:

```txt
- create post
- edit post
- delete/archive post
- save draft
- publish post
- manage tags
- SEO fields
```

Fields:

```txt
title
slug
excerpt
content
cover_image_url
status
reading_time
published_at
seo_title
seo_description
tags
```

---

## 8.5 Admin Products

Must support:

```txt
- create product
- edit product
- archive product
- set status
- set featured
- set price
- set checkout_url
- attach cover image
- attach gallery images
- manage tags
```

Fields:

```txt
title
slug
summary
description
product_type
price
currency
checkout_url
cover_image_url
gallery_images
status
featured
tags
```

MVP note:

`checkout_url` is used for Midtrans Payment Link.

---

## 8.6 Admin Media

Must support:

```txt
- upload image/file
- list uploaded media
- copy URL
- set alt text
- select media for project/post/product
```

Storage:

```txt
Supabase Storage
```

---

## 8.7 Admin Site Settings

Must support editing:

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

---

## 8.8 Admin Themes

Must support:

```txt
- list available themes
- preview theme
- select active theme
- save active theme
```

Important:

Changing theme must not change underlying data.

---

# 9. Theme System

## 9.1 Core Rule

Themes must be presentation only.

They must not own the content.

```txt
Content lives in DB.
Theme only renders content.
```

---

## 9.2 Theme Data Contract

All themes must be able to consume:

```txt
profile
site_settings
projects
posts
products
media
tags
```

---

## 9.3 Theme Rendering Flow

```txt
User opens page
   ↓
Phoenix loads site_settings
   ↓
Read active_theme
   ↓
Load required page data
   ↓
Render matching theme module/component
```

---

## 9.4 First Theme: old_web_classic

Design direction:

```txt
- old-school HTML feel
- white background
- black serif typography
- blue underlined links
- thin horizontal rules
- minimal CSS
- simple layout
- human and personal
- not generic SaaS
```

Why this theme first:

```txt
- faster to build
- distinctive for personal brand
- good for build-in-public content
- easy to implement in LiveView
- easy to keep accessible
- low visual complexity
```

---

## 9.5 Future Themes

Potential future themes:

```txt
simple
us_builder
premium_dark
creator_style
```

Each new theme must reuse the same data contract.

---

# 10. Frontend Components

## 10.1 Shared Public Components

```txt
PublicLayout
Header
Navigation
Footer
SEOHead
ImageFrame
TagList
LinkList
Pagination
```

---

## 10.2 Old Web Theme Components

```txt
OldWebLayout
OldWebHeader
OldWebNav
OldWebFooter
OldWebHome
OldWebSection
OldWebLinkList
OldWebImageFrame
OldWebProjectList
OldWebProjectDetail
OldWebPostList
OldWebPostDetail
OldWebProductList
OldWebProductDetail
OldWebAbout
OldWebNow
```

---

## 10.3 Admin Components

```txt
AdminLayout
AdminNav
AdminTable
AdminForm
AdminField
AdminTextarea
AdminSelect
AdminStatusBadge
AdminMediaPicker
AdminThemePreview
AdminConfirmDelete
```

---

# 11. SEO and Sharing

## 11.1 Required SEO Features

```txt
- meta title
- meta description
- canonical URL
- Open Graph title
- Open Graph description
- Open Graph image
- sitemap.xml
- robots.txt
- RSS feed for writing
```

## 11.2 Pages That Need SEO

```txt
Homepage
Work detail
Writing detail
Product detail
About
```

---

# 12. Responsive and Accessibility Requirements

## 12.1 Responsive

Must work on:

```txt
- mobile
- tablet
- desktop
```

Old web layout can remain simple, but must not break on mobile.

## 12.2 Accessibility

Requirements:

```txt
- semantic HTML
- readable font sizes
- keyboard navigation
- clear focus states
- alt text for images
- sufficient contrast
- links must be visually identifiable
```

---

# 13. Build Phases

## Phase 0 — Project Setup

Priority: High

Current prototype note:

```txt
Static dummy UI already runs locally with npm run dev.
This is not the final Phoenix setup.
Use it as visual/data-contract reference when creating the Phoenix project.
```

Tasks:

```txt
- Create Phoenix project
- Configure Supabase Postgres connection
- Setup Tailwind or simple CSS
- Setup basic public layout
- Setup basic admin layout
- Setup admin authentication
- Setup env config
- Setup local dev scripts
```

Done when:

```txt
- App runs locally
- DB connection works
- Admin login page exists
- Public homepage route exists
```

---

## Phase 1 — Database Foundation

Priority: High

Tasks:

```txt
- Create profiles table
- Create site_settings table
- Create themes table
- Create projects table
- Create posts table
- Create products table
- Create media table
- Create tags table
- Create pivot tag tables
- Create seed data
```

Done when:

```txt
- Core schema exists
- Seed data renders in console or basic page
- active_theme exists in site_settings
```

---

## Phase 2 — Public Website Basic

Priority: High

Current prototype note:

```txt
Dummy versions of these routes already exist in the static prototype.
Final implementation must render data from Phoenix contexts/Supabase instead of src/app.js.
```

Build routes in this order:

```txt
1. /
2. /work
3. /work/:slug
4. /writing
5. /writing/:slug
6. /products
7. /products/:slug
8. /about
9. /now
10. /contact
```

Done when:

```txt
- Public pages render data from DB
- Navigation works
- Detail pages work by slug
```

---

## Phase 3 — old_web_classic Theme

Priority: High

Current prototype note:

```txt
Initial old_web_classic styling exists in styles.css.
Keep the scale compact and avoid duplicated hero/name content.
```

Tasks:

```txt
- Implement OldWebLayout
- Implement OldWebHeader
- Implement OldWebNav
- Implement OldWebFooter
- Implement homepage style
- Implement list/detail pages style
- Implement mobile responsive polish
```

Done when:

```txt
- All public pages render using old_web_classic
- Homepage has clear navigation and section links
- Mobile layout is readable
```

---

## Phase 4 — Theme System

Priority: High

Current prototype note:

```txt
The prototype uses localStorage for active_theme.
Final MVP should read and write active_theme from site_settings.
```

Tasks:

```txt
- Read active_theme from site_settings
- Create theme resolver
- Render page via selected theme
- Add theme list in DB
- Add placeholder future themes
```

Done when:

```txt
- active_theme controls rendered theme
- changing active_theme changes visual layer
- data remains unchanged
```

---

## Phase 5 — Admin Dashboard MVP

Priority: High

Current prototype note:

```txt
Admin screens currently exist as frontend-only mock pages.
They document the intended shape of dashboard, tables, dummy forms, and theme settings.
They do not perform auth, validation, persistence, or real CRUD yet.
```

Tasks:

```txt
- Admin dashboard
- CRUD projects
- CRUD posts
- CRUD products
- Media management basic
- Site settings form
- Theme settings form
```

Done when:

```txt
- Admin can manage projects
- Admin can manage posts
- Admin can manage products
- Admin can edit site settings
- Admin can switch active theme
```

---

## Phase 6 — Product Catalog + Midtrans Payment Link

Priority: Medium-High

Current prototype note:

```txt
Product detail pages already render Buy Now links from checkout_url.
Use this behavior unchanged for MVP manual Midtrans Payment Link mode.
```

Tasks:

```txt
- Add checkout_url field to product form
- Add Buy Now link on product detail
- Add product status handling
- Add coming soon state
- Add manual fulfillment note if needed
```

Done when:

```txt
- Product page has Buy Now
- Buy Now redirects to checkout_url
- Midtrans Payment Link can be used manually
```

---

## Phase 7 — Media Management

Priority: Medium

Tasks:

```txt
- Upload to Supabase Storage
- Save media metadata
- List media in admin
- Select cover image for projects/posts/products
- Add alt text
```

Done when:

```txt
- Admin can upload and use media
- Public pages show uploaded media
```

---

## Phase 8 — SEO and Sharing

Priority: Medium

Tasks:

```txt
- Add meta title and description
- Add Open Graph tags
- Add sitemap.xml
- Add robots.txt
- Add RSS feed for writing
```

Done when:

```txt
- Shared links have title/description/image
- Sitemap exists
- RSS feed exists
```

---

## Phase 9 — Future Commerce Proper

Priority: Low for MVP, High for monetization phase

Tasks:

```txt
- Add customers table
- Add orders table
- Add order_items table
- Add payments table
- Add product_files table
- Add digital_entitlements table
- Add shipping_addresses table
- Add shipments table
- Create checkout page
- Integrate Midtrans API
- Handle Midtrans webhook
- Update order/payment status
- Create admin orders page
- Create digital download flow
- Create physical shipping flow
```

Done when:

```txt
- Website can create orders
- Payment status updates automatically
- Digital product access can be granted automatically
- Physical orders can be tracked manually/admin-side
```

---

# 14. Recommended Sprint Order

## Sprint 1 — Foundation

```txt
- Phoenix project setup
- Supabase connection
- Admin auth
- Public/admin layouts
```

## Sprint 2 — Core Database

```txt
- profiles
- site_settings
- themes
- projects
- posts
- products
- media
- tags
```

## Sprint 3 — Public Pages

```txt
- homepage
- work list/detail
- writing list/detail
- products list/detail
- about
- now
```

## Sprint 4 — old_web_classic Theme

```txt
- old web layout
- navigation
- homepage sections
- list/detail page styling
- responsive polish
```

## Sprint 5 — Admin CRUD

```txt
- projects CRUD
- posts CRUD
- products CRUD
- site settings
- theme settings
```

## Sprint 6 — Product Catalog + Payment Link

```txt
- checkout_url
- Buy Now link
- Midtrans Payment Link manual flow
- product status/coming soon handling
```

## Sprint 7 — Polish

```txt
- media upload
- SEO
- OG image
- RSS
- sitemap
- accessibility pass
```

## Sprint 8 — Commerce Proper Later

```txt
- orders
- payments
- Midtrans API
- webhook
- digital entitlement
- shipping
```

---

# 15. MVP Acceptance Criteria

MVP is complete when:

```txt
- Homepage renders from DB
- Homepage has clear navigation
- Work list renders from DB
- Work detail renders by slug
- Writing list renders from DB
- Writing detail renders by slug
- Products list renders from DB
- Product detail renders by slug
- Buy Now uses checkout_url
- About page renders
- Now page renders
- Admin can login
- Admin can CRUD projects
- Admin can CRUD posts
- Admin can CRUD products
- Admin can edit site settings
- Admin can switch active theme
- old_web_classic theme is active
- Website is readable on mobile
- Basic SEO metadata exists
```

---

# 16. Implementation Rules for AI Agents

When an AI coding agent works on this project, follow these rules:

## 16.1 Do Not Overbuild

Do not implement cart, customer accounts, Midtrans webhook, or complex ecommerce until the MVP is complete.

## 16.2 Keep Data Separate from Theme

Do not hardcode content inside theme components unless it is temporary seed/demo data.

Theme components should receive data from contexts or assigns.

## 16.3 Make Theme Replaceable

Do not make `old_web_classic` the only possible hardcoded design path.

Create a theme resolver or equivalent structure so future themes can be added.

## 16.4 Prioritize Admin CRUD

The admin dashboard can be visually simple. Functionality matters more than polish.

## 16.5 Midtrans MVP is Manual

For the first version, products only need `checkout_url`.

Do not build automatic payment handling until the commerce proper phase.

## 16.6 Keep UX Clear

Even with old-web aesthetic, navigation must be obvious.

Homepage must always include:

```txt
Work
Writing
Products
About
Now
```

## 16.7 Use Slugs for Public Content

Public detail pages must use slug routes:

```txt
/work/:slug
/writing/:slug
/products/:slug
```

## 16.8 Prefer Simple HTML

For `old_web_classic`, avoid unnecessary modern UI patterns.

Use:

```txt
- semantic HTML
- headings
- paragraphs
- lists
- links
- horizontal rules
- simple image frames
```

---

# 17. Key Risks and Mitigations

## Risk 1 — Scope Creep

Mitigation:

```txt
Build content platform first.
Commerce proper later.
```

## Risk 2 — Theme System Becomes Too Complex

Mitigation:

```txt
Use a simple theme resolver.
No drag-and-drop builder.
No visual theme editor in MVP.
```

## Risk 3 — Admin Takes Too Long

Mitigation:

```txt
Use simple forms and tables.
No need for fancy dashboard UI.
```

## Risk 4 — Payment Integration Distracts from Portfolio Goal

Mitigation:

```txt
Use Midtrans Payment Link in checkout_url first.
```

## Risk 5 — Old-Web Design Becomes Confusing

Mitigation:

```txt
Keep global nav visible.
Add section links like View all work/writing/products.
```

---

# 18. Final MVP Definition

The MVP is:

```txt
A themeable personal brand platform built with Elixir/Phoenix and Supabase,
with admin-managed portfolio, writing, product catalog,
and old_web_classic as the first visual identity.
```

Shorter version:

```txt
Personal brand platform first.
Commerce proper later.
```

---

# 19. North Star

This website should feel like:

```txt
not just a portfolio,
but a personal basecamp.
```

A place for:

```txt
- work
- writing
- products
- experiments
- build-in-public journey
- personal brand
```

Core principle:

```txt
Data stable.
Design flexible.
Build small.
Iterate fast.
```
