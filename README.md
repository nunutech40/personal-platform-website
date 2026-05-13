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
Admin:   http://localhost:4000/admin (admin / admin123)
Search:  http://localhost:4000/search
```

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
- **Admin:** Backpex resources with custom delete modal, EasyMDE editor, sorted by `updated_at DESC`
- **Tests:** 221 tests (schema, context, LiveView, admin)

## Scripts

```bash
./scripts/start-local.sh           # Start PostgreSQL + Phoenix
./scripts/start-local.sh --daemon  # Background mode
./scripts/stop-local.sh            # Stop Phoenix
./scripts/status-local.sh          # Health check
./scripts/reset-local-db.sh --yes  # Reset dev database
```
