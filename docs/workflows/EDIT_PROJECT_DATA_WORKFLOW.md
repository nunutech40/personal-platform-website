# Edit Project Data Workflow

Gunakan workflow ini saat kamu (user) ingin mengubah data project yang sudah ada di CMS.

Cukup kasih tahu AI poin mana yang mau diubah — misalnya "deskripsi diganti dengan yang ini" atau "gambar cover pakai image dari folder ini".

## Prasyarat

Pastikan app jalan:

```bash
./scripts/status-local.sh
./scripts/start-local.sh --daemon
```

## Step 1 — Tentukan Project yang Mau Diubah

Kamu cukup bilang:

- Judul atau slug project yang mau diedit
- Poin spesifik yang mau diubah (field apa, isinya jadi apa)
- Atau lampirkan file gambar/media yang mau dipasang

Contoh perintah dari kamu:

> "Ubah deskripsi project Personal Platform Website jadi: [deskripsi baru]"
> "Ganti cover image project Personal Platform Website dengan gambar halaman1.png yang ada di docs/design/uiux/"
> "Tambah tech_stack: Redis, Docker"
> "Ubah sort_order jadi 1 biar muncul paling atas"

## Step 2 — AI Baca Data Existing

AI akan:

1. Buka `http://localhost:4000/admin/projects`
2. Login jika belum
3. Cari project berdasarkan judul/slug
4. Klik `Ubah` / Edit
5. Baca isi field yang ada di form

## Step 3 — AI Lakukan Perubahan

Berdasarkan instruksi kamu, AI akan:

- Isi ulang field text/textarea dengan nilai baru
- Centang/centang ulang checkbox taxonomy (Platform, Discipline)
- Pilih cover image dari Media library (upload dulu jika perlu)
- Ubah status, featured, sort_order, dll
- Klik Save

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

## Step 4 — Verifikasi Visual di Browser

**Ini WAJIB dilakukan.** Jangan cuma cek database.

### 4a. Cek Halaman Work List

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

### 4b. Cek Halaman Detail Project

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

### 4c. Screenshot sebagai Bukti

Ambil screenshot halaman detail dan simpan sebagai bukti verifikasi.

## Step 5 — Lapor

Setelah selesai, AI lapor:

```txt
Edit selesai:
- Project: <title>
- Slug: <slug>
- Yang diubah: <daftar field>
- Status: <published/draft>

Verifikasi Visual:
- Halaman work list: ✅ / ❌ (catatan jika ada)
- Halaman detail: ✅ / ❌ (catatan jika ada)
- Cover image tampil: ✅ / ❌
- Array fields terisi: ✅ / ❌

Catatan:
- <issue atau anomali yang ditemukan>
```
