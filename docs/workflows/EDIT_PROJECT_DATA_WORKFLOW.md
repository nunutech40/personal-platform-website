# Edit Project Data Workflow

Gunakan workflow ini saat user meminta revisi data project yang sudah ada di CMS.

Tujuannya: perubahan copy, taxonomy, status, sort order, link, atau cover image masuk ke data CMS dengan aman, lalu hasil public-nya dicek ulang di browser.

## Prasyarat

Pastikan app lokal hidup:

```bash
./scripts/status-local.sh
./scripts/start-local.sh --daemon
```

Admin:

```txt
URL: http://localhost:4000/admin
Login: admin / admin123
Project index: http://localhost:4000/admin/projects
Public work: http://localhost:4000/work
```

Jika revisi juga menyentuh profile/About/Now/Contact/support links, edit lewat:

```txt
Site settings: http://localhost:4000/admin/site-settings
Public about: http://localhost:4000/about
Public now: http://localhost:4000/now
Public contact: http://localhost:4000/contact
```

`/admin/site-settings` langsung membuka edit form singleton Site Settings. Jangan buat record baru dan jangan hapus record ini karena dipakai sebagai patokan website publik.

## Step 1 — Pahami Permintaan Edit

Identifikasi project target dan field yang diminta berubah.

Contoh permintaan:

```txt
ganti overview project X jadi ...
problemnya kurang tajam, bikin lebih recruiter-ready
ganti cover image pakai asset di folder docs/assets/project-x
ubah status jadi published
jadikan featured dan sort_order 1
```

Kalau slug/title project tidak disebut jelas, cari dari admin project list atau data DB berdasarkan judul/slug yang paling dekat. Jangan membuat project baru kalau maksud user adalah edit.

## Step 2 — Ambil Data Existing

Baca data project existing sebelum mengedit:

```bash
cd personal_brand
mix run -e 'alias PersonalBrand.{Repo,Content.Project}; import Ecto.Query; Repo.all(from p in Project, order_by: [asc: p.sort_order, desc: p.inserted_at], select: {p.id, p.title, p.slug, p.status, p.featured, p.sort_order}) |> IO.inspect(limit: :infinity)'
```

Untuk project spesifik, cek field yang akan diubah lewat admin edit page atau query DB. Catat nilai lama seperlunya agar perubahan tidak menghapus field lain tanpa sengaja.

## Step 3 — Draft Revisi

Sebelum submit form, tulis draft singkat perubahan:

```txt
Project:
Slug:
Field yang diubah:
- field lama -> field baru
Risiko:
- public copy berubah
- URL berubah jika slug diganti
- image perlu upload/pilih ulang jika cover diganti
```

Untuk copy recruiter-facing, ikuti:

```txt
docs/workflows/PROJECT_ARTICULATION_WORKFLOW.md
```

### Konvensi README Project (untuk referensi cover image & demo)

Jika edit melibatkan cover image atau demo link, cek README project di repo GitHub masing-masing. README harus menyertakan:

**Cover Image** — dideteksi dari tag:

```markdown
## Screenshots
## Preview
## Cover
```

**Demo / Video** — dideteksi dari tag:

```markdown
## Demo
## Video Demo
**Demo:**
**Live Demo:**
**Video Demo:**
```

Lihat detail konvensi di:

```txt
docs/workflows/INPUT_PROJECT_DATA_WORKFLOW.md
```

## Step 4 — Edit via Admin

Alur browser:

1. Buka `http://localhost:4000/admin`.
2. Login jika diminta.
3. Buka `Content / Projects`.
4. Cari project target.
5. Klik `Edit`.
6. Ubah hanya field yang diminta atau field yang diperlukan untuk membuat hasil konsisten.
7. Untuk array-like fields, isi satu item per baris:
   - `tech_stack`
   - `result`
   - `technical_highlights`
   - `metrics`
   Untuk `tech_stack`, pastikan teknologi/library penting benar-benar terisi karena detail work menampilkannya sebagai section `Tech & Libraries`.
8. Untuk taxonomy, pakai checkbox `Platform` dan `Keahlian / Discipline`.
9. Jika perlu mengatur urutan berdasarkan tahun-bulan, isi `Tanggal Sortir` (`sort_date`) dengan format `YYYY-MM-DD`. Teks publik tetap ambil dari `duration` atau `year`.
10. Untuk field panjang seperti Technical Approach, Architecture Notes, dan Trade-offs, pakai blank line untuk paragraf baru atau numbering `1.`, `2.`, `3.` untuk daftar keputusan. Jangan satukan banyak ide menjadi satu paragraf raksasa.
11. Save.

Catatan form: `tech_stack`, `result`, `technical_highlights`, dan `metrics` disimpan sebagai array dari textarea satu-item-per-baris. Workflow normal tidak perlu SQL workaround.

### Re-artikulasi 3 Section Teknis

Gunakan pola ini saat user bilang section teknis "kurang kebaca", "nggak nyambung", atau "terlalu panjang":

| Section publik | Field admin | Cara edit |
|---|---|---|
| `Technical Approach` | `solution` | Tulis 1-2 paragraf tentang cara implementasi. Mulai dari pendekatan utama, lalu jelaskan integration point atau flow teknis yang relevan. |
| `Architecture Notes` | `architecture_notes` | Tulis struktur sistem. Jika ada beberapa keputusan, awali dengan kalimat pengantar lalu tulis `1.`, `2.`, `3.`. |
| `Trade-offs` | `tradeoffs` | Tulis keputusan dan konsekuensi. Jangan cuma menyebut teknologi; jelaskan kenapa memilih itu dan apa harga yang dibayar. |

