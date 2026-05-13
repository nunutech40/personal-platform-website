# Building Plan — Unified Search

## 0. Purpose

Membangun halaman search publik yang bisa mencari konten di seluruh website: Projects, Writing (Posts), dan Products — dalam satu input field.

Goal: visitor/recruiter bisa menemukan konten apapun tanpa harus tahu di halaman mana konten itu berada.

## 1. User Experience

### Route

```txt
/search
/search?q=flutter
```

### Flow

```txt
1. User buka /search → halaman kosong dengan input search besar
2. User mulai ketik → debounce 300ms → query dikirim ke server
3. Loading state muncul (animasi CSS ringan)
4. Hasil tampil grouped: Projects, Writing, Products
5. Klik item → redirect ke detail masing-masing
6. Jika tidak ada hasil → empty state yang helpful
```

### Default State (Belum Search)

```txt
- Input search besar di tengah
- Placeholder: "Cari project, tulisan, atau produk..."
- Suggestion tags di bawah: "Try: Flutter, Architecture, Phoenix, iOS"
- Tidak ada hasil ditampilkan
```

### Loading State

```txt
- Animasi CSS-only (3 dots bouncing atau typing cursor)
- Cocok dengan old_web_classic aesthetic (serif, minimal)
- Tidak pakai Lottie, GIF, atau library eksternal
- Muncul setelah debounce trigger, hilang saat hasil muncul
```

### Result State

```txt
- Grouped by content type:
  - 🔨 Projects (max 5 items)
  - ✍️ Writing (max 5 items)
  - 📦 Products (max 5 items)
- Setiap item tampil: title + snippet/excerpt + meta
- Link ke detail masing-masing (/work/:slug, /writing/:slug, /products/:slug)
- Total count per group: "3 projects ditemukan"
- Jika satu group kosong, group itu tidak ditampilkan
```

### Empty State (Tidak Ada Hasil)

```txt
- "Tidak ada hasil untuk 'query'"
- Suggestion: "Coba kata kunci lain atau lihat semua Work / Writing / Products"
```

## 2. Teknologi & Arsitektur

### Stack

```txt
- Phoenix LiveView (real-time search tanpa page reload)
- PostgreSQL ILIKE (pattern matching, case-insensitive)
- Ecto dynamic queries
- CSS-only loading animation
- phx-change dengan phx-debounce="300" untuk input
```

### Kenapa LiveView + ILIKE?

| Opsi | Pro | Kontra | Keputusan |
|---|---|---|---|
| LiveView + ILIKE | Simple, no dependency, instant untuk data kecil | Tidak ada relevance ranking | ✅ Pakai untuk MVP |
| PostgreSQL tsvector (full-text search) | Ranking, stemming, bahasa | Setup lebih kompleks, overkill untuk <100 records | ⏳ Upgrade nanti |
| Elasticsearch/Meilisearch | Typo tolerance, facets, super fast | External service, deployment complexity | ❌ Tidak perlu |
| Client-side search (JS) | Zero latency | Data harus di-load semua ke browser, tidak scalable | ❌ Tidak cocok |

### Kenapa Bukan Full-Text Search Dulu?

Data saat ini:
- ~30 projects
- ~5 posts
- ~5 products

Untuk skala ini, `ILIKE '%query%'` di PostgreSQL sudah instant (<10ms). Full-text search (tsvector) baru relevan kalau:
- Data >500 records
- Butuh relevance ranking
- Butuh stemming (cari "building" ketemu "build")
- Butuh typo tolerance

Upgrade path sudah jelas: ganti `ILIKE` ke `tsvector` di context function tanpa ubah UI.

## 3. Algoritma Search

### Query Strategy

```txt
1. Terima input string dari user
2. Trim dan lowercase
3. Jika kosong atau < 2 karakter → return empty
4. Split menjadi terms (by space) untuk multi-word search
5. Query 3 tables secara paralel (atau sequential, tergantung performance)
6. Setiap table: match ANY term di field yang relevan
7. Limit 5 per table
8. Return grouped results
```

### Fields yang Di-search Per Table

