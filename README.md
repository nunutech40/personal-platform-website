# personal-platform-website

Personal Brand Platform untuk Nunu Nugraha: portfolio, writing/blog, product catalog, admin-managed content, dan themeable public website.

Project direction utama tetap mengikuti dokumen:

- [docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md](docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md)
- [docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md](docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md)
- [docs/product/PRD_Personal_Brand_Platform_COMMERCE_READY.docx](docs/product/PRD_Personal_Brand_Platform_COMMERCE_READY.docx)
- [docs/technical/TRD_Personal_Brand_Platform_COMMERCE_READY.docx](docs/technical/TRD_Personal_Brand_Platform_COMMERCE_READY.docx)
- [docs/design/Design_Document_Old_Web_Personal_Brand_Platform.docx](docs/design/Design_Document_Old_Web_Personal_Brand_Platform.docx)

## Current Status

Saat ini repo berisi **dummy UI prototype** yang bisa dijalankan lokal sebelum backend Phoenix/Supabase dibuat.

Prototype ini dibuat untuk memvalidasi:

- public routes dan navigasi utama
- old-web visual direction
- reusable data contract
- theme switching behavior
- admin dashboard mock
- product detail dengan external `checkout_url`

Important note:

Prototype ini belum menggantikan arsitektur final. Target final MVP tetap Phoenix LiveView + Supabase seperti di building plan.

## Run Local

```bash
npm run dev
```

Lalu buka:

```text
http://127.0.0.1:5173
```

## Current Prototype Routes

- `/` homepage dengan active theme
- `/work` dan `/work/:slug`
- `/writing` dan `/writing/:slug`
- `/products` dan `/products/:slug`
- `/about`
- `/now`
- `/admin`
- `/admin/projects`
- `/admin/posts`
- `/admin/products`
- `/admin/site-settings`
- `/admin/themes`

## Current Files

- `index.html` — SPA entry point
- `styles.css` — old-web style plus placeholder future themes
- `src/app.js` — dummy data, simple router, renderers, admin mock, theme switching
- `server.mjs` — tiny local static server with SPA fallback
- `package.json` — local run script
- `docs/` — product, technical, architecture, planning, and design documentation
- `personal_brand_platform_agent_kit/` — reusable AI agent skills and short handoff docs

## Data Contract

Data dummy sekarang ada di `src/app.js` dan sengaja mengikuti contract PRD/TRD:

- `profile`
- `siteSettings`
- `themes`
- `projects`
- `posts`
- `products`
- `now`

Nanti ketika backend Phoenix/Supabase sudah siap, bagian data ini bisa diganti dengan Phoenix contexts, LiveView assigns, atau API response.

Theme switching saat ini memakai `localStorage`. Versi backend cukup menggantinya dengan update:

```txt
site_settings.active_theme
```

## Backend Handoff

Mapping prototype ke implementasi final:

- `data.profile` → `profiles`
- `data.siteSettings` → `site_settings`
- `data.themes` → `themes`
- `data.projects` → `projects`
- `data.posts` → `posts`
- `data.products` → `products`
- `state.activeTheme` → `site_settings.active_theme`
- route `/products/:slug` Buy Now → `products.checkout_url`

## Build Plan Alignment

Prototype ini meng-cover sebagian kecil dari build plan:

- Phase 2 Public Website Basic: route dan page dummy sudah tersedia.
- Phase 3 old_web_classic Theme: visual direction awal sudah tersedia.
- Phase 4 Theme System: theme resolver sederhana sudah tersedia di frontend dummy.
- Phase 5 Admin Dashboard MVP: admin mock sudah tersedia, belum CRUD backend.
- Phase 6 Product Catalog + Midtrans Payment Link: `checkout_url` dummy sudah tersedia.

Yang belum dibuat:

- Phoenix project
- Supabase connection
- database migrations
- admin auth
- real CRUD
- media upload
- SEO/RSS/sitemap
- proper Midtrans integration

## Agent Kit

Agent skills ada di:

```txt
personal_brand_platform_agent_kit/.agents/skills
```

Skill generik yang direkomendasikan:

- `pbp-architecting-phoenix-platforms`
- `pbp-coding-elixir-functionally`
- `pbp-modeling-content-data`
- `pbp-building-liveview-pages`
- `pbp-building-admin-forms`
- `pbp-theming-public-interfaces`
- `pbp-managing-publishing-workflows`
- `pbp-handling-media-assets`
- `pbp-integrating-external-checkout`
- `pbp-testing-and-qa`

Root documentation tetap menjadi source of truth. Agent kit hanya menyimpan workflow/skills yang reusable, bukan salinan building plan atau architecture.

## Documentation Structure

- `docs/product/` — PRD and product requirement docs
- `docs/technical/` — TRD and implementation requirement docs
- `docs/architecture/` — target system architecture and Elixir/Phoenix boundaries
- `docs/planning/` — build plan, AI workflow, work packets, and phase breakdown
- `docs/design/` — old-web design direction and UI reference screenshots

## Git Workflow

Workflow commit/push terpisah ada di:

- [docs/workflows/PUSH_WORKFLOW.md](docs/workflows/PUSH_WORKFLOW.md)
