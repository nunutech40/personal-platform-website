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
8. Untuk taxonomy, pakai checkbox `Platform` dan `Keahlian / Discipline`.
9. Save.

## Step 5 — Edit Cover Image dari Asset Lokal

Jika user meminta ganti image dari folder tertentu:

1. Pastikan file asset ada dan formatnya cocok untuk web (`.jpg`, `.jpeg`, `.png`, `.webp`, atau `.gif`).
2. Buka `http://localhost:4000/admin/media/new`.
3. Upload file tersebut atau isi metadata media sesuai form.
4. Save media.
5. Kembali ke edit project.
6. Pilih media baru di field cover image.
7. Save project.

Jangan menghapus file asset user dari folder asal. Upload/copy ke storage lokal app harus lewat workflow media/admin yang tersedia.

## Step 6 — Review Public Output

Setelah save, wajib cek:

```txt
http://localhost:4000/
http://localhost:4000/work
http://localhost:4000/work/<slug>
```

Checklist review:

- Homepage tetap tidak crash.
- Project masih muncul/hilang sesuai `status`, `featured`, dan `sort_order`.
- Detail page memakai copy terbaru.
- Overview/problem/solution/trade-offs tidak kosong kalau seharusnya tampil.
- Cover image baru tampil dan tidak merusak layout.
- Link publik memakai slug yang benar.
- Jika slug berubah, URL lama sudah tidak dipakai di handoff.

Kalau hasil belum sesuai, balik ke admin edit form, perbaiki, save, lalu cek ulang.

## Step 7 — Handoff Note

Setelah edit selesai, lapor:

```txt
Edit selesai:
- Project:
- Slug:
- Field yang diubah:
- Cover image:
- Status/featured/sort_order:
- Public URL:

Review:
- Homepage:
- Work list:
- Detail:
- Catatan/risiko:
```
