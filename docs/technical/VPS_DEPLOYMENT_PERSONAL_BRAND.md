# VPS Deployment - Personal Brand Platform

Target VPS sudah tersedia:

- Host: `103.181.143.73`
- User: `nunuadmin`
- Hostname: `BelajarSains`
- OS: Ubuntu 24.04.4 LTS
- PostgreSQL: 16
- Nginx: active
- Existing busy app ports: `8080`, `8081`
- Phoenix port: `4000`
- Domain: `nunugraha.web.id`
- Private ops/admin path: `/nunu-ops-7f3c`

Do not commit real secrets. Use templates in `docs/deployment/`.

## 0. Current Production Status

Last checked over SSH: 2026-05-24.

VPS status:

```txt
CPU        2 vCPU
RAM        1.9 GiB + 2.0 GiB swap
Disk       38G total, 31G free on /
Postgres   active, listening on 127.0.0.1:5432
Nginx      active, listening on 80/443
Phoenix    active, listening on 4000 via personal-brand.service
UFW        active, allows SSH + HTTP/HTTPS
Node/npm   installed
Erlang     OTP 25 from Ubuntu package
Elixir     1.15.8 installed at /opt/elixir-1.15.8
Mix        1.15.8
Git HTTPS  can reach GitHub repo
Git SSH    not ready; host key verification failed
```

Live endpoints:

```txt
Public site   https://nunugraha.web.id
Work list     https://nunugraha.web.id/work
Health check  https://nunugraha.web.id/health
Ops login     https://nunugraha.web.id/nunu-ops-7f3c/login
```

Deployed revision:

```txt
9f92c20 Prepare VPS deployment
```

Production data restored from local:

```txt
projects       29
posts          2
media records  5
site_settings  1
uploads files 10
```

Prepared in repo:

- Production config reads `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PORT`, `POOL_SIZE`, `ADMIN_USERNAME`, `ADMIN_PASSWORD`, `UPLOADS_DIR`, `MIDTRANS_SERVER_KEY`, and `MIDTRANS_ENV`.
- `/health` returns `ok` for Nginx/systemd health checks.
- Uploads can live outside the release via `UPLOADS_DIR=/home/nunuadmin/personal-brand-shared/uploads`.
- Nginx and systemd templates live in `docs/deployment/`.
- Latest migrations include post monetization, orders/access grants, product fulfillment, `best_three`, `clap_count`, and standardized product checkout fields.

Current gaps:

- `MIDTRANS_SERVER_KEY` is still empty in the VPS `.env`.
- SMTP env values are still empty in the VPS `.env`.
- GitHub SSH on VPS is not configured; use HTTPS clone/pull for now.
- Keep existing apps on ports `8080` and `8081` untouched.

Secret location reminder:

```txt
Local temporary secret file: /private/tmp/personal_brand_prod_secrets.txt
Line 1: production database password
Line 2: production ops/admin password
Line 3: SECRET_KEY_BASE
```

Do not commit this file. If the Mac `/private/tmp` is cleaned, reset the admin password in `/home/nunuadmin/personal-brand-platform/.env` and restart `personal-brand`.

## 1. Prepare Domain

Set DNS in Cloudflare:

```txt
A nunugraha.web.id      103.181.143.73 proxied
A www.nunugraha.web.id  103.181.143.73 proxied
```

Use Cloudflare SSL mode `Full`, matching the existing VPS pattern.

## 2. Install VPS Runtime

Runtime is already installed on the VPS. The first deploy used Ubuntu Erlang/OTP 25 plus precompiled Elixir 1.15.8.

```bash
ssh nunuadmin@103.181.143.73
sudo apt update
sudo apt install -y git curl build-essential unzip postgresql-client ca-certificates gnupg

# First deploy used:
sudo apt install -y erlang
curl -fL https://github.com/elixir-lang/elixir/releases/download/v1.15.8/elixir-otp-25.zip -o /tmp/elixir-otp-25.zip
sudo rm -rf /opt/elixir-1.15.8
sudo mkdir -p /opt/elixir-1.15.8
sudo unzip -q /tmp/elixir-otp-25.zip -d /opt/elixir-1.15.8
sudo ln -sf /opt/elixir-1.15.8/bin/elixir /usr/local/bin/elixir
sudo ln -sf /opt/elixir-1.15.8/bin/elixirc /usr/local/bin/elixirc
sudo ln -sf /opt/elixir-1.15.8/bin/mix /usr/local/bin/mix

elixir -v
mix -v
```

