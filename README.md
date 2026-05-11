# Personal Brand Platform

Phoenix LiveView personal brand platform untuk Nunu Nugraha: portfolio, writing/blog, product catalog, admin-managed content, dan themeable public website.

Source of truth utama:

- [Architecture](docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md)
- [Design](docs/design/Design_Document_Old_Web_Personal_Brand_Platform.docx)
- [Local Setup](docs/technical/LOCAL_SETUP.md)

## Run Local

```bash
./scripts/start-local.sh
```

Atau manual:

```bash
cd personal_brand
mix ecto.setup
mix phx.server
```

Buka:

```text
http://localhost:4000/
```

Admin:

```text
http://localhost:4000/admin
admin / admin123
```

## Frontend

Frontend publik sekarang dirender oleh Phoenix LiveView di `personal_brand/`.

- Public LiveView: `personal_brand/lib/personal_brand_web/live/public_live.ex`
- Public layout: `personal_brand/lib/personal_brand_web/components/layouts/public.html.heex`
- CSS/theme styles: `personal_brand/assets/css/app.css`

Static prototype root lama sudah dihapus. Jangan pakai `npm run dev` atau port `5173` untuk mengecek frontend.
