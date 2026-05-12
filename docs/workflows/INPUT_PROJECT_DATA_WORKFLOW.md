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

### Catatan Penting dari Experience

#### 1. Array Fields (tech_stack, result, technical_highlights, metrics)

Ada bug: form Backpex tidak menampilkan nilai array fields yang sudah ada di database (textarea tampil kosong). Jika AI mengisi textarea lalu save, data mungkin tidak tersimpan.

**Workaround:** Setelah save via browser, verifikasi di database:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "SELECT tech_stack, result, technical_highlights, metrics FROM projects WHERE slug = '<slug>';"
```

Jika masih kosong (`{}`), gunakan SQL UPDATE langsung:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "UPDATE projects SET tech_stack = ARRAY['item1','item2','item3'] WHERE slug = '<slug>';"
```

Contoh:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "UPDATE projects SET tech_stack = ARRAY['Elixir','Phoenix LiveView','PostgreSQL','Ecto','Backpex'] WHERE slug = 'personal-platform-website';"
```

Setelah SQL fallback, refresh halaman publik untuk verifikasi.

#### 2. Cover Image dari File Lokal

File input di form Backpex bersifat hidden (LiveUpload). **Tidak bisa di-upload langsung via Playwright `upload_file`.**

Workaround untuk upload cover image:

**Opsi A — Copy file langsung ke folder uploads + insert SQL:**

```bash
# 1. Copy file ke folder uploads
cp /path/ke/gambar.png personal_brand/priv/static/uploads/media/gambar.png

# 2. Insert record media
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "INSERT INTO media (id, filename, alt_text, content_type, size, url, file_path, inserted_at, updated_at) VALUES (gen_random_uuid(), 'gambar.png', 'Deskripsi gambar', 'image/png', 0, '/uploads/media/gambar.png', 'uploads/media/gambar.png', NOW(), NOW()) RETURNING id;"

# 3. Set cover image
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "UPDATE projects SET cover_image_id = '<id-dari-hasil-returning>' WHERE slug = '<slug>';"
```

**Opsi B — Upload via Admin > Media dulu (manual), lalu pilih di form edit project.**

#### 3. Update Multiple Fields Sekaligus via SQL

Untuk efisiensi, AI bisa menggabungkan beberapa update dalam satu query:

```bash
/opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "UPDATE projects SET cover_image_id = '<id>', tech_stack = ARRAY['item1','item2'], result = ARRAY['hasil1','hasil2'] WHERE slug = '<slug>';"
```

## Step 5 — Verifikasi Visual di Browser

**Ini WAJIB dilakukan.** Jangan cuma cek database atau percaya save berhasil.

### 5a. Cek Halaman Work List

Buka di browser:

```txt
http://localhost:4000/work
```

Verifikasi:
- [ ] Project muncul di daftar dengan judul yang benar
- [ ] Summary/ringkasan terbaca dengan baik
- [ ] Role dan platform/discipline tampil
- [ ] Cover image (jika ada) muncul di card
- [ ] Urutan project sesuai sort_order

### 5b. Cek Halaman Detail Project

Buka di browser:

```txt
http://localhost:4000/work/<slug>
```

Verifikasi:
- [ ] Judul dan metadata (role, ownership, team_size, platform, discipline, stack, tahun) tampil
- [ ] Cover image tampil di hero/detail page
- [ ] Description, problem, solution terbaca natural
- [ ] Architecture notes dan tradeoffs menunjukkan seniority
- [ ] Technical highlights muncul sebagai bullet points
- [ ] Result dan metrics tampil
- [ ] Link GitHub dan Demo bekerja (jika ada)
- [ ] Tidak ada data sensitif yang tidak sengaja terekspos

### 5c. Screenshot sebagai Bukti

Ambil screenshot halaman detail dan simpan sebagai bukti verifikasi.

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
