# Deploy Prep Checklist - Personal Brand Platform

Last checked: 2026-05-17.

## Local Readiness

- `mix ecto.migrate` applied locally, including `20260517090000_standardize_product_monetization` and `20260517093000_update_product_checkout_defaults`.
- `mix format --check-formatted` passes.
- `mix test` passes with 249 tests.
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

- Domain name.
- Cloudflare DNS records:
  - `A @ 103.181.143.73`
  - `A www 103.181.143.73`
- Production `.env` values:
  - `PHX_HOST`
  - `SECRET_KEY_BASE`
  - `DATABASE_URL`
  - `ADMIN_USERNAME`
  - `ADMIN_PASSWORD`
  - `UPLOADS_DIR`
  - `MIDTRANS_SERVER_KEY`
  - `MIDTRANS_ENV`
- Decision: restore local data/uploads or start fresh.

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
- admin password
- VPS credentials
