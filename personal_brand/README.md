# Personal Brand Platform

Personal brand website milik Nunu Nugraha — portfolio, writing, products, dan admin CMS.

## Stack

- **Backend:** Elixir / Phoenix LiveView
- **Database:** PostgreSQL (Ecto)
- **Admin:** Backpex LiveResources
- **Styling:** Tailwind CSS + daisyUI (admin), old_web_classic theme (public)
- **Markdown:** MDEx (Rust-based renderer)
- **Editor:** EasyMDE (admin post editor)

## Quick Start

```bash
# Prerequisites: Elixir >= 1.17, PostgreSQL 16, Node.js >= 18

# Start PostgreSQL
brew services start postgresql@16

# Setup database
mix ecto.setup

# Start server
mix phx.server

# Open browser
open http://localhost:4000
```

Atau pakai script dari root repo:

```bash
./scripts/start-local.sh --daemon
```

## Routes

### Public

| Route | Description |
|-------|-------------|
| `/` | Homepage |
| `/work` | Project portfolio (load more, filter by discipline) |
| `/work/:slug` | Project case study detail |
| `/writing` | Blog/writing list (load more) |
| `/writing/:slug` | Article detail (Markdown rendered) |
| `/products` | Product catalog (load more) |
| `/products/:slug` | Paid product detail + checkout gate |
| `/checkout/writing/:slug` | Paid/tips post checkout |
| `/checkout/products/:slug` | Product purchase checkout |
| `/webhooks/midtrans` | Midtrans HTTP notification webhook |
| `/health` | Production health check |
| `/about` | About page |
| `/now` | Now page |
| `/contact` | Contact page |
| `/search` | Unified search across all content |

### Admin

| Route | Description |
|-------|-------------|
| `/admin` | Dashboard |
| `/admin/projects` | CRUD projects (Backpex) |
| `/admin/posts` | CRUD posts with Markdown editor |
| `/admin/products` | CRUD products |
| `/admin/orders` | Review commerce orders and fulfillment state |
| `/admin/media` | Media library |
| `/admin/site-settings` | Site settings (singleton) |
| `/admin/themes` | Theme registry |

**Local default login:** `admin` / `admin123`. Production should set `ADMIN_USERNAME` and `ADMIN_PASSWORD` in the env file.

## Key Features

- Auto-generated slugs from title
- Discipline/platform taxonomy with checkbox admin UI
- Load more pagination (9 items per page)
- Unified search across projects, posts, products
- Post monetization: free, tips-gated, and paid gated posts
- Product checkout: products are always paid, with checkout preview/CTA, Midtrans Snap or manual link fallback
- Orders and access grants for paid posts, tips, and product purchases
- Midtrans webhook endpoint with signature verification
- Project `best_three` flag for homepage Featured Work
- Public writing claps with writing list sorted by clap count
- Filter counts on `/work` page
- EasyMDE Markdown editor with toolbar
- Delete confirmation modal (Indonesian copy)
- SEO meta tags (Open Graph, Twitter Card)
- Cover image and certificate PDF support
- old_web_classic retro theme

## Documentation

Full docs at `../docs/`:

- Architecture: `docs/architecture/`
- Planning: `docs/planning/`
- Technical: `docs/technical/`
- Workflows: `docs/workflows/`
- Standards: `docs/standards/`

## Testing

```bash
mix format --check-formatted
mix test
```

249 tests covering schema, context, commerce, LiveView, and admin routes.
