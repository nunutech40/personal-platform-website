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

Jika input/review juga menyentuh data website umum:

```txt
Site settings: http://localhost:4000/admin/site-settings
Public about: http://localhost:4000/about
Public now: http://localhost:4000/now
Public contact: http://localhost:4000/contact
```

`/admin/site-settings` adalah singleton shortcut. Route ini langsung membuka form edit record Site Settings yang menjadi patokan sistem, bukan list dan bukan form `new`.

## Step 1 — Pahami Project yang Mau Diinput

Sebelum buka form, AI harus membaca konteks secukupnya:

- PRD/product docs: `docs/product`
- TRD/technical docs: `docs/technical`
- Architecture docs: `docs/architecture`
- Planning docs relevan: `docs/planning`
- Real implementation atau repo project terkait
- GitHub repository project terkait, termasuk branch target yang diberikan user
- README/local setup jika ada

Untuk hemat token, pakai workflow:

```txt
docs/workflows/FETCH_PROJECT_CONTEXT_WORKFLOW.md
```

### Konvensi GitHub Source

Jika project diambil dari GitHub, user cukup memberi:

```txt
repo: https://github.com/nunutech40/<repo>
branch: main
```

Branch boleh berbeda per project. AI harus membaca README dari branch tersebut, lalu mengubah relative asset path menjadi raw GitHub URL:

```txt
docs/assets/cover.png
→ https://raw.githubusercontent.com/nunutech40/<repo>/<branch>/docs/assets/cover.png
```

Untuk file release asset atau link absolut `https://...`, pakai link asli selama publik.

### Konvensi README Project

README setiap project portfolio sebaiknya menyertakan bagian berikut agar AI bisa otomatis mengambil cover image dan demo/video link:

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

**Live Demo:** https://example.com
**Video Demo:** https://raw.githubusercontent.com/nunutech40/<repo>/<branch>/docs/demo/demo.mp4
```

Atau:

```markdown
## Video Demo

