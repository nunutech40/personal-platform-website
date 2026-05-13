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

Untuk agent/automation yang tidak boleh “stuck” menunggu proses foreground, jalankan Phoenix di background:

```bash
./scripts/start-local.sh --daemon
```

Mode foreground (`./scripts/start-local.sh`) memang akan terus berjalan sampai dihentikan dengan `Ctrl+C`. Itu normal untuk terminal manusia, tapi tidak ideal untuk agent yang sedang menjalankan command sekali jalan.

---

## Database

### Connection

Konfigurasi ada di `personal_brand/config/dev.exs`:

```elixir
config :personal_brand, PersonalBrand.Repo,
  username: "nununugraha",
  password: "",
  hostname: "localhost",
  database: "personal_brand_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

### Useful Commands

```bash
# Masuk ke database
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev

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

# Reset database dari dalam folder personal_brand
mix ecto.reset
```

### Clean Reset Workflow

Untuk mengulang development dari awal dan membersihkan data admin yang sudah kotor, gunakan script repo dari root project:

```bash
./scripts/reset-local-db.sh --yes
```

Perilaku default:

- Hanya berjalan untuk `MIX_ENV=dev`.
- Drop dan recreate `personal_brand_dev`.
- Jalankan migration.
- Tidak menjalankan seed; database dibiarkan kosong setelah migration.
- Kalau Phoenix sedang berjalan di `localhost:4000`, script akan stop dulu sebelum drop DB lalu start lagi via daemon.
- PostgreSQL tetap dibiarkan hidup.

Opsi tambahan:

```bash
# Reset DB + hapus uploaded files lokal
./scripts/reset-local-db.sh --yes --with-uploads

# Reset DB lalu isi demo seed eksplisit
./scripts/reset-local-db.sh --yes --seed

# Reset DB tapi jangan restart Phoenix
./scripts/reset-local-db.sh --yes --no-restart
```

Setelah reset, jika ingin memastikan project `Personal Platform Website` memakai copy portfolio yang paling recruiter-ready, jalankan SQL fallback:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-personal-platform-project.sql
```

Kapan pakai database yang sama vs beda database:

- Pakai `personal_brand_dev` + reset script untuk kerja harian. Ini paling simpel dan cocok saat ingin balik ke baseline bersih.
- Pakai DB baru hanya kalau butuh eksperimen paralel yang tidak boleh merusak data dev utama. Untuk itu buat config sementara via env/config terpisah, bukan mengubah `dev.exs` setiap hari.
- Test suite sudah memakai database terpisah: `personal_brand_test`, jadi reset dev tidak mengganggu test database.

### Seed Data

File: `personal_brand/priv/repo/seeds.exs`

Berisi data dummy untuk development:
- 1 admin account (admin / admin123)
- 4 themes (old_web_classic, simple, us_builder, premium_dark)
- 1 site_settings
- 5 portfolio projects prioritas dari CV dan Personal Platform Website
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
| `/admin/site-settings` | Site settings singleton edit shortcut | ✅ Backpex |
| `/admin/themes` | Theme settings | ✅ Backpex |

---

## Scripts

```bash
./scripts/start-local.sh           # Start PostgreSQL + Phoenix in foreground
./scripts/start-local.sh --daemon  # Start PostgreSQL + Phoenix in background
./scripts/status-local.sh          # Check PostgreSQL, Phoenix, HTTP, and DB status
./scripts/stop-local.sh            # Stop Phoenix only
./scripts/stop-local.sh --with-postgres  # Stop Phoenix and request PostgreSQL service stop
```

`start-local.sh` aman dijalankan berulang. Kalau port `4000` sudah dipakai Phoenix, script akan menampilkan PID yang sedang jalan dan keluar tanpa membuka server kedua.

Log untuk mode daemon:

```txt
personal_brand/tmp/local-server.log
```