| Table | Fields | Alasan |
|---|---|---|
| projects | title, summary, description, problem, solution, role, tech_stack (array→text) | Recruiter cari by role, tech, atau problem domain |
| posts | title, excerpt, content_markdown, tags (array→text) | Reader cari by topic atau keyword di artikel |
| products | title, summary, description | Buyer cari by nama atau deskripsi produk |

### Matching Logic

```elixir
# Untuk setiap term, cek apakah ada di salah satu field
# Pakai ILIKE '%term%' dengan OR antar fields, AND antar terms

# Contoh: query "flutter architecture"
# → WHERE (title ILIKE '%flutter%' OR summary ILIKE '%flutter%' OR ...)
#   AND (title ILIKE '%architecture%' OR summary ILIKE '%architecture%' OR ...)
```

### Scoring (Future Enhancement)

MVP tidak pakai scoring — hasil diurutkan by `updated_at DESC` (terbaru dulu).

Future scoring bisa berdasarkan:
- Title match = weight 3x
- Summary/excerpt match = weight 2x
- Body match = weight 1x
- Featured item = bonus weight

## 4. Implementasi Detail

### Router

```elixir
# di router.ex, scope public
live "/search", PublicLive, :search
```

### Context Function

```elixir
# di content.ex
def search(query) when is_binary(query) do
  query = String.trim(query)

  if String.length(query) < 2 do
    %{projects: [], posts: [], products: []}
  else
    terms = query |> String.downcase() |> String.split(~r/\s+/, trim: true)

    %{
      projects: search_projects(terms),
      posts: search_posts(terms),
      products: search_products(terms)
    }
  end
end

defp search_projects(terms) do
  base = from(p in Project, where: p.status == "published", limit: 5, order_by: [desc: p.updated_at])

  Enum.reduce(terms, base, fn term, query ->
    pattern = "%#{term}%"
    from p in query,
      where: ilike(p.title, ^pattern)
          or ilike(p.summary, ^pattern)
          or ilike(p.description, ^pattern)
          or ilike(p.problem, ^pattern)
          or ilike(p.solution, ^pattern)
          or ilike(p.role, ^pattern)
  end)
  |> Repo.all()
end
```

### LiveView Handle

```elixir
# di public_live.ex handle_params
:search ->
  query = Map.get(params, "q", "")
  results = if query != "", do: Content.search(query), else: nil

  assign(socket,
    page: :search,
    page_title: "Search",
    search_query: query,
    search_results: results,
    search_loading: false
  )

# handle_event untuk live search
def handle_event("search", %{"q" => query}, socket) do
  results = if String.length(String.trim(query)) >= 2, do: Content.search(query), else: nil

  {:noreply, assign(socket,
    search_query: query,
    search_results: results,
    search_loading: false
  )}
end
```

### Template Structure

```heex
<section class="search-page">
  <h1>Search</h1>
  <form phx-change="search" phx-submit="search">
    <input
      type="text"
      name="q"
      value={@search_query}
      placeholder="Cari project, tulisan, atau produk..."
      phx-debounce="300"
      autocomplete="off"
      class="search-input"
    />
  </form>

  <!-- Loading -->
  <div :if={@search_loading} class="search-loading">
    <span class="dot"></span><span class="dot"></span><span class="dot"></span>
  </div>

  <!-- Results -->
  <div :if={@search_results}>
    <!-- Projects group -->
    <!-- Posts group -->
    <!-- Products group -->
    <!-- Empty state -->
  </div>

  <!-- Default suggestions -->
  <div :if={!@search_results && @search_query == ""} class="search-suggestions">
    <p>Try:</p>
    <a href="/search?q=Flutter">Flutter</a>
    <a href="/search?q=iOS">iOS</a>
    <a href="/search?q=Architecture">Architecture</a>
  </div>
</section>
```

### CSS Loading Animation

```css
.search-loading {
  display: flex;
  gap: 6px;
  justify-content: center;
  padding: 24px 0;
}

.search-loading .dot {
  width: 8px;
  height: 8px;
  background: var(--muted);
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.search-loading .dot:nth-child(1) { animation-delay: -0.32s; }
.search-loading .dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}
```

## 5. Navigation