[Watch demo](https://drive.google.com/file/d/<file-id>/view)
```

Tag yang dideteksi AI: `## Demo`, `## Video Demo`, `**Demo:**`, `**Live Demo:**`, atau `**Video Demo:**`

> **Catatan:** Video demo bisa berupa direct raw GitHub `.mp4/.webm`, GitHub release asset, Google Drive, YouTube, atau link publik lain. Direct `.mp4/.webm` akan bisa dirender inline di halaman detail project; link non-direct tetap tampil sebagai link.

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
demo_url          → dari Live Demo di README
demo_video_url    → dari Video Demo di README
cover_image       → media record dengan URL dari Screenshots / Preview / Cover README
certificate_media → media record PDF untuk certificate, course completion, atau credential pendukung
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

### Reviewer Lens untuk Recruiter

Sebelum input, pastikan draft bisa dijawab cepat oleh pembaca:

- 5 detik pertama: recruiter tahu role, platform, dan seniority signal.
- 30 detik pertama: recruiter tahu problem, ownership, architecture decision, dan impact.
- Evidence: `technical_highlights`, `result`, `metrics`, `github_url`, `demo_url`, atau `demo_video_url` tidak dibiarkan kosong jika project punya bukti publik.
- `tech_stack` wajib cukup artikulatif untuk recruiter: isi framework, bahasa, database, library, admin/tooling, dan package penting yang benar-benar dipakai di project.
- Jangan isi stack terlalu luas. Hanya teknologi/library yang benar-benar dipakai atau disentuh dan membantu positioning.
- Untuk partner/customer, copy harus tetap aman: jangan expose credential, client secret, detail proprietary, atau angka internal yang tidak boleh dibuka.

### ⚠️ Aturan Intepretasi Disciplines dari README

**Jangan asal menebak disciplines dari tech stack.** Disciplines harus diisi berdasarkan **jenis project yang sebenarnya**, bukan dari teknologi yang disebut di README.

Aturan:

| Jenis Project | Disciplines yang Tepat | Contoh Salah |
|---|---|---|
| Flutter mobile app (Android/iOS) | `flutter_developer` saja | ❌ Jangan tambah `backend_developer` hanya karena README menyebut REST API |
| Phoenix LiveView web app | `fullstack_developer`, `backend_developer`, `frontend_developer` | ❌ Jangan tambah `flutter_developer` |
| Backend API service | `backend_developer` | ❌ Jangan tambah `frontend_developer` |
| iOS native app | `ios_developer`, `swift` | ❌ Jangan tambah `android_developer` |
| macOS native app | `swift` | ❌ Jangan tambah `ios_developer` kecuali memang ada iOS target |

**Penyebab umum kesalahan:** README Flutter app sering menyebut "REST API", "backend", "Firebase" — ini adalah **integrasi/konsumsi**, bukan berarti project-nya backend engineering. Disciplines mencerminkan **peran kamu di project**, bukan daftar teknologi.

> **Kasus real:** Internak App adalah Flutter mobile app. README menyebut REST API dan Firebase Auth. AI salah mengisi `backend_developer` sebagai discipline karena mengintepretasi "REST API" sebagai backend. Padahal ini murni Flutter development — REST API hanya dikonsumsi, bukan dibangun.

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
   Untuk `tech_stack`, pecah cukup granular supaya recruiter bisa melihat exposure teknologi/library, contoh: `Elixir`, `Phoenix LiveView`, `Ecto`, `PostgreSQL`, `Backpex`, `Tailwind CSS`, `daisyUI`.
8. Set:
   - `status = Published`
   - `featured = ON` untuk project prioritas
   - `sort_order` makin kecil makin atas
   - `sort_date` untuk urutan tahun-bulan, format `YYYY-MM-DD`. Pakai tanggal awal project, publish date, atau bulan dari GitHub evidence. Field ini tidak tampil publik; `duration` tetap dipakai untuk teks seperti `2024 - 2025`.
9. **Input cover image** (jika README menyediakan):
   - Buka `http://localhost:4000/admin/media/new`
   - Untuk asset GitHub, tidak perlu download jika raw URL publik tersedia.
   - Isi `URL` dengan raw GitHub URL atau link gambar publik.
   - Isi `Filename`, `Content Type` (`image/png`, `image/jpeg`, dll), dan `Alt Text`.
   - Alternatif: upload file lokal; admin akan generate `/uploads/media/...` otomatis.
   - Isi alt text sesuai project
   - Save media
   - Kembali ke form project, pilih media di field `Gambar Cover`
10. **Isi link demo**:
   - `demo_url` untuk live site/app/demo interaktif.
   - `demo_video_url` untuk video demo dari README/GitHub/Drive/YouTube.
11. **Input certificate PDF** (jika project punya sertifikat):
   - Buka `http://localhost:4000/admin/media/new`.
   - Upload file PDF certificate atau isi URL eksternal permanen jika PDF sudah ada di storage publik.
   - Pastikan `Content Type = application/pdf`.
   - Isi filename yang jelas, contoh `flutter-certificate-nunu-nugraha.pdf`.
   - Save media.
   - Kembali ke form project, pilih media tersebut di field `Sertifikat PDF`.
   - Di public detail, certificate tampil sebagai `Download Certificate`.
12. Save.
13. Klik preview atau buka `/work/<slug>`.

Catatan form: `tech_stack`, `result`, `technical_highlights`, dan `metrics` disimpan sebagai array dari textarea satu-item-per-baris. Jangan ubah ke SQL workaround kecuali sedang repair data lama atau bulk import.

### Penulisan 3 Section Teknis yang Readable

Field panjang seperti `description`, `problem`, `solution`, `architecture_notes`, dan `tradeoffs` boleh lebih dari satu paragraf.

Khusus 3 section teknis, jangan menaruh semua fakta ke satu paragraf panjang. Setiap section punya tugas berbeda:

| Public section | Admin field | Tujuan |
|---|---|---|
| `Technical Approach` | `solution` | Menjelaskan cara project dibangun: stack utama, flow implementasi, integration point, dan keputusan teknis yang langsung menyelesaikan problem. |
| `Architecture Notes` | `architecture_notes` | Menjelaskan struktur sistem: boundary module, data flow, dependency direction, state management, storage, atau query layer. |
| `Trade-offs` | `tradeoffs` | Menjelaskan keputusan yang sengaja diambil, alternatif yang tidak dipilih, konsekuensi, dan follow-up jika project dilanjutkan. |

Format yang disarankan:

```txt
Paragraf pertama menjelaskan inti pendekatan.

Paragraf kedua menjelaskan detail implementasi atau batasan penting.
```

Untuk daftar keputusan, tulis dengan numbering eksplisit supaya public detail merendernya sebagai ordered list:

```txt
Keputusan arsitektur kunci:
1. Pisahkan state UI ke ViewModel.
2. Buat service layer stateless.
3. Pakai NSTextView untuk payload besar.
```

Standar kualitas:

- 1 paragraph idealnya 2-4 kalimat, bukan 8-10 kalimat.
- Jangan mengulang isi yang sama di `solution`, `architecture_notes`, dan `tradeoffs`.
- `solution` boleh lebih naratif; `architecture_notes` lebih struktural; `tradeoffs` lebih reflektif.
- Jika ada 3+ keputusan, pakai numbering.
- Hindari buzzword tanpa bukti seperti "scalable", "robust", atau "clean architecture" kecuali dijelaskan lewat implementasi nyata.
- Public detail akan merender blank line sebagai paragraf baru dan numbering sebagai ordered list.

## Step 5 — Review Public Output

Setelah save, AI wajib cek public output. Jangan berhenti di "data berhasil disimpan".

```txt
http://localhost:4000/
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Checklist review:

- Homepage tidak crash dan project tampil jika memang featured/published.
- Homepage headline bukan placeholder/testing copy.
- Navigation urut dan tidak membingungkan: Home, Work, Writing, Products, About, Now, Contact.
- Primary path untuk recruiter jelas: header/nav, hero CTA, dan Featured Work mengarah ke `/work`.
- Social/contact link yang tampil memang bisa diklik dan sesuai persona publik.
- About, Now, dan Contact mengambil data dari Site Settings, bukan copy hardcoded.
- Support links di Contact hanya muncul jika Saweria atau Buy Me Coffee sudah diisi.
- Judul dan summary enak discan.
- Role dan ownership langsung jelas.
- Section `Tech & Libraries` tampil di detail work jika `tech_stack` diisi, dan isinya membantu recruiter memahami teknologi yang pernah dipakai.
- Problem tidak generik.
- Solution menunjukkan technical decision nyata.
- Stack tidak berlebihan.
- Highlight teknis tampil sebagai bukti, bukan jargon.
- Result/metrics tidak mengarang.
- Detail work tidak menampilkan section kosong seperti Results/Links tanpa isi.
- Detail work dari atas sampai footer punya flow: breadcrumb → title/summary → facts → case study sections → evidence/results → links/media → footer.
- Case study aman untuk publik.
- Link preview/detail bekerja.
- Cover image tampil jika sudah dipilih; kalau belum ada, fallback visual tidak merusak layout.
- Jika cover image dari GitHub raw URL, gambar tetap tampil di public page.
- Jika ada data kosong, halaman tetap menampilkan empty state yang masuk akal, bukan error.
- **demo_url** muncul sebagai Live Demo.
- **demo_video_url** muncul sebagai Video Demo; direct `.mp4/.webm` tampil inline di halaman detail.
- **certificate_media** muncul sebagai Download Certificate jika PDF dipilih.

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
- Demo live: <link from README / not available>
- Demo video: <link from README / not available>

Review:
- Yang sudah bagus:
- Yang masih kurang:
- Field yang perlu data tambahan dari owner:
```
