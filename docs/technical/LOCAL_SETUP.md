# Local Setup — Personal Brand Platform

## Overview

Project ini adalah **Phoenix LiveView** app (Elixir) dengan **PostgreSQL** database.

- **App:** http://localhost:4000
- **Admin:** http://localhost:4000/admin
- **Login:** admin / admin123

> Static prototype lama (FE SPA) ada di `index.html` + `src/app.js` via `npm run dev` di port 5173.
> Itu sudah tidak dipakai lagi. Semua sudah pindah ke Phoenix.

---

## Prerequisites

```bash
# Elixir & Phoenix
elixir --version    # >= 1.17
mix --version       # >= 1.17

# PostgreSQL (via Homebrew)
brew list postgresql@16
/opt/homebrew/bin/psql --version

# Node.js (untuk asset build)
node --version      # >= 18
```

---

## Quick Start

```bash
# 1. Start PostgreSQL
brew services start postgresql@16

# 2. Setup database (create + migrate + seed)
cd personal_brand
mix ecto.setup

# 3. Start Phoenix
mix phx.server

# 4. Buka browser
open http://localhost:4000
```

Atau pakai script:

```bash
./scripts/start-local.sh
```

---

## Database

### Connection

Konfigurasi ada di `personal_brand/config/dev.exs`:

```elixir
config :personal_brand, PersonalBrand.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "personal_brand_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

### Useful Commands

```bash
# Masuk ke database
/opt/homebrew/bin/psql -U postgres -d personal_brand_dev

# Lihat semua tabel
\dt

# Lihat schema tabel
\d+ projects

# Query data
SELECT * FROM projects;
SELECT * FROM posts;
SELECT * FROM products;
SELECT * FROM site_settings;
SELECT * FROM themes;
```

### Migrations

```bash
# Buat migration baru
mix ecto.gen.migration nama_migration

# Jalankan migration
mix ecto.migrate

# Rollback
mix ecto.rollback

# Reset database (drop + create + migrate + seed)
mix ecto.reset
```

### Seed Data

File: `personal_brand/priv/repo/seeds.exs`

Berisi data dummy untuk development:
- 1 admin account (admin / admin123)
- 4 themes (old_web_classic, simple, us_builder, premium_dark)
- 1 site_settings
- 3 projects (HabitKit, SplitWise++, PromptBoard)
- 3 posts (blog articles)
- 2 products (Flux Icons, SnipKit)

Jalankan:

```bash
mix run priv/repo/seeds.exs
```

---

## Project Structure

```
personal_brand/
├── config/                    # App configuration
│   ├── config.exs            # Base config
│   ├── dev.exs               # Dev config (DB, dev settings)
│   ├── prod.exs              # Production config
│   ├── runtime.exs           # Runtime config (secrets)
│   └── test.exs              # Test config
├── lib/
│   ├── personal_brand.ex     # App module
│   ├── personal_brand/
│   │   ├── accounts/         # Admin auth context
│   │   ├── application.ex    # App startup
│   │   ├── content/          # Content contexts (projects, posts, products, media, etc.)
│   │   ├── repo.ex           # Ecto repo
│   │   └── ...
│   └── personal_brand_web/
│       ├── components/       # Shared components (layouts, core_components)
│       ├── controllers/      # PageController, auth controllers
│       ├── live/             # LiveViews (admin dashboard, Backpex resources)
│       ├── plugs/            # Plugs (RequireAdmin)
│       ├── router.ex         # Routes
│       └── ...
├── priv/
│   ├── repo/
│   │   ├── migrations/       # Ecto migrations
│   │   └── seeds.exs         # Seed data
│   └── static/               # Static assets (favicon, images)
├── assets/                   # Frontend assets (CSS, JS)
│   ├── css/app.css           # Main CSS (Tailwind + daisyUI)
│   ├── js/app.js             # Main JS (Phoenix hooks)
│   └── vendor/               # Vendor JS (daisyUI, heroicons, topbar)
└── test/                     # Tests
```

---

## Routes

### Public Routes (Phase 2 — in progress)

| Route | Description | Status |
|-------|-------------|--------|
| `/` | Homepage | ✅ (redirect ke admin, perlu diubah) |
| `/work` | Work list | ❌ Belum |
| `/work/:slug` | Work detail | ❌ Belum |
| `/writing` | Writing list | ❌ Belum |
| `/writing/:slug` | Writing detail | ❌ Belum |
| `/products` | Products list | ❌ Belum |
| `/products/:slug` | Product detail | ❌ Belum |
| `/about` | About page | ❌ Belum |
| `/now` | Now page | ❌ Belum |

### Admin Routes

| Route | Description | Status |
|-------|-------------|--------|
| `/admin` | Dashboard | ✅ Backpex |
| `/admin/login` | Login | ✅ |
| `/admin/logout` | Logout | ✅ |
| `/admin/projects` | CRUD projects | ✅ Backpex |
| `/admin/posts` | CRUD posts | ✅ Backpex |
| `/admin/products` | CRUD products | ✅ Backpex |
| `/admin/media` | Media library | ✅ Backpex |
| `/admin/site-settings` | Site settings | ✅ Backpex |
| `/admin/themes` | Theme settings | ✅ Backpex |

---

## Scripts

```bash
./scripts/start-local.sh    # Start PostgreSQL + Phoenix
./scripts/stop-local.sh     # Stop Phoenix + PostgreSQL
./scripts/status-local.sh   # Check status
```

---

## Data Contract

Data dari static prototype (`src/app.js`) sudah dipindah ke database:

| Static Prototype | Database Table |
|-----------------|----------------|
| `data.profile` | `profiles` (belum ada migration) |
| `data.siteSettings` | `site_settings` |
| `data.themes` | `themes` |
| `data.projects` | `projects` |
| `data.posts` | `posts` |
| `data.products` | `products` |
| `data.now` | `site_settings` (bisa ditambah kolom) |
| `localStorage active_theme` | `site_settings.active_theme` |

---

## Porting Status (Static Prototype → Phoenix)

### Done
- ✅ Database schema & migrations
- ✅ Seed data
- ✅ Admin CRUD via Backpex
- ✅ Admin auth (login/logout)
- ✅ Admin layouts

### In Progress
- 🔄 Public homepage (LiveView)
- 🔄 Public routes (work, writing, products, about, now)

### Not Started
- ❌ old_web_classic theme components
- ❌ Theme resolver
- ❌ Media upload
- ❌ SEO / OG tags
- ❌ RSS / sitemap