Install Hex/Rebar:

```bash
mix local.hex --force
mix local.rebar --force
```

## 3. Create Production Database

Already created. Use a separate database/user from SAINS.

```bash
sudo -u postgres psql
```

```sql
CREATE USER personal_brand_user WITH PASSWORD 'REPLACE_WITH_STRONG_PASSWORD';
CREATE DATABASE personal_brand_prod OWNER personal_brand_user;
\q
```

If rotating the password, update both PostgreSQL and `/home/nunuadmin/personal-brand-platform/.env`, then restart the service.

## 4. Prepare App Directories

```bash
mkdir -p /home/nunuadmin/personal-brand-platform
mkdir -p /home/nunuadmin/personal-brand-shared/uploads/media
```

Clone or pull the repo:

```bash
cd /home/nunuadmin/personal-brand-platform
git clone https://github.com/nunutech40/personal-platform-website.git .
```

GitHub HTTPS works from the VPS. GitHub SSH currently needs `known_hosts`/key setup before it can be used.

For follow-up deploys:

```bash
cd /home/nunuadmin/personal-brand-platform
git pull origin main
```

## 5. Create Env File

Copy template:

```bash
cp docs/deployment/personal-brand.env.example /home/nunuadmin/personal-brand-platform/.env
nano /home/nunuadmin/personal-brand-platform/.env
```

Required values:

```txt
PHX_HOST=nunugraha.web.id
SECRET_KEY_BASE=...
DATABASE_URL=ecto://personal_brand_user:...@localhost/personal_brand_prod
ADMIN_USERNAME=...
ADMIN_PASSWORD=...
UPLOADS_DIR=/home/nunuadmin/personal-brand-shared/uploads
MIDTRANS_SERVER_KEY=...
MIDTRANS_ENV=sandbox
PAYMENT_NOTIFICATION_TO=r.fajarnugraha@gmail.com
PAYMENT_NOTIFICATION_FROM="Personal Brand <no-reply@nunugraha.web.id>"
SMTP_HOST=...
SMTP_PORT=587
SMTP_USERNAME=...
SMTP_PASSWORD=...
```

Generate secret locally or on VPS. On the first deploy, the local temporary file was:

```txt
/private/tmp/personal_brand_prod_secrets.txt
```

Generate a new secret if needed:

```bash
cd /home/nunuadmin/personal-brand-platform/personal_brand
mix phx.gen.secret
```

## 6. Migrate Existing Local Data

Data safety rule: database rows and uploaded files are separate. To carry everything from local to VPS, move **both** the PostgreSQL dump and `priv/static/uploads`.

On local Mac:

```bash
pg_dump -Fc personal_brand_dev > /tmp/personal_brand_dev.dump
tar -C personal_brand/priv/static -czf /tmp/personal_brand_uploads.tgz uploads
scp /tmp/personal_brand_dev.dump /tmp/personal_brand_uploads.tgz nunuadmin@103.181.143.73:/home/nunuadmin/
```

On VPS:

```bash
sudo -u postgres dropdb --if-exists personal_brand_prod
sudo -u postgres createdb -O personal_brand_user personal_brand_prod
sudo -u postgres pg_restore --clean --if-exists --no-owner -d personal_brand_prod /home/nunuadmin/personal_brand_dev.dump
sudo -u postgres psql -d personal_brand_prod -c "ALTER SCHEMA public OWNER TO personal_brand_user; GRANT ALL ON SCHEMA public TO personal_brand_user; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO personal_brand_user; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO personal_brand_user;"

rm -rf /home/nunuadmin/personal-brand-shared/uploads
mkdir -p /home/nunuadmin/personal-brand-shared
tar -C /home/nunuadmin/personal-brand-shared -xzf /home/nunuadmin/personal_brand_uploads.tgz
find /home/nunuadmin/personal-brand-shared/uploads -name '._*' -type f -delete
```

Default rule for this project: restore local CMS data and uploads when content has changed locally. Do not skip restore if the latest local CMS edits must appear on VPS.

After restore, still run `MIX_ENV=prod mix ecto.migrate` so any migrations created after the dump are applied.

