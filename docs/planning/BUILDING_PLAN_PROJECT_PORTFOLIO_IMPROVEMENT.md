# Building Plan - Project Portfolio Improvement

## 0. Purpose

Plan ini fokus untuk memperbaiki fitur Projects sebagai portfolio utama untuk mencari kerja Software Engineer.

Area yang disentuh:

- Admin project list/create/edit di `http://localhost:4000/nunu-ops-7f3c/projects`
- Public project list di `http://localhost:4000/work`
- Public project detail di `http://localhost:4000/work/:slug`

Goal utama: recruiter bisa cepat memahami seniority, role, technical depth, business impact, dan evidence dari setiap project.

## 1. Current State

Project schema saat ini sudah mendukung case study dasar:

- `title`
- `slug`
- `summary`
- `description`
- `problem`
- `solution`
- `result`
- `role`
- `tech_stack`
- `year`
- `status`
- `featured`
- `demo_url`
- `github_url`
- `cover_image_id`

Admin sudah bisa:

- list projects
- create project
- edit project
- archive/delete melalui Backpex resource

Public sudah bisa:

- list published projects di `/work`
- render detail project by slug di `/work/:slug`
- render cover image dari media jika `cover_image_id` valid

## 2. Problem

Untuk kebutuhan recruiter, data project saat ini masih terlalu umum.

Masalah utama:

- Slug masih diketik manual sehingga rawan typo, redundant, dan tidak konsisten.
- Role, platform, discipline, dan tech stack masih free text.
- Admin belum membedakan project iOS, Flutter, Swift, Kotlin, Android, Backend, Frontend, dan Full-Stack secara rapi.
- Public `/work` belum punya grouping/filter yang membantu recruiter menemukan project relevan.
- Detail page belum cukup kuat sebagai case study senior engineer.
- Cover image masih input UUID manual, belum media picker.
- Project list belum menonjolkan impact, ownership, dan technical highlight.

## 3. Recruiter-Facing Project Model

Setiap project idealnya menjawab pertanyaan berikut:

- Apa project-nya?
- Kamu berperan sebagai apa?
- Platform/discipline apa yang dibuktikan?
- Problem bisnis/produk apa yang diselesaikan?
- Technical decision apa yang penting?
- Apa trade-off/constraint yang kamu hadapi?
- Apa hasil atau impact-nya?
- Bukti pendukungnya apa: screenshot, GitHub, demo, App Store, internal/proprietary note?

## 4. Target Taxonomy

### Disciplines

Taxonomy terkontrol untuk filter portfolio di `/work`. Diperbarui per 2026-05-13 — disederhanakan dan ditambah kategori automation/tooling:

- `mobile_developer` — Mobile Developer (umbrella untuk native mobile tanpa spesifik platform)
- `flutter_developer` — Flutter Developer
- `ios_developer` — iOS Developer
- `swift` — Swift (termasuk macOS development)
- `kotlin` — Kotlin
- `flutter` — Flutter (sebagai teknologi/bahasa, bukan role)
- `android_developer` — Android Developer
- `backend_developer` — Backend Developer
- `frontend_developer` — Frontend Developer
- `fullstack_developer` — Full-Stack Developer
- `ai_automation` — AI Automation (bot, agent, automated workflow yang pakai LLM)
- `cli_tooling` — CLI & Tooling (shell scripts, CLI tools, DevOps utilities)

Perubahan dari versi sebelumnya:

| Lama | Baru | Alasan |
|---|---|---|
| `ios_development` | `ios_developer` | Lebih role-focused |
| `mobile_engineering_lead` | `mobile_developer` | Lead bukan discipline, masuk ke field `role` |
| `mobile_devops` | `mobile_developer` | DevOps bukan discipline terpisah untuk portfolio |
| `flutter_development` | `flutter_developer` | Konsisten dengan format lain |
| `backend_engineering` | `backend_developer` | Lebih role-focused |
| `frontend_engineering` | `frontend_developer` | Lebih role-focused |
| `fullstack_engineering` | `fullstack_developer` | Lebih role-focused |
| `macos_development` | `swift` | macOS = Swift, cukup satu label |
| `architecture` | dropped | Bukan discipline, masuk ke `technical_highlights` |
| `performance_optimization` | dropped | Bukan discipline, masuk ke `technical_highlights` |

