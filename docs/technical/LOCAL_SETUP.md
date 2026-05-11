# Local Setup — Personal Brand Platform

## Overview

Project ini adalah **Phoenix LiveView** app (Elixir) dengan **PostgreSQL** database.

- **App:** http://localhost:4000
- **Admin:** http://localhost:4000/admin
- **Login:** admin / admin123

> Frontend publik sekarang dirender oleh Phoenix LiveView di port `4000`.
> Jangan jalankan FE static/Vite di port `5173`; prototype static lama sudah dihapus dari root repo.

---

## Prerequisites

```bash
# Elixir & Phoenix
elixir --version    # >= 1.17
mix --version       # >= 1.17

# PostgreSQL (via Homebrew)
brew list postgresql@16
/opt/homebrew/opt/postgresql@16/bin/psql --version

# Node.js (untuk asset build Phoenix)
node --version      # >= 18
```

> **⚠️ PostgreSQL PATH:** Di macOS dengan Homebrew, `psql` dan `pg_isready` mungkin tidak ada di PATH default. Script di repo ini sudah pakai absolute path (`/opt/homebrew/opt/postgresql@16/bin/`). Kalau mau akses manual, tambahin ke PATH:
> ```bash
> export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
> ```


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

### Public Routes

| Route | Description | Status |
|-------|-------------|--------|
| `/` | Homepage | ✅ LiveView |
| `/work` | Work list | ✅ LiveView |
| `/work/:slug` | Work detail | ✅ LiveView |
| `/writing` | Writing list | ✅ LiveView |
| `/writing/:slug` | Writing detail | ✅ LiveView |
| `/products` | Products list | ✅ LiveView |
| `/products/:slug` | Product detail | ✅ LiveView |
| `/about` | About page | ✅ LiveView |
| `/now` | Now page | ✅ LiveView |
| `/contact` | Contact page | ✅ LiveView |

### Admin Routes

| Route | Description | Status |
|-------|-------------|--------|
| `/admin` | Dashboard | ✅ Backpex |
| `/admin/login` | Login | ✅ |
| `/admin/logout` | Logout | ✅ |
| `/admin/projects` | List/search projects | ✅ Backpex |
| `/admin/projects/new` | Create project | ✅ Backpex |
| `/admin/projects/:id/edit` | Edit project | ✅ Backpex |
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

## Frontend Notes

Frontend yang dipakai untuk development lokal adalah Phoenix LiveView:

```bash
cd personal_brand
mix phx.server
```

Buka:

```text
http://localhost:4000/
```

Asset publik ada di:

```txt
personal_brand/assets/css/app.css
personal_brand/assets/js/app.js
personal_brand/lib/personal_brand_web/live/public_live.ex
personal_brand/lib/personal_brand_web/components/layouts/public.html.heex
```

`public.html.heex` adalah LiveView layout fragment, bukan dokumen HTML penuh. Dokumen HTML utama tetap di `root.html.heex`.

Static prototype root lama (`index.html`, `styles.css`, `src/app.js`, `server.mjs`, dan root `package.json`) sudah tidak menjadi jalur development. Jangan pakai `npm run dev`/port `5173` untuk mengecek FE.

## Project Portfolio Workflow

Project portfolio adalah area paling penting untuk recruiter Software Engineer. Gunakan route publik berikut untuk QA:

