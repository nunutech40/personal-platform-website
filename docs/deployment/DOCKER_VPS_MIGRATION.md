# Docker VPS Migration — Personal Brand Platform

Dokumen ini menjelaskan cara memindahkan Personal Brand Platform dari VPS lama
`103.181.143.73` ke VPS baru yang juga menjalankan Kohnu/SearchYourJob.

Target arsitektur baru:

```text
Internet / Cloudflare
  ↓
VPS baru 103.59.94.121
  ↓
Caddy gateway Kohnu, port publik 80/443
  ├─ app.kohnu.com      -> Kohnu containers
  └─ nunugraha.web.id   -> personal-brand-app:4000
```

Personal Brand tidak membuka port publik. Container `personal-brand-app` join ke
Docker network eksternal `kohnu-production_edge`, lalu Caddy gateway meneruskan
request berdasarkan domain.

## 1. File Docker baru

File yang dipakai:

```text
compose.production.yml
.env.production.example
personal_brand/Dockerfile
personal_brand/.dockerignore
scripts/backup-production-db.sh
scripts/restore-production-db.sh
scripts/backup-production-uploads.sh
```

Runtime config asli di server:

```text
/opt/personal-brand/.env.production
```

File `.env.production` tidak boleh masuk Git.

## 2. DNS cutover

Saat siap pindah, ubah Cloudflare DNS:

```text
A nunugraha.web.id      103.59.94.121
A www.nunugraha.web.id  103.59.94.121
```

Untuk cutover awal, DNS only lebih gampang untuk troubleshooting. Setelah HTTPS
stabil, Cloudflare proxy boleh aktif dengan SSL mode Full/Full strict.

## 3. Deploy fresh container di VPS baru

Di VPS baru:

```bash
sudo install -d -m 750 -o searchyourjob -g searchyourjob /opt/personal-brand
cd /opt/personal-brand
# clone repo atau upload release archive
cp .env.production.example .env.production
chmod 600 .env.production
```

Isi `.env.production` minimal:

```env
PHX_HOST=nunugraha.web.id
IMAGE_TAG=latest
POSTGRES_PASSWORD=<hex-secret>
SECRET_KEY_BASE=<mix-phx-gen-secret-output>
ADMIN_USERNAME=nunuops
ADMIN_PASSWORD=<admin-password>
MIDTRANS_ENV=sandbox
```

Jalankan:

```bash
docker compose --env-file .env.production -f compose.production.yml config --quiet
docker compose --env-file .env.production -f compose.production.yml build app
docker compose --env-file .env.production -f compose.production.yml up -d postgres
docker compose --env-file .env.production -f compose.production.yml --profile tools run --rm migrate
docker compose --env-file .env.production -f compose.production.yml up -d app
```

## 4. Update Caddy gateway Kohnu

Repo Kohnu gateway harus punya env:

```env
PERSONAL_BRAND_DOMAIN=nunugraha.web.id
PERSONAL_BRAND_WWW_DOMAIN=www.nunugraha.web.id
```

Lalu restart Caddy Kohnu:

```bash
cd /opt/kohnu
docker compose --env-file .env.production -f compose.production.yml up -d caddy
```

## 5. Migrasi data dari VPS lama

Di VPS lama:

```bash
ssh nunuadmin@103.181.143.73
pg_dump -Fc personal_brand_prod > /home/nunuadmin/personal-brand-prod.dump
tar -C /home/nunuadmin/personal-brand-shared -czf /home/nunuadmin/personal-brand-uploads.tgz uploads
```

Copy ke VPS baru:

```bash
scp nunuadmin@103.181.143.73:/home/nunuadmin/personal-brand-prod.dump /opt/personal-brand/backups/
scp nunuadmin@103.181.143.73:/home/nunuadmin/personal-brand-uploads.tgz /opt/personal-brand/backups/
```

Restore DB di VPS baru:

```bash
cd /opt/personal-brand
docker compose --env-file .env.production -f compose.production.yml up -d postgres
ALLOW_PRODUCTION_RESTORE=yes DROP_EXISTING_DB=yes \
  bash scripts/restore-production-db.sh backups/personal-brand-prod.dump
```

Restore uploads:

```bash
cd /opt/personal-brand
docker run --rm \
  -v personal-brand-production_uploads:/uploads \
  -v /opt/personal-brand/backups:/backups \
  alpine:3.20 \
  sh -lc 'rm -rf /uploads/* && tar -C / -xzf /backups/personal-brand-uploads.tgz'
```

Jika upload archive berisi folder `uploads/`, pastikan hasil akhirnya ada di
volume container path `/app/uploads`.

## 6. Smoke test

```bash
curl -fsS https://nunugraha.web.id/health
curl -I https://nunugraha.web.id/work
```

Browser:

- buka public site;
- buka `/work`;
- buka admin `/nunu-ops-7f3c/login`;
- cek media/upload tampil;
- cek satu post/project detail.

## 7. Setelah aman

Baru matikan VPS lama setelah semua ini aman:

- DB rows terbawa;
- uploads terbawa;
- domain resolve ke VPS baru;
- Caddy HTTPS valid;
- admin login bisa;
- public page dan media tampil.