### Platforms

- `ios`
- `android`
- `flutter`
- `macos`
- `web`
- `backend`
- `cross_platform`

### Project Types

- `professional_work`
- `client_work`
- `open_source`
- `personal_project`
- `architecture_demo`
- `internal_tool`
- `case_study`

## 5. Proposed Schema Improvement

Tambah field baru ke `projects`:

```txt
project_type          string
company               string
client                string
platforms             array string
disciplines           array string
ownership             string
team_size             string
duration              string
impact_summary        string
technical_highlights  array string
architecture_notes    text
tradeoffs             text
metrics               array string
app_store_url         string
case_study_visibility string
sort_order            integer
```

Catatan:

- `case_study_visibility`: `public`, `limited`, `private_summary`
- Untuk project kantor yang proprietary, detail sensitif tidak perlu dibuka; cukup jelaskan impact, role, architecture pattern, dan constraints secara aman.
- `sort_order` membantu mengatur urutan project penting tanpa bergantung ke tanggal insert.

## 5.1 ERD Delta

ERD perlu berubah saat feature portfolio project ini diimplementasikan. Untuk kebutuhan urgent mencari kerja, rekomendasi paling pragmatis adalah memperluas table `projects` yang sudah ada, bukan membuat taxonomy table baru dulu.

Tambahan column di `projects`:

```txt
project_type              text nullable
company                   text nullable
client                    text nullable
platforms                 text[] not null default '{}'
disciplines               text[] not null default '{}'
ownership                 text nullable
team_size                 text nullable
duration                  text nullable
impact_summary            text nullable
technical_highlights      text[] not null default '{}'
architecture_notes        text nullable
tradeoffs                 text nullable
metrics                   text[] not null default '{}'
app_store_url             text nullable
case_study_visibility     text not null default 'public'
sort_order                integer not null default 0
```

Relasi dan index:

- `cover_image_id` tetap nullable FK ke `media.id`, mengikuti nama field di code saat ini.
- `slug` tetap unique dan stabil untuk public URL `/work/:slug`.
- Tambahkan index untuk `status`, `featured`, dan `sort_order`.
- Tambahkan GIN index untuk `platforms` dan `disciplines` jika filter `/work` sudah mulai dipakai aktif.
- `tags` tetap dipakai untuk keyword fleksibel seperti `SwiftUI`, `Phoenix LiveView`, atau `CI/CD`.

Future normalization:

- `project_media` bisa ditambahkan nanti jika setiap project butuh gallery lebih dari satu image.
- `platforms`, `disciplines`, dan join table baru bisa ditambahkan nanti jika taxonomy perlu dikelola dari admin. Untuk fase urgent, enum-array di changeset sudah cukup dan lebih cepat dikirim.
- Tag picker custom untuk array field bisa ditambahkan nanti. Untuk fase urgent, textarea satu item per baris lebih cepat, stabil, dan tetap tervalidasi oleh changeset.

## 6. Slug Strategy

Slug harus dibuat oleh sistem, bukan beban admin.

Target behavior:

1. Admin mengisi `title`.
2. Sistem auto-generate slug dari title.
3. Slug dinormalisasi menjadi lowercase kebab-case.
4. Jika slug sudah dipakai, sistem menambah suffix:

```txt
postie
postie-2
postie-3
```

5. Slug tetap bisa diedit manual di mode Advanced.
6. Slug stabil setelah publish kecuali admin sengaja mengubahnya.

Contoh:

| Title | Generated Slug |
|-------|----------------|
| RajaOngkir iOS App | `rajaongkir-ios-app` |
| iOS Distributed Modular Architecture | `ios-distributed-modular-architecture` |
| Personal Platform Website | `personal-platform-website` |
| Postie | `postie` |

