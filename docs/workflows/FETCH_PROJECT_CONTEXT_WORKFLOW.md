# Fetch Project Context Workflow

Gunakan workflow ini saat membuka chat baru atau pindah AI sebelum meminta perubahan kode.

Tujuannya: AI memahami project secara menyeluruh dengan input token seminimal mungkin. Jangan langsung membaca semua file. Ambil peta dulu, lalu baca file yang benar-benar relevan.

## Output yang Diharapkan

Sebelum mengubah kode, AI harus memberi ringkasan singkat:

- App ini apa dan sedang dikerjakan untuk tujuan apa.
- Area yang akan disentuh.
- File utama yang relevan.
- Data/schema/route/test yang perlu dijaga.
- Risiko perubahan dan test minimal yang harus dijalankan.

## Step 1 — Baca Peta Project

Jalankan dari repo root:

```bash
pwd
git status --short
rg --files -g 'README*' -g 'docs/**/*.md' -g 'personal_brand/lib/**/*.ex' -g 'personal_brand/test/**/*.exs' | sort
```

Baca dokumen ini lebih dulu:

```txt
docs/README.md
docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md
docs/technical/LOCAL_SETUP.md
docs/technical/VPS_DEPLOYMENT_PERSONAL_BRAND.md
docs/deployment/DEPLOY_PREP_CHECKLIST.md
docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md
docs/planning/BUILDING_PLAN_PROJECT_PORTFOLIO_IMPROVEMENT.md
docs/planning/BUILDING_PLAN_UNIFIED_SEARCH.md
docs/standards/CODING_AND_TESTING_STANDARDS.md
```

Aturan hemat token:

- Baca heading dan section relevan dulu, bukan seluruh dokumen panjang.
- Kalau task spesifik admin project, prioritaskan section project/admin/Backpex.
- Kalau task spesifik public page, prioritaskan route, LiveView, component, dan test terkait.

## Step 2 — Temukan Entry Point

Gunakan search terarah:

```bash
rg -n "live_resource|Backpex|ProjectResource|PostResource|ProductResource|MediaResource|SiteSettingResource|ThemeResource" personal_brand/lib personal_brand/test
rg -n "defmodule PersonalBrand.Content|schema \"projects\"|schema \"posts\"|schema \"products\"|schema \"media\"|schema \"site_settings\"|schema \"themes\"" personal_brand/lib
rg -n "live \"/work|nunu-ops-7f3c|ProjectLive|PublicLive|work/:slug|project" personal_brand/lib/personal_brand_web
```

Untuk task portfolio project, file yang biasanya relevan:

```txt
personal_brand/lib/personal_brand/content/project.ex
personal_brand/lib/personal_brand/content.ex
personal_brand/lib/personal_brand_web/live/admin/project_resource.ex
personal_brand/lib/personal_brand_web/live/public_live.ex
personal_brand/priv/repo/seeds.exs
personal_brand/test/personal_brand/content/project_test.exs
personal_brand/test/personal_brand_web/live/admin/project_resource_test.exs
personal_brand/test/personal_brand_web/live/public_live_test.exs
```

Untuk task search, file yang relevan:

```txt
personal_brand/lib/personal_brand/content.ex (search/1, search_projects, search_posts, search_products)
personal_brand/lib/personal_brand_web/live/public_live.ex (handle_event "live_search", search_page component)
personal_brand/assets/css/app.css (search-page, search-loading styles)
docs/planning/BUILDING_PLAN_UNIFIED_SEARCH.md
```

Untuk task disciplines/taxonomy, file yang relevan:

```txt
personal_brand/lib/personal_brand/content/project.ex (@disciplines, @labels, label_for/1)
personal_brand/lib/personal_brand_web/live/public_live.ex (work_filters, work_filter_counts)
personal_brand/lib/personal_brand_web/live/admin/project_resource.ex (checkbox taxonomy)
docs/planning/BUILDING_PLAN_PROJECT_PORTFOLIO_IMPROVEMENT.md (taxonomy section)
docs/workflows/INPUT_PROJECT_DATA_WORKFLOW.md (categorization rules)
```

## Step 3 — Baca Secara Bertingkat

Urutan baca:

1. Schema dan changeset.
2. Context function yang dipakai public/admin.
3. Route/LiveView/component yang render UI.
4. Admin resource/form.
5. Tests existing.
6. Seed/data hanya jika behavior tergantung data.

Jangan baca semua file dalam satu tarikan kalau belum perlu. Pakai `rg` untuk menemukan fungsi/field, lalu `sed -n` pada range kecil.

## Step 4 — Konfirmasi Pemahaman

AI harus menulis ringkasan seperti:

```txt
Konteks yang kupakai:
- Domain:
- Entry points:
- Schema/data contract:
- UI/admin contract:
- Tests yang akan dijalankan:
- Risiko:
```

Setelah itu baru implement.

## Step 5 — Test Minimal

Pilih test berdasarkan area:

```bash
# Context/schema changes
cd personal_brand
mix test test/personal_brand/content/<resource>_test.exs

# Admin Backpex changes
mix test test/personal_brand_web/live/admin

# Public route changes
mix test test/personal_brand_web/live

# Sebelum handoff/push
mix format --check-formatted
mix test
```

## Notes untuk AI

- Jangan pakai static frontend lama atau port `5173`.
- App lokal utama adalah Phoenix LiveView di `http://localhost:4000`.
- Jangan stop server setelah push kecuali user minta.
- Jangan reset database kecuali user eksplisit minta.
- Kalau user minta push, ikuti `docs/workflows/PUSH_WORKFLOW.md`.
- PRD/TRD .docx mungkin outdated — gunakan planning docs .md sebagai source of truth.
- Disciplines taxonomy: 12 values (`mobile_developer`, `flutter_developer`, `ios_developer`, `swift`, `kotlin`, `flutter`, `android_developer`, `backend_developer`, `frontend_developer`, `fullstack_developer`, `ai_automation`, `cli_tooling`). Lihat aturan kategorisasi di `docs/workflows/INPUT_PROJECT_DATA_WORKFLOW.md`.
- Public pages pakai load more (9 per page) untuk `/work`, `/writing`, `/products`.
- `/search` adalah unified search across projects, posts, products via PostgreSQL ILIKE.
- Navigation: Home, Work, Writing, Products, About, Now, Contact, Search.
- Production domain is `https://nunugraha.web.id`; VPS is `nunuadmin@103.181.143.73`; systemd service is `personal-brand`.
- Private ops/admin path is `/nunu-ops-7f3c` (module/folder names may still use `admin` internally).
- Production admin username is `nunuops`; admin password reminder is local Mac file `/private/tmp/personal_brand_prod_secrets.txt`, line 2. Never commit that file.
- Production data sync rule: if local CMS data must appear in production, restore both `personal_brand_dev` PostgreSQL dump and `personal_brand/priv/static/uploads`.
- Current full test count is 263.
