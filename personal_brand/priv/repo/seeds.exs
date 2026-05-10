# Seed data for Personal Brand Platform
#
# Run with: mix run priv/repo/seeds.exs

alias PersonalBrand.Repo
alias PersonalBrand.Content.Project
alias PersonalBrand.Content.Post
alias PersonalBrand.Content.Product
alias PersonalBrand.Content.SiteSetting
alias PersonalBrand.Content.Theme
alias PersonalBrand.Content.Tag

# ── Themes ─────────────────────────────────────────────────
themes = [
  %{
    key: "old_web_classic",
    name: "Old Web Classic",
    description: "Text-first, handmade, serif, blue links, and horizontal rules.",
    is_active: true,
    config: %{}
  },
  %{
    key: "simple",
    name: "Simple",
    description: "Clean, light, and easier to read for a general audience.",
    is_active: false,
    config: %{}
  },
  %{
    key: "us_builder",
    name: "US Builder",
    description: "Bolder builder positioning for shipping in public.",
    is_active: false,
    config: %{}
  },
  %{
    key: "premium_dark",
    name: "Premium Dark",
    description: "Developer aesthetic for apps, case studies, and products.",
    is_active: false,
    config: %{}
  }
]

Enum.each(themes, fn attrs ->
  Repo.insert!(struct!(Theme, attrs))
end)

IO.puts("✅ #{length(themes)} themes created")

# ── Site Settings ──────────────────────────────────────────
Repo.insert!(%SiteSetting{
  site_name: "Nunu Nugraha",
  headline: "A personal basecamp for work, writing, products, and things currently being built.",
  subheadline:
    "One data source, many homepage themes. This dummy UI is ready to be wired to Phoenix, PostgreSQL, and future commerce flows.",
  primary_cta_text: "View Work",
  primary_cta_url: "/work",
  secondary_cta_text: "Read Writing",
  secondary_cta_url: "/writing",
  active_theme: "old_web_classic",
  profile_name: "Nunu Nugraha",
  profile_title: "Flutter Developer, Builder, and Tech Enthusiast",
  profile_location: "Indonesia",
  profile_email: "hello@nununugraha.dev",
  profile_bio:
    "I build cross-platform mobile apps with Flutter, care about clean design and smooth performance, and share the lessons learned while shipping small useful products.",
  social_links: %{
    "GitHub" => "https://github.com/nununugraha",
    "X" => "https://x.com/nununugraha",
    "LinkedIn" => "https://linkedin.com",
    "Email" => "mailto:hello@nununugraha.dev"
  },
  featured_project_ids: [],
  featured_product_ids: []
})

IO.puts("✅ Site settings created")

# ── Projects ───────────────────────────────────────────────
projects = [
  %{
    title: "HabitKit",
    slug: "habitkit",
    summary: "Minimal habit tracker for iOS and Android.",
    description:
      "A clean, offline-first habit tracker with streaks, notes, calendar view, and simple analytics.",
    problem:
      "Most habit apps become too complex. HabitKit keeps the daily flow fast, clear, and motivating.",
    solution:
      "Focus on the core loop: track habits, stay consistent, see progress, and sync across devices.",
    result: ["1,000+ downloads in the first month", "4.8 average rating", "70%+ day-7 retention"],
    role: "Product Engineer",
    tech_stack: ["Flutter", "PostgreSQL", "SQLite"],
    year: "2025",
    status: "published",
    featured: true,
    demo_url: "https://example.com",
    github_url: "https://github.com"
  },
  %{
    title: "SplitWise++",
    slug: "splitwise-plus",
    summary: "Smart group expense splitter.",
    description:
      "Split expenses with friends, settle up faster, and track balances effortlessly.",
    problem: "Group spending gets messy when everyone pays at different times.",
    solution: "A simple ledger with smart settlement suggestions and shareable group summaries.",
    result: ["Prototype tested with travel groups", "Reduced manual settlement steps"],
    role: "Flutter Developer",
    tech_stack: ["Flutter", "Firebase", "Cloud Functions"],
    year: "2024",
    status: "published",
    featured: true,
    demo_url: "https://example.com"
  },
  %{
    title: "PromptBoard",
    slug: "promptboard",
    summary: "Prompt snippets for AI builders.",
    description: "Organize, version, and reuse prompts across LLM workflows.",
    problem: "Good prompts get scattered across notes, chats, and docs.",
    solution: "A small library for prompts, variables, tags, and shareable collections.",
    result: ["Used as daily internal tool", "Prepared for productized beta"],
    role: "Builder",
    tech_stack: ["Flutter", "Hive", "GitHub Gist API"],
    year: "2024",
    status: "published",
    featured: true,
    github_url: "https://github.com"
  }
]

Enum.each(projects, fn attrs ->
  Repo.insert!(struct!(Project, attrs))
end)

IO.puts("✅ #{length(projects)} projects created")

