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

import Ecto.Query


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
    "One Phoenix LiveView app, one PostgreSQL-backed content source, and multiple theme renderers for the same work, writing, and products.",
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
    title: "RajaOngkir iOS App",
    slug: "rajaongkir-ios-app",
    summary:
      "Aplikasi iOS untuk membantu pengguna cek ongkir, tracking, dan workflow pengiriman.",
    description:
      "Project mobile utama di Komerce yang menghubungkan kebutuhan shipping harian ke pengalaman iOS yang lebih cepat, stabil, dan mudah dipahami pengguna operasional.",
    problem:
      "Pengguna membutuhkan akses cepat untuk cek ongkir dan tracking tanpa harus berpindah-pindah tool. Dari sisi engineering, app perlu punya struktur yang mudah dirawat saat fitur shipping terus berkembang.",
    solution:
      "Memimpin pengembangan mobile dengan standar code review, MVVM, repository pattern, dan modular boundary supaya fitur shipping bisa berkembang tanpa membuat codebase sulit dipahami.",
    result: [
      "Membantu mobile division punya standar implementasi dan review yang lebih konsisten.",
      "Menyediakan fondasi app iOS yang lebih siap untuk iterasi fitur shipping berikutnya."
    ],
    role: "Chapter Lead Mobile Developer",
    tech_stack: ["Swift", "UIKit", "SwiftUI", "MVVM", "Repository Pattern", "GitLab CI/CD"],
    year: "2021-2026",
    status: "published",
    featured: true,
    project_type: "professional_work",
    company: "Komerce",
    platforms: ["ios"],
    disciplines: ["ios_development", "mobile_engineering_lead", "architecture"],
    ownership:
      "Lead mobile engineer untuk standar engineering, review, dan delivery aplikasi iOS.",
    team_size: "Mobile division",
    duration: "2021-2026",
    impact_summary:
      "Menunjukkan kemampuan memimpin mobile engineering sekaligus tetap dekat dengan implementasi teknis iOS.",
    technical_highlights: [
      "Standarisasi code review dan clean architecture untuk tim mobile.",
      "Pemisahan responsibility melalui MVVM dan repository pattern.",
      "Penguatan proses delivery melalui CI/CD."
    ],
    architecture_notes:
      "Architecture diarahkan supaya domain shipping, presentation layer, dan data access tidak saling bergantung langsung.",
    tradeoffs:
      "Detail bisnis internal diringkas, fokus publik diarahkan ke ownership, engineering process, dan pattern teknis yang aman dibagikan.",
    metrics: [
      "Leadership scope: mobile division",
      "Project context: production shipping workflow"
    ],
    case_study_visibility: "limited",
    sort_order: 1
  },
  %{
    title: "iOS Distributed Modular Architecture",
    slug: "ios-distributed-modular-architecture",
    summary:
      "Showcase arsitektur iOS modular berbasis micro-features dan dependency boundary yang ketat.",
    description:
      "Project arsitektur untuk menunjukkan bagaimana aplikasi iOS bisa dipecah menjadi Core, Features, dan InfraShared tanpa membuat dependency antar modul menjadi liar.",
    problem:
      "Codebase iOS yang tumbuh besar sering menjadi sulit dites, sulit dipahami, dan rawan coupling antar fitur.",
    solution:
      "Membangun struktur modular dengan Swift Package Manager, protocol-based dependency, DI container, dan Coordinator/Router agar tiap fitur punya batas yang jelas.",
    result: [
      "Menjadi bukti teknis untuk seniority di architecture design.",
      "Memudahkan diskusi teknis tentang dependency direction, testability, dan modular scaling."
    ],
    role: "iOS Architecture Builder",
    tech_stack: ["Swift", "SwiftUI", "Combine", "SPM", "Clean Architecture", "Realm"],
    year: "2025",
    status: "published",
    featured: true,
    project_type: "architecture_demo",
    platforms: ["ios"],
    disciplines: ["ios_development", "architecture"],
    ownership: "Solo builder untuk eksplorasi dan dokumentasi architecture pattern.",
    duration: "2025",
    impact_summary:
      "Memperlihatkan kemampuan merancang struktur aplikasi iOS yang scalable, testable, dan mudah dikembangkan.",
    technical_highlights: [
      "Micro-feature modules menggunakan Swift Package Manager.",
      "Dependency inversion melalui protocol dan DI container.",
      "Navigation dipisah melalui Coordinator/Router."
    ],
    architecture_notes:
      "Core module menyimpan kontrak dan shared domain, feature module fokus pada user flow, dan infrastructure module menangani detail persistence/network.",
    tradeoffs:
      "Modularisasi menambah biaya setup awal, tetapi memberi payoff pada maintainability, testing, dan onboarding engineer.",
    metrics: [
      "Architecture scope: Core, Features, InfraShared",
      "Primary goal: testability and dependency control"
    ],
    case_study_visibility: "public",
    sort_order: 2
  },
  %{
    title: "Postie",
    slug: "postie",
    summary: "Native macOS API client ringan untuk testing request tanpa overhead besar.",
    description:
      "Tool macOS untuk kebutuhan network testing sehari-hari, dibuat sebagai alternatif ringan untuk API client yang terasa berat untuk workflow sederhana.",
    problem:
      "Developer sering butuh mengetes API cepat, tetapi tool umum bisa terasa berat, lambat dibuka, dan memakai resource besar.",
    solution:
      "Membangun API client native dengan Swift, AppKit/SwiftUI, URLSession, konfigurasi timeout/cache, dan persistence sederhana yang aman.",
    result: [
      "Menunjukkan kemampuan membangun native developer tool di macOS.",
      "Menjadi portfolio open-source yang bisa direview langsung dari GitHub."
    ],
    role: "macOS App Developer",
    tech_stack: ["Swift", "SwiftUI", "AppKit", "URLSession", "File Persistence"],
    year: "2025",
    status: "published",
    featured: true,
    github_url: "https://github.com/nunutech40/Postie/tree/main",
    project_type: "open_source",
    platforms: ["macos"],
    disciplines: ["macos_development", "performance_optimization"],
    ownership: "Solo builder dari konsep, implementation, sampai repository publik.",
    duration: "2025",
    impact_summary:
      "Membuktikan kemampuan membuat tool native yang fokus pada resource usage, UX sederhana, dan reliability.",
    technical_highlights: [
      "Native request flow berbasis URLSession.",
      "Atomic file persistence untuk menyimpan workspace/request.",
      "Error mapping untuk membuat failure network lebih mudah dipahami."
    ],
    architecture_notes:
      "App dipisah antara request configuration, execution, persistence, dan presentation agar logic network tidak terkunci di UI.",
    tradeoffs:
      "Persistence file dipilih untuk menjaga aplikasi tetap ringan dibanding langsung membawa database layer yang lebih kompleks.",
    metrics: [
      "Target memory footprint: lightweight native app",
      "Distribution: public GitHub repository"
    ],
    case_study_visibility: "public",
    sort_order: 3
  },
  %{
    title: "Prodia Booking Flow Optimization",
    slug: "prodia-booking-flow-optimization",
    summary:
      "Optimasi flow booking iOS untuk mengurangi hang, memory issue, dan masalah session.",
    description:
      "Pekerjaan contractor iOS yang berfokus pada stabilitas dan kelancaran flow booking agar user tidak terganggu saat menyelesaikan proses penting.",
    problem:
      "Flow booking mengalami gejala UI hang, memory leak, dan session timer yang bisa memicu logout acak.",
    solution:
      "Melakukan investigasi bottleneck, memperbaiki lifecycle/state handling, dan mengoptimalkan area yang mengganggu conversion flow.",
    result: [
      "Flow booking menjadi lebih stabil dari sisi pengalaman pengguna.",
      "Risiko user gagal menyelesaikan proses booking karena issue teknis berkurang."
    ],
    role: "iOS Developer Contractor",
    tech_stack: ["Swift", "UIKit", "Xcode Instruments", "Memory Debugging"],
    year: "2024",
    status: "published",
    featured: true,
    project_type: "client_work",
    company: "Prodia",
    platforms: ["ios"],
    disciplines: ["ios_development", "performance_optimization"],
    ownership: "Contributor iOS untuk investigasi dan perbaikan flow booking.",
    duration: "Contract project",
    impact_summary:
      "Menunjukkan kemampuan debugging production-like issue yang berdampak langsung ke conversion flow.",
    technical_highlights: [
      "Investigasi memory leak dan UI hang.",
      "Perbaikan state/session behavior di flow booking.",
      "Optimasi area yang mempengaruhi conversion funnel."
    ],
    architecture_notes:
      "Fokus teknis berada pada lifecycle, state consistency, dan performa UI di flow yang sensitif terhadap drop-off.",
    tradeoffs:
      "Detail internal aplikasi tidak dibuka; case study menekankan jenis problem, pendekatan debugging, dan impact engineering.",
    metrics: ["Focus area: booking funnel", "Issue class: memory leak, UI hang, session timeout"],
    case_study_visibility: "limited",
    sort_order: 4
  },
  %{
    title: "Personal Platform Website",
    slug: "personal-platform-website",
    summary:
      "Platform personal berbasis Phoenix LiveView untuk portfolio, writing, product, dan admin CMS.",
    description:
      "Website personal yang dirancang sebagai single source of truth untuk portfolio kerja, tulisan, produk digital, dan konten yang bisa dikelola dari admin.",
    problem:
      "Portfolio statis sulit dijaga konsisten ketika kebutuhan berubah: recruiter butuh case study, admin butuh CRUD, dan public page butuh data yang rapi.",
    solution:
      "Membangun Phoenix LiveView app dengan PostgreSQL, Ecto, Backpex admin, taxonomy project, auto slug, dan public `/work` detail berbasis case study.",
    result: [
      "Public work page bisa menampilkan project berdasarkan discipline/platform.",
      "Admin bisa create dan edit project dengan data case study yang lebih lengkap."
    ],
    role: "Full-stack Software Engineer",
    tech_stack: [
      "Elixir",
      "Phoenix LiveView",
      "PostgreSQL",
      "Ecto",
      "Backpex",
      "Tailwind CSS",
      "daisyUI"
    ],
    year: "2026",
    status: "published",
    featured: true,
    project_type: "personal_project",
    platforms: ["web", "backend"],
    disciplines: ["fullstack_engineering", "backend_engineering", "frontend_engineering"],
    ownership:
      "Solo full-stack builder untuk product, backend, admin, public UI, dan dokumentasi.",
    duration: "2026",
    impact_summary:
      "Menjadi platform utama untuk menunjukkan project portfolio secara recruiter-friendly.",
    technical_highlights: [
      "Phoenix LiveView public pages.",
      "Backpex admin CRUD untuk content management.",
      "Ecto schema dan migration untuk taxonomy portfolio.",
      "Slug generation untuk public route yang stabil."
    ],
    architecture_notes:
      "Content context menjadi boundary utama untuk query publik/admin, sedangkan LiveView hanya mengatur state dan rendering.",
    tradeoffs:
      "Taxonomy memakai array field terlebih dahulu agar cepat dikirim untuk kebutuhan job search, dengan opsi normalisasi di fase berikutnya.",
    metrics: ["162 automated tests passing", "Primary public routes: /work and /work/:slug"],
    case_study_visibility: "public",
    sort_order: 5
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
# Fetch inserted records by slug (more stable than relying on order)
project_map =
  Repo.all(from p in Project)
  |> Map.new(fn p -> {p.slug, p} end)

[prod_ready, offline_first, design_systems] = Repo.all(from p in Post, order_by: [asc: p.title])
[flux_icons, snipkit] = Repo.all(from p in Product, order_by: [asc: p.title])

tag_map = Enum.into(tag_records, %{}, fn t -> {t.name, t} end)

# Project tags
rajaongkir = project_map["rajaongkir-ios-app"]
ios_modular = project_map["ios-distributed-modular-architecture"]
postie = project_map["postie"]
prodia = project_map["prodia-booking-flow-optimization"]
personal_platform = project_map["personal-platform-website"]

Repo.insert_all("project_tags", [
  %{
    id: Ecto.UUID.generate(),
    project_id: rajaongkir.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: ios_modular.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: postie.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: prodia.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: personal_platform.id,
    tag_id: tag_map["Elixir"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: personal_platform.id,
    tag_id: tag_map["Phoenix"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    project_id: personal_platform.id,
    tag_id: tag_map["PostgreSQL"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])


# Post tags
Repo.insert_all("post_tags", [
  %{
    id: Ecto.UUID.generate(),
    post_id: prod_ready.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    post_id: prod_ready.id,
    tag_id: tag_map["Shipping"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    post_id: offline_first.id,
    tag_id: tag_map["Product"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    post_id: offline_first.id,
    tag_id: tag_map["Mobile"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    post_id: design_systems.id,
    tag_id: tag_map["Design"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    post_id: design_systems.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])

# Product tags
Repo.insert_all("product_tags", [
  %{
    id: Ecto.UUID.generate(),
    product_id: flux_icons.id,
    tag_id: tag_map["Design"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    product_id: flux_icons.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    product_id: snipkit.id,
    tag_id: tag_map["Flutter"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  },
  %{
    id: Ecto.UUID.generate(),
    product_id: snipkit.id,
    tag_id: tag_map["Product"].id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])

IO.puts("✅ Tag associations created")

IO.puts("")
IO.puts("🎉 Seed complete!")
IO.puts("   Login: admin@personalbrand.dev / admin123")
IO.puts("   Site: http://localhost:4000")
