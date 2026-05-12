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

### Konvensi README Project

README setiap project portfolio harus menyertakan dua bagian ini agar AI bisa otomatis mengambil cover image dan demo link:

**Cover Image** — gunakan salah satu format berikut di README:

```markdown
## Screenshots

![Project Name](https://raw.githubusercontent.com/nunutech40/<repo>/main/<path>/cover.png)
```

Atau:

```markdown
## Preview

![Project Name](docs/assets/cover.png)
```

Tag yang dideteksi AI: `## Screenshots`, `## Preview`, atau `## Cover`

**Demo / Video** — gunakan format berikut:

```markdown
## Demo

**Live Demo:** https://drive.google.com/file/d/<file-id>/view
```

Atau:

```markdown
## Video Demo

[Watch demo](https://drive.google.com/file/d/<file-id>/view)
```

Tag yang dideteksi AI: `## Demo`, `## Video Demo`, atau `**Demo:**`

> **Catatan:** Video demo bisa diupload ke Google Drive atau sebagai release asset di GitHub. Pastikan link bisa diakses publik (viewable by anyone with the link).

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

Field tambahan yang diisi dari README:

```txt
demo_url       → dari bagian Demo / Video Demo di README
cover_image    → upload dari gambar di bagian Screenshots / Preview README
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
9. **Upload cover image** (jika README menyediakan):
   - Buka `http://localhost:4000/admin/media/new`
   - Upload file gambar dari README (download dulu dari GitHub raw URL)
   - Isi alt text sesuai project
   - Save media
   - Kembali ke form project, pilih media di field `Gambar Cover`
10. **Isi demo_url** dari link video di README.
11. Save.
12. Klik preview atau buka `/work/<slug>`.

## Step 5 — Review Public Output

Setelah save, AI wajib cek public output. Jangan berhenti di "data berhasil disimpan".

```txt
http://localhost:4000/
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Checklist review:

- Homepage tidak crash dan project tampil jika memang featured/published.
- Judul dan summary enak discan.
- Role dan ownership langsung jelas.
- Problem tidak generik.
- Solution menunjukkan technical decision nyata.
- Stack tidak berlebihan.
- Highlight teknis tampil sebagai bukti, bukan jargon.
- Result/metrics tidak mengarang.
- Case study aman untuk publik.
- Link preview/detail bekerja.
- Cover image tampil jika sudah dipilih; kalau belum ada, fallback visual tidak merusak layout.
- Jika ada data kosong, halaman tetap menampilkan empty state yang masuk akal, bukan error.
- **demo_url** (video demo) muncul di bagian Links halaman detail.

Kalau ada yang belum sesuai, AI harus kembali ke admin edit form, perbaiki field terkait, save lagi, lalu ulangi review URL di atas.

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
- Cover image: <uploaded / not available>
- Demo video: <link from README / not available>

Review:
- Yang sudah bagus:
- Yang masih kurang:
- Field yang perlu data tambahan dari owner:
```
