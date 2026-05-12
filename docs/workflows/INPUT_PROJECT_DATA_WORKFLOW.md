# Input Project Data Workflow

Gunakan workflow ini saat meminta AI menginput project portfolio lewat browser admin.

Targetnya: data project masuk ke CMS dengan artikulasi yang layak untuk recruiter Software Engineer, bukan sekadar form terisi.

## Prasyarat

Pastikan app jalan:

```bash
./scripts/status-local.sh
./scripts/start-local.sh --daemon
```

Admin:

```txt
URL: http://localhost:4000/admin
Login: admin / admin123
Project index: http://localhost:4000/admin/projects
New project: http://localhost:4000/admin/projects/new
Public work: http://localhost:4000/work
```

## Step 1 — Pahami Project yang Mau Diinput

Sebelum buka form, AI harus membaca konteks secukupnya:

- PRD/product docs: `docs/product`
- TRD/technical docs: `docs/technical`
- Architecture docs: `docs/architecture`
- Planning docs relevan: `docs/planning`
- Real implementation atau repo project terkait
- README/local setup jika ada

Untuk hemat token, pakai workflow:

```txt
docs/workflows/FETCH_PROJECT_CONTEXT_WORKFLOW.md
```

## Step 2 — Artikulasi Dulu, Baru Input

Buat draft isi field sebelum mengetik di browser.

Gunakan Bahasa Indonesia untuk deskripsi. Nama teknologi tetap nama aslinya.

Field wajib untuk project recruiter-ready:

```txt
title
slug
summary
description
problem
solution
role
ownership
team_size
project_type
platforms
disciplines
tech_stack
architecture_notes
tradeoffs
technical_highlights
result
metrics
case_study_visibility
status
featured
sort_order
```

Kalau project proprietary:

- Jangan buka detail internal, credential, client secret, atau angka yang tidak boleh dibagikan.
- Pakai `case_study_visibility = limited` atau `private_summary`.
- Fokus pada problem class, ownership, technical decision, dan safe impact.

## Step 3 — Pattern Artikulasi

Gunakan format berpikir ini:

```txt
1. Project ini apa?
2. Siapa user atau pembacanya?
3. Problem apa yang diselesaikan?
4. Role kamu apa?
5. Scope ownership kamu sampai mana?
6. Technical approach apa yang dipakai?
7. Architecture decision apa yang menarik?
8. Trade-off apa yang sengaja diambil?
9. Result/impact apa yang bisa dipercaya?
10. Stack/platform/discipline apa yang benar-benar relevan?
```

Untuk detail lengkap, ikuti:

```txt
docs/workflows/PROJECT_ARTICULATION_WORKFLOW.md
```

## Step 4 — Input via Browser

Alur manual browser:

1. Buka `http://localhost:4000/admin`.
2. Login jika diminta.
3. Masuk ke `Content / Projects`.
4. Klik `New Project` atau `Edit` project existing.
5. Isi field dari draft.
6. Gunakan checkbox untuk `Platform` dan `Keahlian / Discipline`, jangan mengetik taxonomy manual.
7. Isi array-like fields satu item per baris:
   - `tech_stack`
   - `result`
   - `technical_highlights`
   - `metrics`
8. Set:
   - `status = Published`
   - `featured = ON` untuk project prioritas
   - `sort_order` makin kecil makin atas
9. Save.
10. Klik preview atau buka `/work/<slug>`.

## Step 5 — Review Public Output

Setelah save, AI harus cek:

```txt
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Checklist review:

- Judul dan summary enak discan.
- Role dan ownership langsung jelas.
- Problem tidak generik.
- Solution menunjukkan technical decision nyata.
- Stack tidak berlebihan.
- Highlight teknis tampil sebagai bukti, bukan jargon.
- Result/metrics tidak mengarang.
- Case study aman untuk publik.
- Link preview/detail bekerja.

## Step 6 — SQL Fallback untuk Personal Platform Website

Jika butuh restore data Personal Platform Website setelah reset DB:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-personal-platform-project.sql
```

SQL ini bukan pengganti browser QA. Tetap review hasil akhir di `/work/personal-platform-website`.

## Handoff Note

Setelah input, AI harus lapor:

```txt
Input selesai:
- Project:
- Slug:
- Status:
- Featured/sort_order:
- Public URL:

Review:
- Yang sudah bagus:
- Yang masih kurang:
- Field yang perlu data tambahan dari owner:
```