Tambah "Search" ke navigation bar:

```txt
Home | Work | Writing | Products | About | Now | Contact | Search
```

Atau bisa juga sebagai icon 🔍 di sebelah kanan nav.

## 6. Performance Considerations

### Current Scale

```txt
~30 projects × 6 fields = ~180 ILIKE checks
~5 posts × 4 fields = ~20 ILIKE checks
~5 products × 3 fields = ~15 ILIKE checks
Total: ~215 ILIKE checks per search
Expected latency: <20ms
```

### Debounce

```txt
phx-debounce="300" → user berhenti ketik 300ms baru query dikirim
Ini mencegah spam query setiap keystroke
```

### Limit

```txt
Max 5 results per table = max 15 items ditampilkan
Jika user butuh lebih, redirect ke halaman masing-masing dengan filter
```

### Future Optimization (Jika Data Besar)

```txt
1. PostgreSQL tsvector + GIN index
2. Materialized search view yang di-refresh periodic
3. Search result caching (ETS atau Redis)
4. Trigram index (pg_trgm) untuk fuzzy matching
```

## 7. Testing Plan

### Unit Tests

```txt
- Content.search("flutter") returns projects with flutter in title/stack
- Content.search("") returns empty
- Content.search("x") returns empty (< 2 chars)
- Content.search("nonexistent") returns empty groups
- Draft/archived content tidak muncul di search
- Multi-word search: "flutter architecture" matches items with both words
```

### LiveView Tests

```txt
- GET /search renders search page
- Search input triggers results
- Results link to correct detail pages
- Empty state shows when no results
- Navigation includes Search link
```

### Manual QA

```txt
- Ketik "flutter" → project Flutter muncul
- Ketik "phoenix" → Personal Platform Website muncul
- Ketik "asdfghjkl" → empty state
- Ketik 1 karakter → tidak trigger search
- Loading animation muncul saat typing
- Mobile responsive
```

## 8. Implementation Slices

### Slice 1 — Route + Basic Search

```txt
- Add /search route
- Add Content.search/1 function
- Add search page template (input + results)
- Add navigation link
- Tests for context function
```

### Slice 2 — Loading Animation + Polish

```txt
- CSS loading animation
- Debounce UX
- Empty state
- Suggestion tags
- Responsive layout
```

### Slice 3 — Future Enhancement (Optional)

```txt
- Highlight matched text in results
- Search history (localStorage)
- Popular searches
- tsvector upgrade for relevance ranking
- URL sync (/search?q=flutter updates as you type)
```

## 9. Referensi

- [Phoenix LiveView — Form Bindings](https://hexdocs.pm/phoenix_live_view/form-bindings.html) — phx-change, phx-debounce
- [Ecto — Dynamic Queries](https://hexdocs.pm/ecto/dynamic-queries.html) — building queries with Enum.reduce
- [PostgreSQL ILIKE](https://www.postgresql.org/docs/current/functions-matching.html) — case-insensitive pattern matching
- [PostgreSQL Full Text Search](https://www.postgresql.org/docs/current/textsearch.html) — future upgrade path
- [CSS Animation — Bouncing Dots](https://developer.mozilla.org/en-US/docs/Web/CSS/animation) — loading indicator

## 10. Decision Log

| Keputusan | Alasan | Alternatif yang Tidak Dipilih |
|---|---|---|
| ILIKE untuk MVP | Data kecil (<50 records), instant, zero setup | tsvector (overkill), Meilisearch (external dep) |
| LiveView phx-change | Real-time feel tanpa JS custom | Form submit (page reload), JS fetch (extra complexity) |
| Debounce 300ms | Balance antara responsiveness dan server load | 0ms (too many queries), 500ms (feels slow) |
| Grouped results | User tahu context item (project vs post vs product) | Flat list (kehilangan context) |
| Max 5 per group | Cukup untuk discovery, tidak overwhelming | 10 (too many), 3 (too few) |
| CSS-only animation | Cocok old_web_classic, no dependency | Lottie (heavy), GIF (not themeable) |
| Search di nav | Discoverable, accessible dari mana saja | Hidden di footer (not discoverable) |
