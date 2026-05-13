defmodule PersonalBrandWeb.PublicLiveTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Content.{Media, Post, Product, Project}
  alias PersonalBrand.Content.SiteSetting
  alias PersonalBrand.Repo

  setup do
    Repo.insert!(%SiteSetting{
      site_name: "Test Site",
      headline: "Test headline",
      subheadline: "Test subheadline",
      active_theme: "old_web_classic"
    })

    :ok
  end

  test "GET /work lists published recruiter-facing projects", %{conn: conn} do
    insert_project(%{
      title: "RajaOngkir iOS App",
      slug: "rajaongkir-ios-app",
      status: "published",
      summary: "Aplikasi iOS untuk cek ongkir dan tracking.",
      role: "Mobile Engineering Lead",
      platforms: ["ios"],
      disciplines: ["ios_development", "mobile_engineering_lead"],
      impact_summary: "Menyatukan kebutuhan shipping ke dalam workflow mobile yang cepat.",
      featured: true
    })

    insert_project(%{
      title: "Postie",
      slug: "postie",
      status: "published",
      summary: "Native macOS API client untuk testing request.",
      platforms: ["macos"],
      disciplines: ["macos_development"]
    })

    insert_project(%{
      title: "Draft Project",
      slug: "draft-project",
      status: "draft",
      summary: "Hidden"
    })

    conn = get(conn, ~p"/work")

    html = html_response(conn, 200)
    assert html =~ "Featured Projects"
    assert html =~ "Other Projects"
    assert html =~ "RajaOngkir iOS App"
    assert html =~ "Postie"
    assert html =~ "Mobile Engineering Lead"
    assert html =~ "iOS"
    refute html =~ "Draft Project"
  end

  test "GET / renders empty database fallback without seeded settings", %{conn: conn} do
    Repo.delete_all(SiteSetting)

    conn = get(conn, ~p"/")

    html = html_response(conn, 200)
    assert html =~ "No public content has been published yet."
    assert html =~ "No featured work yet."
    assert html =~ "No writing published yet."
    assert html =~ "No featured products yet."
  end

  test "GET /about /now /contact render CMS-managed settings", %{conn: conn} do
    setting = Repo.one!(SiteSetting)

    setting
    |> Ecto.Changeset.change(%{
      profile_email: "hello@example.com",
      social_links: %{"GitHub" => "https://github.com/nunu"},
      about_intro: "I build useful software.",
      about_focus: "I focus on mobile and Phoenix platforms.",
      about_tools: ["Elixir", "Phoenix LiveView", "Flutter"],
      about_values: ["Readable code", "Useful products"],
      now_building: "Admin-driven public pages",
      now_learning: "Midtrans payment flows",
      now_focus: "Portfolio polish",
      now_updated_at: ~D[2026-05-12],
      saweria_url: "https://saweria.co/nunu",
      buy_me_coffee_url: "https://www.buymeacoffee.com/nunu"
    })
    |> Repo.update!()

    about_html =
      conn
      |> get(~p"/about")
      |> html_response(200)

    assert about_html =~ "I build useful software."
    assert about_html =~ "Phoenix LiveView"
    assert about_html =~ "Useful products"

    now_html =
      conn
      |> get(~p"/now")
      |> html_response(200)

    assert now_html =~ "Admin-driven public pages"
    assert now_html =~ "Midtrans payment flows"
    assert now_html =~ "Updated May 12, 2026"

    contact_html =
      conn
      |> get(~p"/contact")
      |> html_response(200)

    assert contact_html =~ "hello@example.com"
    assert contact_html =~ "GitHub"
    assert contact_html =~ "Saweria"
    assert contact_html =~ "Buy Me Coffee"
  end

  test "GET /work filters by platform", %{conn: conn} do
    insert_project(%{
      title: "Postie",
      slug: "postie",
      status: "published",
      platforms: ["macos"],
      disciplines: ["macos_development"]
    })

    insert_project(%{
      title: "Personal Platform Website",
      slug: "personal-platform-website",
      status: "published",
      platforms: ["web"],
      disciplines: ["fullstack_engineering"]
    })

    conn = get(conn, ~p"/work?platform=macos")

    html = html_response(conn, 200)
    assert html =~ "Postie"
    refute html =~ "Personal Platform Website"
  end

  test "GET /work filters by discipline", %{conn: conn} do
    insert_project(%{
      title: "Postie",
      slug: "postie",
      status: "published",
      platforms: ["macos"],
      disciplines: ["macos_development"]
    })

    insert_project(%{
      title: "Personal Platform Website",
      slug: "personal-platform-website",
      status: "published",
      platforms: ["web"],
      disciplines: ["fullstack_engineering"]
    })

    conn = get(conn, ~p"/work?discipline=fullstack_engineering")

    html = html_response(conn, 200)
    assert html =~ "Personal Platform Website"
    refute html =~ "Postie"
  end

  test "GET /work/:slug renders published case study detail", %{conn: conn} do
    Repo.one!(SiteSetting)
    |> Ecto.Changeset.change(%{profile_email: "hello@example.com"})
    |> Repo.update!()

    certificate =
      Repo.insert!(%Media{
        filename: "flutter-certificate.pdf",
        content_type: "application/pdf",
        url: "/uploads/media/flutter-certificate.pdf",
        alt_text: "Flutter certificate PDF"
      })

    insert_project(%{
      title: "Personal Platform Website",
      slug: "personal-platform-website",
      status: "published",
      summary: "CMS portfolio berbasis Phoenix LiveView.",
      description: "Platform personal untuk menampilkan work, writing, dan products.",
      problem: "Portfolio perlu mudah dikelola dari admin.",
      solution: "Menggunakan Phoenix LiveView, PostgreSQL, dan Backpex.",
      architecture_notes:
        "Keputusan arsitektur kunci: 1. Content context menjaga query dan visibility rules. 2. Public LiveView membaca data published by slug.",
      tradeoffs:
        "Trade-off utama: 1. Taxonomy memakai array field untuk fase urgent. 2. Gallery media penuh ditunda.",
      ownership: "Solo full-stack builder",
      technical_highlights: ["Auto slug", "Admin CRUD"],
      metrics: ["150 tests passing"],
      impact_summary: "Recruiter bisa membaca case study lebih cepat.",
      demo_video_url: "https://raw.githubusercontent.com/nunutech40/repo/main/docs/demo/demo.mp4",
      github_url: "https://github.com/nunutech40/private-repo",
      certificate_media_id: certificate.id,
      tech_stack: ["Elixir", "Phoenix LiveView", "Backpex"],
      platforms: ["web"],
      disciplines: ["fullstack_engineering"],
      case_study_visibility: "limited"
    })

    conn = get(conn, ~p"/work/personal-platform-website")

    html = html_response(conn, 200)
    assert html =~ "Personal Platform Website"
    assert html =~ "My Role &amp; Ownership"
    assert html =~ "Technical Approach"
    assert html =~ "Tech & Libraries"
    assert html =~ "Phoenix LiveView"
    assert html =~ "Backpex"
    assert html =~ "Trade-offs"
    assert html =~ "<ol"
    assert html =~ "Content context menjaga query"
    assert html =~ "Gallery media penuh ditunda"
    assert html =~ "150 tests passing"
    assert html =~ "Video Demo"
    assert html =~ "GitHub — request access"
    assert html =~ "mailto:hello@example.com?subject=GitHub+access+request"
    refute html =~ ~s(href="https://github.com/nunutech40/private-repo")
    assert html =~ "Download Certificate"
    assert html =~ ~s(href="/uploads/media/flutter-certificate.pdf")

    assert html =~
             ~s(src="https://raw.githubusercontent.com/nunutech40/repo/main/docs/demo/demo.mp4")
  end

  test "GET /work/:slug links directly to public GitHub repositories", %{conn: conn} do
    insert_project(%{
      title: "Open Source Tool",
      slug: "open-source-tool",
      status: "published",
      github_url: "https://github.com/nunutech40/open-source-tool",
      case_study_visibility: "public"
    })

    html =
      conn
      |> get(~p"/work/open-source-tool")
      |> html_response(200)

    assert html =~ "GitHub Repository"
    assert html =~ ~s(href="https://github.com/nunutech40/open-source-tool")
    refute html =~ "GitHub — request access"
  end

  test "GET /work keeps stack preview compact on list", %{conn: conn} do
    insert_project(%{
      title: "Internak App",
      slug: "internak-app",
      status: "published",
      summary: "Flutter app for livestock monitoring.",
      tech_stack: [
        "Flutter",
        "Dart",
        "Flutter BLoC",
        "Go Router",
        "Get It",
        "REST API",
        "Firebase Auth",
        "OpenStreetMap",
        "Google Maps",
        "Geolocator"
      ],
      platforms: ["flutter"],
      disciplines: ["flutter_development"]
    })

    html =
      conn
      |> get(~p"/work")
      |> html_response(200)

    assert html =~ "stack-preview"
    assert html =~ "+2 more"
    refute html =~ "Geolocator</span>"
  end

  test "GET /writing/:slug uses post SEO fields and social image fallback", %{conn: conn} do
    media =
      Repo.insert!(%Media{
        filename: "post-og.png",
        content_type: "image/png",
        url: "/uploads/media/post-og.png",
        alt_text: "Post social preview"
      })

    insert_post(%{
      title: "Visible Post Title",
      slug: "visible-post-title",
      excerpt: "Fallback excerpt",
      seo_title: "SEO Post Title",
      seo_description: "SEO description for sharing.",
      og_image_id: media.id
    })

    html =
      conn
      |> get(~p"/writing/visible-post-title")
      |> html_response(200)

    assert html =~ "SEO Post Title"
    assert html =~ ~s(<meta name="description" content="SEO description for sharing.")
    assert html =~ ~s(<meta property="og:image" content="/uploads/media/post-og.png")
    assert html =~ "Visible Post Title"
  end

  test "GET /writing/:slug renders configured support CTA", %{conn: conn} do
    Repo.one!(SiteSetting)
    |> Ecto.Changeset.change(%{
      saweria_url: "https://saweria.co/nunu",
      buy_me_coffee_url: "https://www.buymeacoffee.com/nunu",
      tips_cta_title: "Kalau tulisan ini ngebantu, traktir kopi virtual boleh.",
      tips_cta_body: "Support kecil bikin eksperimen dan tulisan teknis ini tetap jalan."
    })
    |> Repo.update!()

    insert_post(%{
      title: "Flutter Skills",
      slug: "flutter-skills",
      excerpt: "Catatan tentang Flutter Skills."
    })

    html =
      conn
      |> get(~p"/writing/flutter-skills")
      |> html_response(200)

    assert html =~ "Kalau tulisan ini ngebantu, traktir kopi virtual boleh."
    assert html =~ "Support kecil bikin eksperimen"
    assert html =~ ~s(href="https://saweria.co/nunu")
    assert html =~ ~s(href="https://www.buymeacoffee.com/nunu")
  end

  test "GET /work/:slug handles sparse optional list fields", %{conn: conn} do
    Repo.insert!(%Project{
      title: "Sparse Project",
      slug: "sparse-project",
      status: "published",
      year: "2026",
      result: nil,
      metrics: nil,
      technical_highlights: nil
    })

    conn = get(conn, ~p"/work/sparse-project")

    html = html_response(conn, 200)
    assert html =~ "Sparse Project"
    refute html =~ "Results"
    refute html =~ "Implementation Highlights"
  end

  test "GET /products/:slug handles sparse optional product fields", %{conn: conn} do
    insert_product(%{
      title: "Sparse Product",
      slug: "sparse-product",
      summary: nil,
      description: nil,
      included: nil,
      faq: nil,
      currency: nil
    })

    conn = get(conn, ~p"/products/sparse-product")

    html = html_response(conn, 200)
    assert html =~ "Sparse Product"
    assert html =~ "TBD"
    refute html =~ "FAQ"
  end

  test "GET /work/:slug hides draft project detail", %{conn: conn} do
    insert_project(%{
      title: "Draft Project",
      slug: "draft-project",
      status: "draft"
    })

    conn = get(conn, ~p"/work/draft-project")

    html = html_response(conn, 200)
    assert html =~ "Page Not Found"
    refute html =~ "Draft Project"
  end

  defp insert_project(attrs) do
    defaults = %{
      title: "Project",
      slug: "project",
      summary: "Summary",
      description: "Description",
      problem: "Problem",
      solution: "Solution",
      result: [],
      role: "Software Engineer",
      tech_stack: ["Elixir"],
      year: "2026",
      status: "published",
      featured: false,
      demo_video_url: nil,
      project_type: "personal_project",
      platforms: ["web"],
      disciplines: ["fullstack_engineering"],
      case_study_visibility: "public"
    }

    %Project{}
    |> Project.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp insert_product(attrs) do
    defaults = %{
      title: "Product",
      slug: "product",
      summary: "Summary",
      product_type: "digital",
      status: "active",
      price: nil,
      currency: "USD"
    }

    struct(Product, Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp insert_post(attrs) do
    defaults = %{
      title: "Post",
      slug: "post",
      excerpt: "Excerpt",
      content_markdown: "# Post",
      tags: ["Elixir"],
      status: "published",
      reading_time: 5
    }

    %Post{}
    |> Post.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end
end
