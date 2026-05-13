# Project Articulation Workflow

Workflow ini dipakai untuk meminta AI membantu mengubah sebuah project menjadi portfolio case study yang layak dibaca recruiter Software Engineer.

## Goal

Output akhirnya bukan sekadar deskripsi project, tapi narasi yang menjawab:

- Apa problem yang diselesaikan.
- Apa role dan ownership kamu.
- Apa technical decision yang menunjukkan seniority.
- Apa stack dan platform yang relevan.
- Apa result atau impact yang bisa dipercaya.
- Apa batas detail yang aman jika project bersifat proprietary.

## Context yang Harus Dibaca AI

Sebelum menulis copy project, minta AI membaca:

1. PRD/product docs: `docs/product`
2. TRD/technical docs: `docs/technical`
3. Architecture docs: `docs/architecture`
4. Planning docs yang relevan: `docs/planning`
5. Real implementation:
   - schema/context terkait
   - public route yang menampilkan project
   - admin form/resource yang dipakai input
   - tests yang memvalidasi behavior
6. README/local setup jika project punya cara run khusus.

Prompt singkat:

```txt
Baca PRD, TRD, architecture docs, planning docs, dan real implementation project ini.
Artikulasikan project ini sebagai portfolio untuk recruiter Software Engineer.
Gunakan Bahasa Indonesia untuk deskripsi, tapi nama teknologi tetap apa adanya.
Fokus pada role, ownership, problem, solution, technical depth, trade-off, result, metrics, dan stack.
Jangan mengarang angka. Kalau tidak ada angka, tulis qualitative impact yang bisa dipercaya.
```

## Field Mapping untuk Admin Project

Isi field admin dengan pola berikut:

| Field | Isi yang Baik |
|---|---|
| `title` | Nama project yang jelas dan mudah dicari. |
| `slug` | URL stabil, lowercase, hyphenated. Kosongkan saat create jika ingin auto-generate. |
| `summary` | One-liner recruiter pitch. Maksimal 1-2 kalimat. |
| `description` | Overview: konteks project, user, scope, dan kenapa penting. |
| `problem` | Masalah nyata: user pain, business pain, atau engineering pain. |
| `solution` | Pendekatan produk/teknis yang kamu ambil. |
| `role` | Role kamu yang recruiter pahami, misalnya `Full-stack Software Engineer`, `iOS Developer`, `Mobile Engineering Lead`. |
| `ownership` | Scope kerja kamu: solo builder, feature owner, technical lead, contributor, dll. |
| `team_size` | Solo, small team, cross-functional team, contractor, atau komposisi tim. |
| `project_type` | `professional_work`, `client_work`, `open_source`, `personal_project`, `architecture_demo`, `internal_tool`, atau `case_study`. |
| `platforms` | Platform yang dikerjakan: `ios`, `android`, `flutter`, `macos`, `web`, `backend`, `cross_platform`. |
| `disciplines` | Keahlian yang ditunjukkan: `mobile_developer`, `flutter_developer`, `ios_developer`, `swift`, `kotlin`, `flutter`, `android_developer`, `backend_developer`, `frontend_developer`, `fullstack_developer`, `ai_automation`, `cli_tooling`. |
| `tech_stack` | Satu teknologi per baris. Jangan campur dengan buzzword yang tidak dipakai nyata. |
| `architecture_notes` | Boundary, module, dependency direction, data flow, atau reasoning arsitektur. |
| `tradeoffs` | Keputusan yang sengaja diambil beserta alasannya. |
| `technical_highlights` | Bullet teknis yang menunjukkan kedalaman implementasi. |
| `result` | Outcome per baris. Bisa qualitative jika tidak ada angka. |
| `metrics` | Angka jika ada. Jika tidak ada, gunakan fakta verifiable seperti test count, routes, coverage area. |
| `case_study_visibility` | `public`, `limited`, atau `private_summary`. |
| `featured` + `sort_order` | Gunakan untuk menentukan prioritas tampil di `/work`. |

