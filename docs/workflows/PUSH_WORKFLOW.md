# Push Workflow

Gunakan workflow ini setiap kali mau commit dan push perubahan ke GitHub.

> **⚠️ ATURAN UNTUK AGENT (AI):**
> Workflow ini WAJIB diikuti LANGKAH DEMI LANGKAH secara berurutan. Jangan pernah menggunakan "Quick Command" atau melewatkan langkah manapun. Setiap kali user menyuruh push, agent harus menjalankan langkah 1 sampai 8 secara berurutan, lalu menulis Handoff Note. Jika ada langkah yang gagal, STOP dan laporkan ke user.

## Full Workflow


### 1. Sync branch

```bash
git checkout main
git pull --ff-only
```

Kalau `git pull --ff-only` gagal, jangan paksa merge/reset. Cek dulu konflik atau remote changes.

### 2. Review changes

```bash
git status --short
git diff --stat
```

Kalau ada file pindahan, pastikan Git menangkapnya sebagai delete + add atau rename yang memang disengaja.

Untuk perubahan docs/skills, cek struktur:

```bash
find docs -maxdepth 3 -type f | sort
find personal_brand_platform_agent_kit -maxdepth 4 -type f | sort
```

### 3. Run lightweight checks

Untuk prototype static saat ini:

```bash
node --check src/app.js
node --check server.mjs
```

Kalau nanti sudah Phoenix:

```bash
mix format --check-formatted
mix test
```

Untuk menentukan test minimal per slice, lihat:

```txt
docs/standards/CODING_AND_TESTING_STANDARDS.md
```

### 4. Stage

Untuk semua perubahan yang memang mau dikirim:

```bash
git add .
```

Kalau mau lebih hati-hati:

```bash
git add README.md docs personal_brand_platform_agent_kit
```

### 5. Verify staged changes

```bash
git status --short
git diff --cached --stat
```

Pastikan tidak ada file rahasia seperti:

```txt
.env
secret keys
private tokens
Midtrans server key
database credentials
storage credentials
```

### 6. Commit

Gunakan imperative summary, singkat dan jelas:

```bash
git commit -m "<verb> <object>"
```

Contoh:

```bash
git commit -m "Refine agent build workflow"
git commit -m "Organize project documentation"
git commit -m "Add Elixir functional coding skill"
```

### 7. Push

```bash
git push
```

Kalau branch belum punya upstream:

```bash
git push -u origin main
```

### 8. Final verification

```bash
git status --short
git log --oneline --decorate -1
git remote -v
```

Expected:

```txt
git status --short
# no output
```

## Handoff Note

Setelah push, tulis ringkasan:

```txt
Pushed:
- commit: <hash> <message>
- branch: main
- remote: origin

Checks:
- <commands run>

Notes:
- <anything the next agent/user should know>
```
