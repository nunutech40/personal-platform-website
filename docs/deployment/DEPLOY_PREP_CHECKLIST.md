# Deploy Checklist - Personal Brand Platform

Last checked after production deploy: 2026-05-24.

## Local Readiness

- `mix ecto.migrate` applied locally, including `20260517090000_standardize_product_monetization` and `20260517093000_update_product_checkout_defaults`.
- `mix format --check-formatted` passes.
- `mix test` passes with 263 tests.
- Production compile check passes with env placeholders.
- `mix assets.deploy` passes with env placeholders.
- Build artifacts from `mix assets.deploy` are ignored by `.gitignore`.

## Code Readiness

- `/health` route returns `ok`.
- `UPLOADS_DIR` is supported for persistent VPS media storage.
- Admin credentials can be configured with `ADMIN_USERNAME` and `ADMIN_PASSWORD`.
- Private ops/admin route is `/nunu-ops-7f3c`.
- Login page no longer displays the local default password.
- Products are always paid, reject price `0`, and use a paid-post-style checkout gate.
- Paid/tips posts and products create orders and use Midtrans/manual fallback.

## Production Status

- Domain name: `nunugraha.web.id`.
- Public site: `https://nunugraha.web.id`.
- Health check: `https://nunugraha.web.id/health`.
- Ops/admin login: `https://nunugraha.web.id/nunu-ops-7f3c/login`.
- VPS app path: `/home/nunuadmin/personal-brand-platform`.
- Shared uploads path: `/home/nunuadmin/personal-brand-shared/uploads`.
- Env file path: `/home/nunuadmin/personal-brand-platform/.env`.
- Systemd service: `personal-brand`.
- Nginx site: `/etc/nginx/sites-available/personal-brand`.
- Production DB: `personal_brand_prod`.
- Production DB user: `personal_brand_user`.
- Current admin username: `nunuops`.
- Current admin password reminder: local Mac file `/private/tmp/personal_brand_prod_secrets.txt`, line 2.
- Deployed commit: `9f92c20 Prepare VPS deployment`.
- Cloudflare DNS records:
  - `A nunugraha.web.id 103.181.143.73`
  - `A www.nunugraha.web.id 103.181.143.73`
- Cloudflare SSL mode: `Full`.
- Restored data:
  - `29` projects
  - `2` posts
  - `5` media records
  - `1` site settings record
  - `10` upload files

## VPS Readiness Snapshot

Checked over SSH on 2026-05-24:

- Host: `BelajarSains`
- User: `nunuadmin`
- OS: Ubuntu 24.04.4 LTS
- CPU/RAM: 2 vCPU, 1.9 GiB RAM, 2.0 GiB swap
- Disk: 31G free on `/`
- PostgreSQL 16: active
- Nginx: active
- Port `4000`: free
- UFW: active, allows SSH + HTTP/HTTPS
- Git HTTPS to GitHub repo: works
- Git SSH to GitHub: not ready (`Host key verification failed`)
- Erlang: OTP 25
- Elixir/Mix: 1.15.8

Do not install Ubuntu apt `elixir` unless it provides `>= 1.15`; apt offered `1.14` during the first deploy, while the app requires `~> 1.15`. The VPS currently uses precompiled Elixir 1.15.8 in `/opt/elixir-1.15.8`.

## Follow-Up Deploy

For code-only deploys:

```bash
ssh nunuadmin@103.181.143.73
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
curl -fsS https://nunugraha.web.id/health
```

## Data Migration Reminder

To carry all local content changes from local dev to VPS, migrate both:

- PostgreSQL data: `pg_dump -Fc personal_brand_dev`
- Uploaded files: `personal_brand/priv/static/uploads`

After restoring the dump on VPS, run migrations again so newer schema changes are applied.

Do not run a fresh empty deploy if CMS content needs to be preserved.

## Remaining Setup

- Fill `MIDTRANS_SERVER_KEY` in VPS `.env` before testing paid checkout seriously.
- Fill SMTP env values in VPS `.env` before relying on paid-order email notifications.
- Configure GitHub SSH on VPS later if HTTPS pulls become annoying.

## Do Not Commit

- `.env`
- database dumps
- upload archives
- Midtrans keys
- SMTP password
- admin password
- VPS credentials
- `/private/tmp/personal_brand_prod_secrets.txt`