Catatan: mode daemon memakai Erlang VM detached supaya server tetap hidup setelah command agent selesai. File log di atas mencatat start attempt; untuk health check utama tetap gunakan `./scripts/status-local.sh`.

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
| `role` | Peran di project | Bisa ketik manual; form memberi suggestion dari DB + role umum seperti `Software Engineer`, `Backend Engineer`, `Mobile Engineer`, `iOS Developer`. |
| `ownership` | Scope tanggung jawab | Bisa ketik manual; form memberi suggestion dari DB + scope umum seperti `Feature owner`, `Solo builder`, `Technical lead`. |
| `project_type` | Tipe project | Controlled value: `professional_work`, `client_work`, `open_source`, `personal_project`, `architecture_demo`, `internal_tool`, `case_study`. |
| `platforms` | Checkbox taxonomy di admin | Controlled value: `ios`, `android`, `flutter`, `macos`, `web`, `backend`, `cross_platform`. |
| `disciplines` | Checkbox taxonomy di admin | Controlled value: `mobile_developer`, `flutter_developer`, `ios_developer`, `swift`, `kotlin`, `flutter`, `android_developer`, `backend_developer`, `frontend_developer`, `fullstack_developer`. |
| `tech_stack` | Teknologi/library per baris | Bisa diisi satu teknologi per baris di admin. Detail work menampilkannya sebagai `Tech & Libraries` supaya recruiter cepat melihat exposure stack. |
| `year` | Tahun / periode | Contoh: `2025`, `2021-2024`. |
| `duration` | Durasi/periode tampil | Lebih fleksibel dari `year`, contoh: `2021-2026`, `Contract project`. |
| `sort_date` | Tanggal sortir internal | Format `YYYY-MM-DD`; dipakai untuk urutan tahun-bulan, tidak tampil publik. |
| `status` | `draft`, `published`, `archived` | Hanya published yang ditampilkan publik. |
| `featured` | Prioritas tampil | Untuk project penting di home/work. |
| `sort_order` | Urutan manual | Angka lebih kecil tampil lebih dulu; jika sama, `sort_date` paling baru tampil lebih atas. |
| `impact_summary` | Ringkasan impact | Dipakai di card `/work` dan detail result. |
| `technical_highlights` | Highlight teknis per baris | Dipakai untuk menunjukkan seniority. |
| `metrics` | Metric/outcome per baris | Isi angka jika ada; boleh qualitative jika project proprietary. |
| `case_study_visibility` | Batas detail case study | `public`, `limited`, atau `private_summary`. |
| `demo_url` | Link demo/live | Optional. |
| `github_url` | Link repository | Optional, terutama untuk open-source/demo. |
| `app_store_url` | Link App Store | Optional untuk project iOS/mobile. |
| `cover_image` | Media cover | Pilih dari Admin > Media; tidak perlu copy UUID manual untuk workflow umum. |
| `certificate_media` | Media PDF sertifikat | Pilih dari Admin > Media; tampil sebagai `Download Certificate` di detail work. |

Untuk portfolio yang ditujukan ke recruiter, project detail perlu menjawab:

- Role dan ownership kamu.
- Platform/discipline: Mobile, Flutter, iOS, Swift, Kotlin, Android, Backend, Frontend, atau Full-Stack.
- Problem bisnis/produk yang diselesaikan.
- Architecture/technical decision yang menunjukkan seniority.
- Trade-off atau constraint penting.
- Result/impact yang bisa dipercaya.
- Screenshot/media dan link pendukung jika tersedia.

Yang sudah masuk di implementation slice portfolio:

- Slug auto-generate saat create jika kosong, termasuk duplicate suffix.
- Platform, discipline, project type, dan visibility divalidasi dengan controlled values.
- Platform dan discipline memakai checkbox grid di admin supaya tidak perlu mengetik taxonomy manual.
- Field teks seperti role, ownership, team size, company, dan client memakai suggestion dari data DB + fallback umum yang recruiter-friendly.
- Cover media dipilih melalui Backpex relation field dari Admin > Media.
- Public `/work` punya filter berdasarkan discipline/platform.
- Project detail punya section ownership, technical approach, architecture notes, trade-offs, highlights, metrics, dan impact.

