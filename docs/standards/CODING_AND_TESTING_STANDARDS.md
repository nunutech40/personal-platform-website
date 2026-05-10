# Coding And Testing Standards

Standar ini berlaku untuk semua implementasi final Personal Brand Platform, terutama saat project dipindahkan dari static prototype ke Phoenix LiveView + Supabase.

## Foundation

Stack final:

```txt
Elixir / Phoenix / LiveView
Ecto
Supabase Postgres
Supabase Storage
Midtrans Payment Link first, API/webhook later
```

Filosofi utama:

```txt
Data in, data out.
Business rules in contexts.
Validation in changesets.
Side effects at the edges.
Rendering receives assigns; it does not fetch data.
Tests prove behavior, not implementation details.
```

## Architecture Rules

### Contexts own business rules

LiveView tidak boleh langsung memanggil `Repo`.

Good:

```elixir
Portfolio.list_published_projects()
Content.get_published_post_by_slug(slug)
Catalog.update_product(product, attrs)
```

Bad:

```elixir
Repo.all(Project)
Repo.get_by(Post, slug: slug)
```

### Components and themes render only

Components/theme modules menerima assigns atau shared theme data contract.

They must not:

```txt
- query database
- call Supabase
- call Midtrans
- mutate business state
```

### Side effects stay at integration boundaries

Side-effect modules:

```txt
Media.Storage       -> Supabase Storage
Commerce.Midtrans   -> future Midtrans API
Mailer              -> future email
```

Side-effect functions should return:

```elixir
{:ok, value}
{:error, reason}
```

## Elixir Style Rules

- Prefer small pure functions.
- Prefer pipelines for readable transformations.
- Prefer pattern matching over nested conditionals.
- Prefer explicit context APIs over generic helpers.
- Use `with` for multi-step operations that can fail.
- Return `{:ok, value}` / `{:error, reason}` for fallible operations.
- Use changesets for external/admin input validation.
- Keep slug/status/featured fallback logic testable as pure functions when possible.

## Ecto Rules

Every persisted entity should have:

```txt
schema
changeset
migration constraints
context create/update/list/get functions
tests
```

Required DB protections:

```txt
unique indexes for slugs
foreign keys for relations
indexes for status/published_at where queried
unique constraints for join table pairs
```

Changeset validations should align with database constraints.

## Supabase Rules

Supabase is infrastructure:

```txt
Postgres via Ecto
Storage via server-side integration module
```

Do not:

```txt
- put Supabase service role key in frontend
- call Storage directly from LiveView components
- use public URLs for future paid digital downloads
```

## Testing Policy

Yes, BE unit tests are required.

Every backend slice should add tests at the lowest useful layer:

```txt
Pure/unit tests     -> slug/status/theme resolver/fallback logic
Context tests       -> changesets, queries, public visibility, CRUD flows
LiveView tests      -> routes, assigns, forms, redirects, auth boundaries
Integration tests   -> wrappers around Supabase/Midtrans with mocked boundaries
Manual QA           -> visual navigation and local browser checks
```

## Minimum Tests By Slice

### Database/schema slices

Required:

```txt
changeset accepts valid attrs
changeset rejects missing/invalid attrs
unique slug constraint
relationship constraints
seed assumptions when relevant
```

### Publishing workflow slices

Required:

```txt
draft content is hidden from public queries
published content is visible
archived content is hidden
slug remains stable after publish unless explicitly changed
featured fallback returns expected content
```

### Theme system slices

Required:

```txt
valid active_theme resolves expected theme
invalid active_theme falls back safely
theme receives data contract
theme module does not query Repo
```

### LiveView public pages

Required:

```txt
route renders
navigation exists
slug detail renders public item
missing/draft slug returns not found
page title/meta assigned when relevant
```

### Admin forms

Required:

```txt
unauthenticated user cannot access admin route
valid submit creates/updates record
invalid submit shows changeset errors
draft/publish/archive action works
```

### Media/Supabase slices

Required:

```txt
file validation works
storage wrapper returns {:ok, value} or {:error, reason}
media record is created after upload success
partial failure is handled
service role key stays server-side
```

### Product checkout slices

Required:

```txt
active product with checkout_url shows Buy Now
missing checkout_url does not show broken checkout
coming_soon product shows safe state
future payment secrets are not exposed
```

## Test Commands

Prototype stage:

```bash
node --check src/app.js
node --check server.mjs
bash -n scripts/start-local.sh scripts/stop-local.sh scripts/status-local.sh
```

Phoenix stage:

```bash
mix format --check-formatted
mix test
```

Optional later:

```bash
mix credo --strict
mix sobelow
```

## Definition Of Done

A slice is done when:

```txt
- implementation follows context/component/integration boundaries
- tests cover the behavior introduced by the slice
- no draft/private data leaks publicly
- no secrets are committed or exposed to frontend
- docs/build plan are updated if behavior or architecture changed
- push workflow checks pass before commit
```