## 7. Admin UX Plan

### Project Index

Admin `/nunu-ops-7f3c/projects` harus menampilkan:

- title
- status
- featured
- discipline/platform badges
- role
- year/duration
- updated_at
- quick links: view public, edit

### Create Project

Admin `/nunu-ops-7f3c/projects/new` harus dibagi menjadi section:

- Identity: title, generated slug, status, featured, sort_order
- Classification: project_type, platforms, disciplines, role
- Recruiter Pitch: summary, impact_summary
- Case Study: description, problem, solution, architecture_notes, tradeoffs
- Evidence: result, metrics, technical_highlights
- Media & Links: cover image picker, demo_url, github_url, app_store_url

### Edit Project

Admin `/nunu-ops-7f3c/projects/:id/edit` wajib nyaman untuk revisi data portfolio:

- Slug tampil tapi tidak menjadi field utama.
- Ada warning jika mengubah slug project published.
- Field array tetap bisa diedit satu item per baris, kecuali platform/discipline yang memakai checkbox taxonomy agar tidak terjadi typo atau redundant key.
- Preview link ke `/work/:slug`.
- Cover media dipilih dari media library, bukan copy UUID manual.

## 8. Public Work List Plan

Route: `/work`

Tampilan harus membantu recruiter scanning cepat:

- Featured projects di atas.
- Filter/tab:
  - All
  - Mobile
  - Flutter
  - iOS
  - Swift
  - Kotlin
  - Android
  - Backend
  - Frontend
  - Full-Stack
  - AI Automation
  - CLI & Tooling
- Setiap item menampilkan:
  - title
  - one-line summary
  - role
  - platform/discipline badges
  - tech stack singkat
  - impact summary
  - year/duration

## 9. Public Project Detail Plan

Route: `/work/:slug`

Detail page harus menjadi case study:

1. Hero
   - title
   - summary
   - role
   - platforms/disciplines
   - year/duration
   - links

2. Overview
   - konteks project
   - company/client jika boleh
   - visibility note jika proprietary

3. Problem
   - problem user/business/engineering

4. My Role & Ownership
   - tanggung jawab personal
   - team size atau collaboration model

5. Technical Approach
   - architecture
   - key decisions
   - tech stack

6. Implementation Highlights
   - bullets teknis yang menunjukkan seniority

7. Trade-offs
   - constraint dan alasan keputusan

8. Results
   - outcome
   - metrics
   - qualitative impact

9. Media
   - cover image
   - screenshots
   - optional diagrams

## 10. Priority Project Content From CV

Urutan input data yang disarankan:

1. RajaOngkir iOS App
2. iOS Distributed Modular Architecture / MealsApp
3. Postie
4. Prodia Booking Flow Optimization
5. Mobile DevOps CI/CD at Komerce
6. HRIS Partner App
7. Ping Checker
8. Bookmarker
9. Personal Platform Website

## 11. Implementation Slices

Status implementation per 2026-05-11:

- Slice 1: Done in code. Slug bisa auto-generate saat create, duplicate title diberi suffix, dan manual slug invalid tetap ditolak.
- Slice 2: Done in code. Field taxonomy/project portfolio sudah masuk migration, schema, changeset validation, dan tests.
- Slice 3: Done in code. Admin create/edit memakai Backpex field baru, form dibagi section, array field tetap textarea per baris, cover image memakai relation picker dari Media, ada warning slug published, dan row action untuk membuka public preview.
- Slice 4: Done in code. `/work` menampilkan card recruiter-focused, filter discipline/platform, sort order, dan pemisahan Featured Projects di atas daftar project lain.
- Slice 5: Done in code. `/work/:slug` punya section ownership, technical approach, architecture notes, trade-offs, implementation highlights, results, metrics, dan links.
- Slice 6: Done for initial seed. Seed portfolio berisi 5 project prioritas dari CV dengan copy Bahasa Indonesia dan batas detail proprietary.
- Follow-up admin standardization per 2026-05-12: Done in code for adjacent content resources. Posts, Products, Media, Site Settings, and Themes now follow the same admin baseline used by Projects: visible row actions, placeholders/help text, changeset validation path, clearer boolean controls, and safer structured textarea handling where schema stores maps/arrays.