Checklist edit:

- Satu paragraf maksimal 2-4 kalimat.
- Pisahkan ide berbeda dengan blank line.
- Pakai numbering untuk 3+ keputusan.
- Jangan mengulang kalimat yang sama di tiga section.
- Pastikan setiap section bisa dibaca sendiri tanpa harus menebak konteks dari section sebelumnya.
- Setelah save, cek public `/work/<slug>` dan pastikan HTML menampilkan beberapa `<p>` atau ordered list, bukan satu blok teks panjang.

## Step 5 — Edit Cover Image dari Asset Lokal atau README

Jika user meminta ganti image:

**Dari folder lokal:**
1. Pastikan file asset ada dan formatnya cocok untuk web (`.jpg`, `.jpeg`, `.png`, `.webp`, atau `.gif`).
2. Buka `http://localhost:4000/admin/media/new`.
3. Upload file tersebut atau isi metadata media sesuai form.
4. Save media.
5. Kembali ke edit project.
6. Pilih media baru di field cover image.
7. Save project.

**Dari README project (GitHub raw URL):**
1. Ambil gambar dari URL di README (bagian `## Screenshots` / `## Preview` / `## Cover`).
2. Jika path masih relative terhadap repo, ubah menjadi raw GitHub URL sesuai branch project:
   `https://raw.githubusercontent.com/<owner>/<repo>/<branch>/<path>`.
3. Buka `http://localhost:4000/admin/media/new`.
4. Jika raw URL publik tersedia, isi `URL`, `Filename`, `Content Type`, dan `Alt Text` tanpa download.
5. Alternatif: download lalu upload jika raw URL tidak stabil atau asset tidak publik.
6. Save media.
7. Kembali ke edit project, pilih media baru.
8. Save project.

Jangan menghapus file asset user dari folder asal. Upload/copy ke storage lokal app harus lewat workflow media/admin yang tersedia.

## Step 6 — Edit Demo URL / Video Demo

Jika README project menyediakan link demo:

1. Copy live site/app demo ke field `Link Demo / Live Site` (`demo_url`).
2. Copy video demo ke field `Link Video Demo` (`demo_video_url`).
3. Direct `.mp4/.webm/.ogg/.mov` akan tampil inline di detail work.
4. Google Drive, YouTube, atau GitHub release asset non-direct tetap tampil sebagai link.
5. Save.

## Step 6.5 — Edit Certificate PDF

Jika user meminta certificate bisa diunduh dari work detail:

1. Upload PDF ke `http://localhost:4000/admin/media/new` atau gunakan URL PDF eksternal yang permanen.
2. Pastikan `Content Type = application/pdf`.
3. Isi filename yang jelas dan aman untuk publik.
4. Save media.
5. Kembali ke edit project.
6. Pilih media PDF di field `Sertifikat PDF`.
7. Save project.
8. Review `/work/<slug>` dan pastikan link `Download Certificate` muncul.

Catatan deploy VPS: jika PDF diupload lokal, file fisiknya berada di `personal_brand/priv/static/uploads/media/`. Saat pindah production, folder upload dan row `media` terkait harus ikut dipindahkan. Untuk jangka panjang, lebih aman memakai object storage/CDN agar file tidak tergantung filesystem release.

## Step 7 — Review Public Output

Setelah save, wajib cek:

```txt
http://localhost:4000/
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Checklist review:

- Homepage tetap tidak crash.
- Homepage headline bukan placeholder/testing copy.
- Navigation urut dan tidak membingungkan: Home, Work, Writing, Products, About, Now, Contact.
- Primary recruiter path jelas: hero CTA dan Featured Work mengarah ke `/work`.
- About, Now, dan Contact tetap mengambil data dari Site Settings.
- Support links di Contact hanya tampil jika Saweria atau Buy Me Coffee sudah terisi.
- Project masih muncul/hilang sesuai `status`, `featured`, dan `sort_order`.
- Detail page memakai copy terbaru.
- Detail work dari atas sampai footer punya flow: breadcrumb → title/summary → facts → case study sections → evidence/results → links/media → footer.
- Overview/problem/solution/trade-offs tidak kosong kalau seharusnya tampil.
- Role, ownership, focus, stack, highlights, result/metrics menunjukkan pekerjaan nyata, bukan jargon.
- `Tech & Libraries` tampil jika `tech_stack` tersedia; isinya harus cukup granular untuk recruiter melihat exposure bahasa, framework, database, library, dan tooling.
- Detail work tidak menampilkan section kosong seperti Results/Links tanpa isi.
- Cover image baru tampil dan tidak merusak layout.
- Link publik memakai slug yang benar.
- Jika slug berubah, URL lama sudah tidak dipakai di handoff.
- `demo_url` muncul sebagai Live Demo jika ada.
- `demo_video_url` muncul sebagai Video Demo; direct video file tampil inline.
- Certificate PDF muncul sebagai `Download Certificate` jika `Sertifikat PDF` sudah dipilih.

Kalau hasil belum sesuai, balik ke admin edit form, perbaiki, save, lalu cek ulang.

## Step 8 — Handoff Note

Setelah edit selesai, lapor:

```txt
Edit selesai:
- Project:
- Slug:
- Field yang diubah:
- Cover image: <uploaded / external URL / unchanged / not available>
- Demo live: <updated / unchanged / not available>
- Demo video: <updated / unchanged / not available>
- Status/featured/sort_order:
- Public URL:

Review:
- Homepage/navigation:
- Work list:
- Detail:
- Catatan/risiko:
```