```text
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Gunakan admin berikut untuk input dan edit:

```text
http://localhost:4000/admin/projects
http://localhost:4000/admin/projects/new
http://localhost:4000/admin/projects/<id>/edit
```

Field project saat ini:

| Field | Fungsi | Catatan |
|-------|--------|---------|
| `title` | Nama project | Contoh: `RajaOngkir iOS App`, `Postie`, `Personal Platform Website` |
| `slug` | URL publik `/work/:slug` | Boleh dikosongkan saat create; sistem auto-generate dari title dan auto-resolve duplicate. |
| `summary` | One-line recruiter pitch | Tampilkan impact singkat, bukan deskripsi panjang. |
| `description` | Overview case study | Menjawab konteks dan scope project. |
| `problem` | Problem yang diselesaikan | Harus mempertimbangkan kebutuhan user/business. |
| `solution` | Solusi teknis | Jelaskan architecture, decision, dan ownership. |
| `architecture_notes` | Catatan arsitektur | Jelaskan boundary, dependency direction, dan pattern penting. |
| `tradeoffs` | Trade-off teknis | Jelaskan constraint dan alasan keputusan. |
| `result` | Outcome per baris | Bisa diisi satu hasil per baris di admin. |
| `role` | Peran di project | Contoh: `Senior iOS Engineer`, `Mobile Engineering Lead`, `Full-stack Software Engineer`. |
| `ownership` | Scope tanggung jawab | Contoh: `Solo builder`, `Lead mobile engineer`, `iOS contributor`. |
| `project_type` | Tipe project | Controlled value: `professional_work`, `client_work`, `open_source`, `personal_project`, `architecture_demo`, `internal_tool`, `case_study`. |
| `platforms` | Platform per baris | Controlled value: `ios`, `android`, `flutter`, `macos`, `web`, `backend`, `cross_platform`. |
| `disciplines` | Discipline per baris | Controlled value: `ios_development`, `mobile_engineering_lead`, `mobile_devops`, `flutter_development`, `backend_engineering`, `frontend_engineering`, `fullstack_engineering`, `macos_development`, `architecture`, `performance_optimization`. |
| `tech_stack` | Teknologi per baris | Bisa diisi satu teknologi per baris di admin. |
| `year` | Tahun / periode | Contoh: `2025`, `2021-2024`. |
| `duration` | Durasi/periode tampil | Lebih fleksibel dari `year`, contoh: `2021-2026`, `Contract project`. |
| `status` | `draft`, `published`, `archived` | Hanya published yang ditampilkan publik. |
| `featured` | Prioritas tampil | Untuk project penting di home/work. |
| `sort_order` | Urutan manual | Angka lebih kecil tampil lebih dulu. |
| `impact_summary` | Ringkasan impact | Dipakai di card `/work` dan detail result. |
| `technical_highlights` | Highlight teknis per baris | Dipakai untuk menunjukkan seniority. |
| `metrics` | Metric/outcome per baris | Isi angka jika ada; boleh qualitative jika project proprietary. |
| `case_study_visibility` | Batas detail case study | `public`, `limited`, atau `private_summary`. |
| `demo_url` | Link demo/live | Optional. |
| `github_url` | Link repository | Optional, terutama untuk open-source/demo. |
| `app_store_url` | Link App Store | Optional untuk project iOS/mobile. |
| `cover_image` | Media cover | Pilih dari Admin > Media; tidak perlu copy UUID manual untuk workflow umum. |

Untuk portfolio yang ditujukan ke recruiter, project detail perlu menjawab:

- Role dan ownership kamu.
- Platform/discipline: iOS, Mobile Lead, Flutter, Backend, Frontend, macOS, atau Full-stack.
- Problem bisnis/produk yang diselesaikan.
- Architecture/technical decision yang menunjukkan seniority.
- Trade-off atau constraint penting.
- Result/impact yang bisa dipercaya.
- Screenshot/media dan link pendukung jika tersedia.

Yang sudah masuk di implementation slice portfolio:

- Slug auto-generate saat create jika kosong, termasuk duplicate suffix.
- Platform, discipline, project type, dan visibility divalidasi dengan controlled values.
- Cover media dipilih melalui Backpex relation field dari Admin > Media.
- Public `/work` punya filter berdasarkan discipline/platform.
- Project detail punya section ownership, technical approach, architecture notes, trade-offs, highlights, metrics, dan impact.

## Data Contract

Data dari prototype lama sudah dipindah ke database dan Phoenix assigns:

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
- ✅ Public homepage (LiveView)
- ✅ Public routes (work, writing, products, about, now, contact)
- ✅ old_web_classic theme styles in Phoenix assets
- ✅ Theme resolver via `site_settings.active_theme`

### Remaining
- ❌ Media upload
- ❌ SEO / OG tags
- ❌ RSS / sitemap