## Pattern Penulisan

Gunakan urutan berpikir ini:

1. **Extract facts**
   Ambil fakta dari docs dan code: domain, stack, route, schema, tests, deployment, user flow.

2. **Infer safely**
   Bedakan fakta dan inferensi. Contoh: “test suite passing” adalah fakta jika sudah diuji; “meningkatkan maintainability” adalah inferensi dari architecture/validation.

3. **Frame for recruiter**
   Jangan mulai dari teknologi. Mulai dari masalah dan ownership, lalu buktikan dengan teknologi.

4. **Show technical depth**
   Pilih 3-6 highlight yang benar-benar ada di project: schema design, validation, admin UX, route structure, reset workflow, tests, performance, architecture boundary.

5. **Handle proprietary limits**
   Untuk project kantor/klien, tulis problem class dan pendekatan teknis tanpa membuka data internal.

6. **Make it scannable**
   Summary pendek, detail panjang di `description/problem/solution`, bullet di `result/metrics/highlights`.

## Pattern untuk Technical Approach, Architecture Notes, dan Trade-offs

Tiga field ini sering terlihat buruk kalau ditulis sebagai satu paragraf panjang. Pakai pembagian berikut:

```txt
Technical Approach:
Paragraf 1: pendekatan implementasi utama.

Paragraf 2: detail teknis penting, integration point, atau workflow yang menunjukkan ownership.

Architecture Notes:
Kalimat pengantar tentang boundary/struktur.
1. Keputusan arsitektur pertama dan alasannya.
2. Keputusan arsitektur kedua dan alasannya.
3. Keputusan arsitektur ketiga dan alasannya.

Trade-offs:
Kalimat pengantar tentang constraint.
1. Pilihan yang diambil, alternatif yang tidak dipilih, dan konsekuensinya.
2. Pilihan berikutnya, alasan, dan follow-up.
```

Prinsipnya:

- `solution` menjawab **how it was built**.
- `architecture_notes` menjawab **how it is structured**.
- `tradeoffs` menjawab **why this choice, not another choice**.
- Jangan mengulang stack list di tiga field ini; gunakan stack hanya jika membantu menjelaskan keputusan.
- Public renderer memecah blank line menjadi paragraf dan numbering menjadi ordered list, jadi draft harus sengaja memakai struktur itu.

## Quality Checklist

Sebelum publish:

- `summary` bisa dipahami recruiter dalam 5 detik.
- `role` dan `ownership` tidak ambigu.
- `problem` tidak generik.
- `solution` menyebut keputusan teknis nyata.
- `tech_stack` sesuai implementation.
- `result` tidak mengarang angka.
- `case_study_visibility` sesuai sensitivitas project.
- Public detail `/work/:slug` enak discan tanpa harus membuka admin.

## Input UX Notes

Saat mengisi project panjang seperti Personal Platform Website, field admin yang paling rawan melelahkan adalah `description`, `problem`, `solution`, `architecture_notes`, `tradeoffs`, `technical_highlights`, `result`, dan `metrics`.

Standar kerja yang disarankan:

- Tulis artikulasi project di draft Markdown dulu.
- Pecah ke field admin setelah struktur narasinya stabil.
- Pakai SQL fallback untuk restore baseline copy setelah reset.
- Pakai admin browser untuk final review/edit kecil, terutama typo, status, featured, sort order, dan cover image.

Improvement produk yang masih bisa ditambahkan nanti:

- Import project dari Markdown/JSON.
- Preview detail project langsung di samping form.
- Save draft tanpa perlu scroll panjang.
- Field helper yang menunjukkan contoh per project type.
- AI-assisted “generate case study from docs/code” langsung dari admin.

## SQL Fallback

Untuk project Personal Platform Website, repo menyediakan SQL upsert manual:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-personal-platform-project.sql
```

Gunakan SQL ini setelah reset DB jika ingin memastikan copy project Personal Platform Website kembali ke versi recruiter-ready tanpa input ulang manual.
