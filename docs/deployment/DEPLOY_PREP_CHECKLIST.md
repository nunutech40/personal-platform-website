# Deploy Prep Checklist - Personal Brand Platform

Last checked: 2026-05-24.

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
- Login page no longer displays the local default password.
- Products are always paid, reject price `0`, and use a paid-post-style checkout gate.
- Paid/tips posts and products create orders and use Midtrans/manual fallback.

## VPS Inputs Still Needed

- Domain name: `nunugraha.web.id`.
- Cloudflare DNS records:
  - `A nunugraha.web.id 103.181.143.73`
  - `A www.nunugraha.web.id 103.181.143.73`
- Production `.env` values:
  - `PHX_HOST=nunugraha.web.id`
  - `SECRET_KEY_BASE`
  - `DATABASE_URL`
  - `ADMIN_USERNAME`
  - `ADMIN_PASSWORD`
  - `UPLOADS_DIR`
  - `MIDTRANS_SERVER_KEY`
  - `MIDTRANS_ENV`
  - `PAYMENT_NOTIFICATION_TO`
  - `PAYMENT_NOTIFICATION_FROM`
  - `SMTP_HOST`
  - `SMTP_PORT`
  - `SMTP_USERNAME`
  - `SMTP_PASSWORD`
- Decision: restore local data/uploads so no CMS content is left behind.

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
- Elixir/Mix: not installed

Do not install Ubuntu apt `elixir` unless it provides `>= 1.15`; apt currently offers `1.14`, while the app requires `~> 1.15`.

## Data Migration Reminder

To carry all local content to VPS, migrate both:

- PostgreSQL data: `pg_dump -Fc personal_brand_dev`
- Uploaded files: `personal_brand/priv/static/uploads`

After restoring the dump on VPS, run migrations again so newer schema changes are applied.

## Do Not Commit

- `.env`
- database dumps
- upload archives
- Midtrans keys
- SMTP password
- admin password
- VPS credentials