### Slice 1 - Slug Generation

Output:

- slug generator pure function
- unique slug resolver
- tests for title to slug conversion
- admin create can omit slug
- edit keeps existing slug stable

Acceptance:

- `RajaOngkir iOS App` becomes `rajaongkir-ios-app`
- duplicate title becomes `rajaongkir-ios-app-2`
- invalid manual slug is rejected
- published project slug does not change unless explicitly edited

### Slice 2 - Project Taxonomy Fields

Output:

- migration for project_type, platforms, disciplines, ownership, impact_summary, etc.
- changeset validation for controlled taxonomy values
- tests for valid/invalid taxonomy

Acceptance:

- project can be categorized as Mobile, Flutter, iOS, Swift, Kotlin, Android, Backend, Frontend, or Full-Stack
- public data reads include taxonomy fields

### Slice 3 - Admin Project Form

Output:

- admin create/edit form sections
- edit project workflow
- checkbox taxonomy untuk platform/discipline
- textarea fallback untuk array evidence seperti result, metrics, dan technical_highlights
- safer cover media selection path

Acceptance:

- admin can create project without typing slug manually
- admin can edit project case study fields
- admin can preview public URL
- admin does not need to copy raw media UUID for common cover image workflow
- admin can edit/delete from index row actions without opening a confusing bulk-selection workflow

### Slice 4 - Public Work List

Output:

- recruiter-focused project list
- discipline/platform filters
- featured project ordering

Acceptance:

- `/work` clearly separates Mobile, Flutter, iOS, Swift, Kotlin, Android, Backend, Frontend, Full-Stack
- cards/list show role, impact, stack, and year
- empty states remain clean

### Slice 5 - Public Project Detail

Output:

- richer case study detail layout
- sections for ownership, technical approach, trade-offs, metrics
- media rendering improvements

Acceptance:

- `/work/personal-platform-website` renders richer detail if fields exist
- older projects still render with fallback when new fields are empty
- no public page crash if taxonomy/media fields are missing

### Slice 6 - Seed/Initial Portfolio Data

Output:

- curated portfolio entries based on CV
- public-safe descriptions in Indonesian
- links/media where available

Acceptance:

- at least 5 recruiter-ready projects are published
- all project copy uses Bahasa Indonesia except technology names
- proprietary work avoids confidential details

## 12. Documentation Updates

Docs to update as implementation progresses:

- PRD: recruiter-focused portfolio requirements and project case study UX.
- TRD: schema additions, slug strategy, taxonomy validation, admin/public routes.
- LOCAL_SETUP: admin create/edit workflow and route QA.
- This building plan: status and slice completion notes.

## 13. Test Plan

Minimum tests:

- Project changeset validates taxonomy and URLs.
- Slug generation handles title normalization and duplicates.
- `/work` lists published projects only.
- `/work/:slug` renders published detail and returns not found for draft/missing.
- Admin project new/edit routes render after login.
- Array fields still support newline-separated admin input.

## 14. Risks

- Over-modeling too early can slow urgent job-search needs.
- Proprietary work needs careful wording.
- Backpex custom forms may need extra care for complex inputs.
- Media picker may be larger than expected if Backpex relation UX is limited.

## 15. Recommended Urgent Cut

Untuk kebutuhan cari kerja cepat, kerjakan dulu:

1. Auto slug.
2. Discipline/platform fields.
3. Admin edit-friendly project form.
4. Public `/work` filter/grouping.
5. Public detail sections: ownership, technical approach, trade-offs, impact.
6. Input 5 project prioritas dari CV.
