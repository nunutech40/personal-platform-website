# Personal Brand Platform

Phoenix LiveView personal brand platform untuk Nunu Nugraha: portfolio, writing/blog, product catalog, admin CMS, unified search, dan themeable public website.

## Stack

```txt
Elixir / Phoenix LiveView / Ecto / PostgreSQL
Backpex (admin CRUD) / MDEx (Markdown) / EasyMDE (editor)
Tailwind CSS + daisyUI (admin) / old_web_classic theme (public)
```

## Run Local

```bash
./scripts/start-local.sh --daemon
```

Atau manual:

```bash
cd personal_brand
mix ecto.setup
mix phx.server
```

```txt
Public:  http://localhost:4000
Admin:   http://localhost:4000/nunu-ops-7f3c (admin / admin123 locally)
Search:  http://localhost:4000/search
```

## Production

```txt
Public:  https://nunugraha.web.id
Work:    https://nunugraha.web.id/work
Health:  https://nunugraha.web.id/health
Admin:   https://nunugraha.web.id/nunu-ops-7f3c/login
```

Production runs on VPS `103.181.143.73` as systemd service `personal-brand`.
Deployment runbook: [docs/technical/VPS_DEPLOYMENT_PERSONAL_BRAND.md](docs/technical/VPS_DEPLOYMENT_PERSONAL_BRAND.md)

## Public Pages

| Route | Feature |
|-------|---------|
| `/` | Homepage — featured work, recent writing, products |
| `/work` | Portfolio — filter by discipline, load more, counts |
| `/work/:slug` | Case study detail |
| `/writing` | Blog — load more |
| `/writing/:slug` | Article (Markdown rendered) |
| `/products` | Product catalog — load more |
| `/products/:slug` | Product detail |
| `/search` | Unified search across all content |
| `/about` | About page |
| `/now` | Now page |
| `/contact` | Contact page |

## Documentation

```txt
docs/
├── architecture/   → system architecture, contexts, routes
├── planning/       → build plans, AI workflow, implementation slices
├── technical/      → local setup, field reference, admin workflow
├── standards/      → coding and testing standards
├── workflows/      → push, input project, edit project, fetch context
├── product/        → PRD (.docx)
├── design/         → design docs, UI mockups
└── README.md       → documentation index and read order
```

Start here: [docs/README.md](docs/README.md)

## Key Implementation Details

- **Disciplines taxonomy:** 12 controlled values (`mobile_developer`, `flutter_developer`, `ios_developer`, `swift`, `kotlin`, `flutter`, `android_developer`, `backend_developer`, `frontend_developer`, `fullstack_developer`, `ai_automation`, `cli_tooling`)
- **Search:** PostgreSQL ILIKE across projects/posts/products, LiveView real-time with debounce
- **Pagination:** Load more (9 per page) on work, writing, products
- **Admin:** private `/nunu-ops-7f3c` route, Backpex resources with custom delete modal, EasyMDE editor, project priority sorting, and commerce orders
- **Deploy/data:** production data is restored from local PostgreSQL dump plus `priv/static/uploads`; do not fresh deploy empty data when CMS edits must be preserved
- **Tests:** 263 tests (schema, context, commerce, LiveView, admin)

## Scripts

```bash
./scripts/start-local.sh           # Start PostgreSQL + Phoenix
./scripts/start-local.sh --daemon  # Background mode
./scripts/stop-local.sh            # Stop Phoenix
./scripts/status-local.sh          # Health check
./scripts/reset-local-db.sh --yes  # Reset dev database
```
