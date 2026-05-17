# VPS Deployment - Personal Brand Platform

Target VPS sudah tersedia:

- Host: `103.181.143.73`
- User: `nunuadmin`
- OS: Ubuntu 24.04 LTS
- PostgreSQL: 16
- Nginx: active
- Existing busy app ports: `8080`, `8081`
- Planned Phoenix port: `4000`

Do not commit real secrets. Use templates in `docs/deployment/`.

## 0. Current Deploy Readiness

Prepared in repo:

- Production config reads `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PORT`, `POOL_SIZE`, `ADMIN_USERNAME`, `ADMIN_PASSWORD`, `UPLOADS_DIR`, `MIDTRANS_SERVER_KEY`, and `MIDTRANS_ENV`.
- `/health` returns `ok` for Nginx/systemd health checks.
- Uploads can live outside the release via `UPLOADS_DIR=/home/nunuadmin/personal-brand-shared/uploads`.
- Nginx and systemd templates live in `docs/deployment/`.
- Latest migrations include post monetization, orders/access grants, product fulfillment, `best_three`, `clap_count`, and standardized product checkout fields.

Still needed before public launch:

- Buy/choose the domain and point Cloudflare DNS.
- Install Elixir/Mix on the VPS.
- Fill the production `.env` with real values.
- Decide whether to restore local data or start fresh, then run migrations.

## 1. Buy/Prepare Domain

Set DNS in Cloudflare:

```txt
A @   103.181.143.73 proxied
A www 103.181.143.73 proxied
```

Use Cloudflare SSL mode `Full`, matching the existing VPS pattern.

## 2. Install VPS Runtime

Elixir/Mix are not installed yet on the VPS. Install Erlang + Elixir before deploying.

```bash
ssh nunuadmin@103.181.143.73
sudo apt update
sudo apt install -y git curl build-essential unzip postgresql-client

# Install Erlang/Elixir using your preferred Ubuntu 24.04 method.
# After install, verify:
elixir -v
mix -v
```

Install Hex/Rebar:

```bash
mix local.hex --force
mix local.rebar --force
```

## 3. Create Production Database

Use a separate database/user from SAINS.

```bash
sudo -u postgres psql
```

```sql
CREATE USER personal_brand_user WITH PASSWORD 'REPLACE_WITH_STRONG_PASSWORD';
CREATE DATABASE personal_brand_prod OWNER personal_brand_user;
\q
```

## 4. Prepare App Directories

```bash
mkdir -p /home/nunuadmin/personal-brand-platform
mkdir -p /home/nunuadmin/personal-brand-shared/uploads/media
```

Clone or pull the repo:

```bash
cd /home/nunuadmin/personal-brand-platform
git clone git@github.com:nunutech40/personal-platform-website.git .
```

If GitHub SSH is not configured on VPS, use HTTPS or upload from local.

## 5. Create Env File

Copy template:

```bash
cp docs/deployment/personal-brand.env.example /home/nunuadmin/personal-brand-platform/.env
nano /home/nunuadmin/personal-brand-platform/.env
```

Required values:

```txt
PHX_HOST=your-domain.com
SECRET_KEY_BASE=...
DATABASE_URL=ecto://personal_brand_user:...@localhost/personal_brand_prod
ADMIN_USERNAME=...
ADMIN_PASSWORD=...
UPLOADS_DIR=/home/nunuadmin/personal-brand-shared/uploads
MIDTRANS_SERVER_KEY=...
MIDTRANS_ENV=sandbox
```

Generate secret locally or on VPS:

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
pg_restore --clean --if-exists -d personal_brand_prod /home/nunuadmin/personal_brand_dev.dump
tar -C /home/nunuadmin/personal-brand-shared -xzf /home/nunuadmin/personal_brand_uploads.tgz
```

If deploying fresh without local data, skip restore and run migrations only.

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

## 8. Systemd Service

Install template:

```bash
sudo cp /home/nunuadmin/personal-brand-platform/docs/deployment/personal-brand.service /etc/systemd/system/personal-brand.service
sudo systemctl daemon-reload
sudo systemctl enable personal-brand
sudo systemctl start personal-brand
sudo systemctl status personal-brand
```

Logs:

```bash
sudo journalctl -u personal-brand -f
```

## 9. Nginx

Copy template and replace `YOUR_DOMAIN`:

```bash
sudo cp /home/nunuadmin/personal-brand-platform/docs/deployment/personal-brand.nginx.conf /etc/nginx/sites-available/personal-brand
sudo nano /etc/nginx/sites-available/personal-brand
sudo ln -s /etc/nginx/sites-available/personal-brand /etc/nginx/sites-enabled/personal-brand
sudo nginx -t
sudo systemctl reload nginx
```

Verify:

```bash
curl -I https://your-domain.com/health
curl https://your-domain.com/health
```

Expected body:

```txt
ok
```

## 10. Midtrans

Set HTTP Notification URL in Midtrans dashboard:

```txt
https://your-domain.com/webhooks/midtrans
```

Keep `MIDTRANS_SERVER_KEY` only in `/home/nunuadmin/personal-brand-platform/.env`.

## 10.5 Security Before Public Launch

- Replace `ADMIN_USERNAME` and `ADMIN_PASSWORD` in the VPS env file before exposing `/admin`.
- Keep `.env` readable only by the deploy user:

```bash
chmod 600 /home/nunuadmin/personal-brand-platform/.env
```

- Do not commit `.env`, database dumps, upload archives, Midtrans keys, admin password, or VPS passwords.

## 11. Post-Deploy Admin Checks

1. Open `/admin/login`.
2. Check Site Settings exists.
3. Mark 1-3 projects as `Best Three Homepage`.
4. Confirm uploaded media renders.
5. Test a free post.
6. Test a paid/tips post in Midtrans sandbox.
7. Check `/admin/orders` after payment notification.

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

- Elixir/Mix still need to be installed on VPS.
- Domain is not chosen yet.
- Production env values are not filled yet.
- Nginx/systemd templates are prepared but not installed yet.
