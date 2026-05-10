# Personal Brand Platform Agent Kit

Agent kit ini berisi instruksi kerja untuk AI coding agent yang membangun Personal Brand Platform.

Target utama:

```txt
Phoenix LiveView + Supabase + themeable personal brand platform
```

## How To Use

Untuk fresh/new chat, agent harus membaca:

1. `../README.md`
2. `../docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md`
3. `../docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md`
4. skill yang relevan di `.agents/skills/*/SKILL.md`

Untuk chat yang sudah punya konteks dan baru meneruskan task kecil:

```txt
1. Jangan baca ulang semua dokumen.
2. Baca ulang hanya section building plan yang relevan dengan slice.
3. Baca skill yang relevan.
4. Cek git status dan file sekitar perubahan.
```

## Skill Design Direction

Skill sebaiknya seperti Flutter skills: bukan “fitur produk X”, tapi kemampuan repetitif yang bisa dipakai berkali-kali.

Contoh pola yang benar:

```txt
building forms
working with database schemas
implementing routing
theming interfaces
handling file uploads
integrating external checkout
testing public pages
```

Contoh pola yang terlalu spesifik:

```txt
build products page for Nunu
make Midtrans for this project
create admin dashboard exactly like current mockup
```

## Recommended Skill Set

Gunakan skill generik ini untuk pekerjaan berikutnya:

```txt
pbp-coding-elixir-functionally
pbp-architecting-phoenix-platforms
pbp-modeling-content-data
pbp-building-liveview-pages
pbp-building-admin-forms
pbp-theming-public-interfaces
pbp-managing-publishing-workflows
pbp-handling-media-assets
pbp-integrating-external-checkout
pbp-testing-and-qa
```

Untuk pekerjaan backend, Supabase, Phoenix contexts, LiveView event handlers, atau integrasi eksternal, mulai dari `pbp-coding-elixir-functionally`, lalu lanjutkan ke skill domain yang relevan.

Skill lama yang feature-specific sudah dihapus. Kalau butuh detail project seperti field, route, dan phase, ambil dari root docs:

```txt
../docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md
../docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md
```

## Work Packet Template

Pakai format ini saat meminta AI lain mengerjakan slice tertentu:

```txt
Pakai skill: <skill-1>, <skill-2>

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

## Usage Examples

### 1. Fresh Chat: Start Phoenix Foundation

```txt
Baca docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md,
baca docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md,
lalu pakai skill pbp-coding-elixir-functionally dan pbp-architecting-phoenix-platforms.

Kerjakan Work Packet:
Phase: Phase 0
Slice: Slice 0.1 - Repo and Phoenix setup
Goal: Setup Phoenix LiveView app sebagai fondasi final MVP.
Acceptance checks:
- Phoenix app bisa run local
- struktur context awal sesuai architecture
- prototype static tidak hilang tanpa alasan
- docs diupdate kalau ada perubahan struktur
```

### 2. Continue With Database Foundation

```txt
Gunakan skill:
- pbp-coding-elixir-functionally
- pbp-modeling-content-data

Kerjakan Work Packet:
Phase: Phase 1
Slice: Slice 1.1 - Core identity/settings/theme schema
Goal: Buat migrations, schemas, changesets, contexts, dan seed data untuk profiles, site_settings, themes.
Read first:
- docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md bagian Slice 1.1
- docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md bagian contexts dan FP philosophy
Acceptance checks:
- migrations ada
- schemas + changesets ada
- context API explicit
- seed active_theme = old_web_classic
- tests minimal untuk changeset/context
```

### 3. Port Public Homepage

```txt
Gunakan skill:
- pbp-coding-elixir-functionally
- pbp-building-liveview-pages
- pbp-theming-public-interfaces

Kerjakan Work Packet:
Phase: Phase 2 + Phase 3
Slice: Slice 2.1 - Public layout and homepage
Goal: Port homepage dummy dari src/app.js ke Phoenix LiveView old_web_classic.
Do not touch:
- admin CRUD
- Midtrans proper integration
- future commerce tables
Acceptance checks:
- / render dari context/seed data
- theme module tidak query Repo
- navigation Work/Writing/Products/About/Now muncul
- tidak ada nama dobel di homepage
```

### 4. Continue Small Known Task

```txt
Lanjutkan slice yang terakhir.
Jangan baca ulang semua docs.
Cek git status, baca section slice yang relevan saja, pakai skill pbp-testing-and-qa sebelum selesai.
```

### 5. Push Changes

```txt
Pakai docs/workflows/PUSH_WORKFLOW.md
Commit message: "Set up Phoenix LiveView foundation"
```

## Skill Quality Checklist

Setiap `SKILL.md` harus:

- punya frontmatter `name` dan `description`
- menjelaskan kapan skill dipakai
- memberi workflow yang repeatable
- memberi checklist verifikasi
- menghindari detail konten yang terlalu hardcoded
- mengarahkan agent ke dokumen project jika butuh field/route spesifik
- tetap pendek; detail besar sebaiknya masuk reference file terpisah
