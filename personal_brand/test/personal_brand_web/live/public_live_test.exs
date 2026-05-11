defmodule PersonalBrandWeb.PublicLiveTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Content.Project
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
      impact_summary: "Menyatukan kebutuhan shipping ke dalam workflow mobile yang cepat."
    })

    insert_project(%{
      title: "Draft Project",
      slug: "draft-project",
      status: "draft",
      summary: "Hidden"
    })

    conn = get(conn, ~p"/work")

    html = html_response(conn, 200)
    assert html =~ "RajaOngkir iOS App"
    assert html =~ "Mobile Engineering Lead"
    assert html =~ "iOS"
    refute html =~ "Draft Project"
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
    insert_project(%{
      title: "Personal Platform Website",
      slug: "personal-platform-website",
      status: "published",
      summary: "CMS portfolio berbasis Phoenix LiveView.",
      description: "Platform personal untuk menampilkan work, writing, dan products.",
      problem: "Portfolio perlu mudah dikelola dari admin.",
      solution: "Menggunakan Phoenix LiveView, PostgreSQL, dan Backpex.",
      architecture_notes: "Context layer menjaga query dan visibility rules.",
      tradeoffs: "Taxonomy memakai array field untuk fase urgent.",
      ownership: "Solo full-stack builder",
      technical_highlights: ["Auto slug", "Admin CRUD"],
      metrics: ["150 tests passing"],
      impact_summary: "Recruiter bisa membaca case study lebih cepat.",
      platforms: ["web"],
      disciplines: ["fullstack_engineering"]
    })

    conn = get(conn, ~p"/work/personal-platform-website")

    html = html_response(conn, 200)
    assert html =~ "Personal Platform Website"
    assert html =~ "My Role &amp; Ownership"
    assert html =~ "Technical Approach"
    assert html =~ "Trade-offs"
    assert html =~ "150 tests passing"
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
      project_type: "personal_project",
      platforms: ["web"],
      disciplines: ["fullstack_engineering"],
      case_study_visibility: "public"
    }

    %Project{}
    |> Project.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end
end