# ── Posts ──────────────────────────────────────────────────
posts = [
  %{
    title: "Building a Production-Ready Flutter App in 2026",
    slug: "production-ready-flutter-2026",
    excerpt: "The checklist I use before taking a Flutter app from prototype to shipped product.",
    content_markdown:
      "A production-ready app is less about one big framework choice and more about dozens of small decisions: routing, state boundaries, offline data, observability, release process, and boring reliability.",
    content_html:
      "<p>A production-ready app is less about one big framework choice and more about dozens of small decisions: routing, state boundaries, offline data, observability, release process, and boring reliability.</p>",
    tags: ["Flutter", "Shipping"],
    status: "published",
    featured: true,
    published_at: ~U[2026-04-20 00:00:00Z],
    reading_time: 7
  },
  %{
    title: "Offline-First is a Feature, Not a Fallback",
    slug: "offline-first-feature",
    excerpt: "Why local-first behavior can make everyday mobile apps feel calmer and faster.",
    content_markdown:
      "Offline-first product design starts with respect for the user's context. Network access should improve the app, not become the thing holding the app hostage.",
    content_html:
      "<p>Offline-first product design starts with respect for the user's context. Network access should improve the app, not become the thing holding the app hostage.</p>",
    tags: ["Product", "Mobile"],
    status: "published",
    featured: true,
    published_at: ~U[2026-03-16 00:00:00Z],
    reading_time: 5
  },
  %{
    title: "Design Systems for Indie Developers",
    slug: "design-systems-indie-developers",
    excerpt:
      "A practical way to keep small apps visually consistent without drowning in process.",
    content_markdown:
      "A tiny design system can be a folder of tokens, components, and clear defaults. The point is speed with consistency, not ceremony.",
    content_html:
      "<p>A tiny design system can be a folder of tokens, components, and clear defaults. The point is speed with consistency, not ceremony.</p>",
    tags: ["Design", "Flutter"],
    status: "published",
    featured: true,
    published_at: ~U[2026-02-25 00:00:00Z],
    reading_time: 6
  }
]

Enum.each(posts, fn attrs ->
  Repo.insert!(struct!(Post, attrs))
end)

IO.puts("✅ #{length(posts)} posts created")

# ── Products ───────────────────────────────────────────────
products = [
  %{
    title: "Flux Icons",
    slug: "flux-icons",
    summary: "Clean and consistent icon set for Flutter apps.",
    description:
      "A lightweight icon pack for indie developers who need clean symbols that look good in real products.",
    product_type: "digital",
    price: Decimal.new("29.00"),
    currency: "USD",
    status: "active",
    stock_status: "in_stock",
    delivery_type: "digital_download",
    checkout_url: "https://app.midtrans.com/payment-link/demo",
    featured: true,
    included: ["240+ icons", "Flutter-ready package", "Figma source", "Lifetime updates for v1"],
    faq: %{
      "Can I use it commercially?" => "Yes, the starter license allows use in your own apps.",
      "Is checkout already integrated?" => "For MVP this button goes to an external payment link."
    }
  },
  %{
    title: "SnipKit",
    slug: "snipkit",
    summary: "Useful UI and code snippets for Flutter builders.",
    description:
      "A practical snippet library for common product screens, empty states, settings pages, and app utilities.",
    product_type: "digital",
    price: Decimal.new("19.00"),
    currency: "USD",
    status: "coming_soon",
    stock_status: "preorder",
    delivery_type: "digital_download",
    checkout_url: "https://app.midtrans.com/payment-link/demo",
    featured: true,
    included: ["Flutter snippets", "Copy-ready patterns", "Usage notes"],
    faq: %{
      "When is it shipping?" => "The first version is planned after the platform MVP is live."
    }
  }
]

Enum.each(products, fn attrs ->
  Repo.insert!(struct!(Product, attrs))
end)

IO.puts("✅ #{length(products)} products created")

# ── Tags ────────────────────────────────────────────────────
tags = [
  %{name: "Flutter", slug: "flutter"},
  %{name: "Shipping", slug: "shipping"},
  %{name: "Product", slug: "product"},
  %{name: "Mobile", slug: "mobile"},
  %{name: "Design", slug: "design"},
  %{name: "Elixir", slug: "elixir"},
  %{name: "Phoenix", slug: "phoenix"},
  %{name: "PostgreSQL", slug: "postgresql"},
  %{name: "Firebase", slug: "firebase"},
  %{name: "AI", slug: "ai"}
]

tag_records =
  Enum.map(tags, fn attrs ->
    Repo.insert!(struct!(Tag, attrs))
  end)

IO.puts("✅ #{length(tag_records)} tags created")

# ── Tag Associations ────────────────────────────────────────
# Fetch inserted records
[habitkit, splitwise, promptboard] = Repo.all(from p in Project, order_by: [asc: p.title])
[prod_ready, offline_first, design_systems] = Repo.all(from p in Post, order_by: [asc: p.title])
[flux_icons, snipkit] = Repo.all(from p in Product, order_by: [asc: p.title])

tag_map = Enum.into(tag_records, %{}, fn t -> {t.name, t} end)

# Project tags
Repo.insert_all("project_tags", [
  %{id: Ecto.UUID.generate(), project_id: habitkit.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), project_id: habitkit.id, tag_id: tag_map["PostgreSQL"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), project_id: splitwise.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), project_id: splitwise.id, tag_id: tag_map["Firebase"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), project_id: promptboard.id, tag_id: tag_map["AI"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), project_id: promptboard.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
])

# Post tags
Repo.insert_all("post_tags", [
  %{id: Ecto.UUID.generate(), post_id: prod_ready.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), post_id: prod_ready.id, tag_id: tag_map["Shipping"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), post_id: offline_first.id, tag_id: tag_map["Product"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), post_id: offline_first.id, tag_id: tag_map["Mobile"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), post_id: design_systems.id, tag_id: tag_map["Design"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), post_id: design_systems.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
])

# Product tags
Repo.insert_all("product_tags", [
  %{id: Ecto.UUID.generate(), product_id: flux_icons.id, tag_id: tag_map["Design"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), product_id: flux_icons.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), product_id: snipkit.id, tag_id: tag_map["Flutter"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{id: Ecto.UUID.generate(), product_id: snipkit.id, tag_id: tag_map["Product"].id, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
])

IO.puts("✅ Tag associations created")

IO.puts("")
IO.puts("🎉 Seed complete!")
IO.puts("   Login: admin@personalbrand.dev / admin123")
IO.puts("   Site: http://localhost:4000")