## 7. Build And Migrate App

```bash
cd /home/nunuadmin/personal-brand-platform/personal_brand
set -a
. /home/nunuadmin/personal-brand-platform/.env
set +a

mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate
```

For follow-up deploys without data restore:

```bash
cd /home/nunuadmin/personal-brand-platform
git pull origin main

cd personal_brand
set -a
. /home/nunuadmin/personal-brand-platform/.env
set +a

MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate
sudo systemctl restart personal-brand
sudo systemctl status personal-brand
curl -fsS https://nunugraha.web.id/health
```

## 8. Systemd Service

Install template:

```bash
sudo cp /home/nunuadmin/personal-brand-platform/docs/deployment/personal-brand.service /etc/systemd/system/personal-brand.service
sudo systemctl daemon-reload
sudo systemctl enable personal-brand
sudo systemctl restart personal-brand
sudo systemctl status personal-brand
```

Logs:

```bash
sudo journalctl -u personal-brand -f
```

## 9. Nginx

Copy template and replace `YOUR_DOMAIN` with `nunugraha.web.id`:

```bash
sudo cp /home/nunuadmin/personal-brand-platform/docs/deployment/personal-brand.nginx.conf /etc/nginx/sites-available/personal-brand
sudo sed -i 's/YOUR_DOMAIN/nunugraha.web.id/g' /etc/nginx/sites-available/personal-brand
sudo ln -sf /etc/nginx/sites-available/personal-brand /etc/nginx/sites-enabled/personal-brand
sudo nginx -t
sudo systemctl reload nginx
```

Verify:

```bash
curl -I https://nunugraha.web.id/health
curl https://nunugraha.web.id/health
```

Expected body:

```txt
ok
```

## 10. Midtrans

Set HTTP Notification URL in Midtrans dashboard:

```txt
https://nunugraha.web.id/webhooks/midtrans
```

Keep `MIDTRANS_SERVER_KEY` only in `/home/nunuadmin/personal-brand-platform/.env`.

Paid order notification email is sent when Midtrans webhook marks an order `paid`.
Use `PAYMENT_NOTIFICATION_TO=r.fajarnugraha@gmail.com` and configure SMTP env values.

## 10.5 Security Before Public Launch

- Private ops/admin path is `/nunu-ops-7f3c`.
- Current production admin username is `nunuops`.
- Production admin password is not committed. See `/private/tmp/personal_brand_prod_secrets.txt` line 2 on the local Mac.
- Replace `ADMIN_USERNAME` and `ADMIN_PASSWORD` in the VPS env file if rotating credentials.
- Keep `.env` readable only by the deploy user:

```bash
chmod 600 /home/nunuadmin/personal-brand-platform/.env
```

- Do not commit `.env`, database dumps, upload archives, Midtrans keys, SMTP password, admin password, or VPS passwords.

## 11. Post-Deploy Admin Checks

1. Open `https://nunugraha.web.id/nunu-ops-7f3c/login`.
2. Check Site Settings exists.
3. Mark 1-3 projects as `Best Three Homepage`.
4. Confirm uploaded media renders.
5. Test a free post.
6. Test a paid/tips post in Midtrans sandbox.
7. Check `/nunu-ops-7f3c/orders` after payment notification.
8. Fetch public pages and scan for accidental local URLs:

```bash
curl -ksS https://nunugraha.web.id/ > /tmp/pb_home.html
curl -ksS https://nunugraha.web.id/work > /tmp/pb_work.html
grep -RInE 'localhost|127\.0\.0\.1' /tmp/pb_home.html /tmp/pb_work.html || true
```

## 12. Backup

Database:

```bash
ssh nunuadmin@103.181.143.73 "pg_dump -Fc personal_brand_prod" > personal_brand_prod_$(date +%Y%m%d).dump
```

Uploads:

```bash
ssh nunuadmin@103.181.143.73 "tar -C /home/nunuadmin/personal-brand-shared -czf - uploads" > personal_brand_uploads_$(date +%Y%m%d).tgz
```

## Current Gaps

- Midtrans production/sandbox server key still needs to be filled in VPS `.env`.
- SMTP values still need to be filled in VPS `.env`.
- GitHub SSH on VPS is not configured; follow-up deploys should use HTTPS `git pull`.