## Posts and Products Admin Workflow

Posts dan Products memakai standar admin yang sama dengan Projects untuk CRUD harian:

- Slug bisa dikosongkan saat create dan akan dibuat otomatis dari title.
- Index punya quick actions: `Ubah`, `Lihat Publik`, dan `Hapus`.
- Boolean `featured` memakai segmented control `Biasa/Unggulan`.
- Array-like field (`post.tags`, `product.included`) bisa diisi satu item per baris; post tags juga menerima koma.
- Form punya placeholder dan help text untuk mengurangi input yang ambigu.
- Product `checkout_url` boleh kosong; jika diisi harus diawali `http://` atau `https://`.
- Post monetization is planned but not implemented yet. Planned access modes: `free`, `tips`, and `paid`.
- Free posts will use global Saweria / Buy Me Coffee links from Site Settings.
- Tips and paid posts should use Midtrans when proper payment gating is implemented. Do not add Xendit fields unless a Xendit account exists.
- Paid/tips unlock should avoid customer login at first: use email + order + access token.

## Media, Site Settings, and Themes Admin Workflow

Media dan Themes mengikuti standar admin yang sama: index punya aksi cepat, form punya section yang jelas, placeholder, help text, dan validasi changeset. Site Settings adalah pengecualian singleton: route index langsung membuka edit form record aktif.

Media:

- `/admin/media` menampilkan preview thumbnail untuk gambar, link buka file, edit, dan delete.
- `/admin/media/new` bisa upload file lewat Backpex upload field atau mengisi metadata manual.
- `filename` dan `url` wajib. URL harus diawali `http://`, `https://`, atau `/uploads/`.
- `alt_text` perlu diisi untuk gambar portfolio agar screenshot tetap punya konteks aksesibilitas.

Site Settings:

- `/admin/site-settings` langsung membuka edit form singleton Site Settings; tidak ada list, new, atau delete flow untuk resource ini.
- Site Settings mengatur identitas website, CTA homepage, profil, halaman About/Now, support links, payment reference links, social links, active theme, dan daftar featured ID opsional.
- Data personal website seperti nama, headline homepage, bio, email, lokasi, dan link sosial hidup di tabel `site_settings`. Setelah reset kosong, restore satu record Site Settings dari seed/SQL fallback, lalu edit record tersebut dari admin.
- `active_theme` dipilih dari theme yang ada di database. Kalau belum ada theme, fallback admin menampilkan `old_web_classic`.
- `social_links` diisi satu link per baris dengan format `Label=URL`, contoh `GitHub=https://github.com/username`.
- `featured_project_ids` dan `featured_product_ids` bisa diisi satu UUID per baris. Untuk workflow portfolio utama, prioritas tampilan tetap lebih praktis lewat flag `featured` dan `sort_order` di resource Project/Product.
- About page content is CMS-managed through `about_intro`, `about_focus`, `about_tools`, and `about_values`.
- Now page content is CMS-managed through `now_building`, `now_learning`, `now_focus`, and `now_updated_at`.
- Support links live here too: `saweria_url`, `buy_me_coffee_url`, `tips_cta_title`, and `tips_cta_body`.
- Optional Xendit reference links can be stored as `xendit_checkout_url` and `xendit_webhook_url`, but Midtrans remains the planned payment provider for real paid content/product flows.

Themes:

- `/admin/themes` mengelola registry theme.
- `key` harus lowercase alphanumeric dengan underscore, contoh `old_web_classic`.
- `config` bisa dikosongkan atau diisi JSON object valid, contoh `{"accent_color":"#111827"}`.
- Toggle `Aktif di registry` menandai theme tersedia. Theme publik yang dipakai tetap dipilih lewat Site Settings > Active Theme.

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
- ✅ Media upload/local storage workflow in admin
- ✅ Admin CRUD polish for projects, posts, products, media, site settings, and themes

### Remaining
- ❌ SEO / OG tags
- ❌ RSS / sitemap
