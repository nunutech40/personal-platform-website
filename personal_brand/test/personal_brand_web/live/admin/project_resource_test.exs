defmodule PersonalBrandWeb.Admin.ProjectResourceTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts
  alias PersonalBrand.Content.Project
  alias PersonalBrand.Repo

  import Phoenix.LiveViewTest

  test "GET /admin/projects/new renders grouped portfolio form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects/new")

    assert html =~ "Info Dasar"
    assert html =~ "Klasifikasi &amp; Peran"
    assert html =~ "Pitch untuk Recruiter"
    assert html =~ "Isi Judul Project dulu"
    assert html =~ "Gambar Cover"
    assert html =~ "Sertifikat PDF"
    assert html =~ "Tanggal Sortir"
    assert html =~ "Pilih platform yang dipakai"
    assert html =~ ~s(name="change[platforms][]")
    assert html =~ ~s(value="web")
    assert html =~ "Backend"
    refute html =~ "Select all"
    assert html =~ ~s(value="Software Engineer")
    assert html =~ ~s(value="Backend Engineer")
    assert html =~ ~s(value="Full-stack Engineer")
    assert html =~ "Ketik sendiri atau pilih dari saran"
  end

  test "GET /admin/projects/new combines existing text suggestions with common defaults", %{
    conn: conn
  } do
    insert_project(%{
      title: "Existing Role Project",
      slug: "existing-role-project",
      role: "Existing Mobile Lead",
      ownership: "Feature owner for checkout",
      team_size: "3 engineers",
      company: "Existing Company",
      client: "Existing Client"
    })

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects/new")

    assert html =~ "Existing Mobile Lead"
    assert html =~ "Feature owner for checkout"
    assert html =~ "3 engineers"
    assert html =~ "Existing Company"
    assert html =~ "Existing Client"
    assert html =~ ~s(value="Full-stack Engineer")
    assert html =~ ~s(value="Software Engineer")
    refute html =~ ~s(value="Lead iOS Dev")
  end

  test "GET /admin/projects/:id/edit warns before changing published slug", %{conn: conn} do
    project =
      insert_project(%{
        title: "Personal Platform Website",
        slug: "personal-platform-website",
        status: "published"
      })

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects/#{project.id}/edit")

    assert html =~ "Project ini sudah terbit"
    assert html =~ "/work/personal-platform-website"
    assert html =~ "Mengubah URL Project"
  end

  test "GET /admin/projects includes public preview action and updated column", %{conn: conn} do
    insert_project(%{
      title: "RajaOngkir iOS App",
      slug: "rajaongkir-ios-app",
      status: "published"
    })

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects")

    assert html =~ "RajaOngkir iOS App"
    assert html =~ "Ubah"
    assert html =~ "Lihat Publik"
    assert html =~ ~s(href="/work/rajaongkir-ios-app")
    assert html =~ "Terakhir Diubah"
    assert html =~ "Select all items"
  end

  test "admin project form creates a project without manual slug", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects/new")

    attrs = form_attrs(%{"title" => "Admin CRUD Project", "slug" => ""})

    view
    |> element("#resource-form")
    |> render_submit(%{"change" => attrs, "save-type" => "save"})

    assert_redirect(view, ~p"/admin/projects")

    project = Repo.get_by!(Project, slug: "admin-crud-project")
    assert project.title == "Admin CRUD Project"
    assert project.tech_stack == ["Elixir", "Phoenix LiveView"]
    assert project.result == ["Result"]
    assert project.platforms == ["web"]
    assert project.disciplines == ["fullstack_engineering"]
  end

  test "admin project form updates an existing project", %{conn: conn} do
    project =
      insert_project(%{
        title: "Project Before Edit",
        slug: "project-before-edit",
        status: "draft"
      })

    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects/#{project.id}/edit")

    attrs =
      form_attrs(%{
        "title" => "Project After Edit",
        "slug" => "project-before-edit",
        "summary" => "Updated from admin edit form.",
        "status" => "published",
        "featured" => "true",
        "tech_stack" => "Elixir\nPhoenix LiveView\nBackpex",
        "result" => "Result A\nResult B",
        "technical_highlights" => "Highlight A\nHighlight B",
        "metrics" => "Metric A\nMetric B",
        "sort_date" => "2025-03-01"
      })

    view
    |> element("#resource-form")
    |> render_submit(%{"change" => attrs, "save-type" => "save"})

    assert_redirect(view, ~p"/admin/projects")

    updated = Repo.get!(Project, project.id)
    assert updated.title == "Project After Edit"
    assert updated.summary == "Updated from admin edit form."
    assert updated.status == "published"
    assert updated.featured
    assert updated.tech_stack == ["Elixir", "Phoenix LiveView", "Backpex"]
    assert updated.result == ["Result A", "Result B"]
    assert updated.technical_highlights == ["Highlight A", "Highlight B"]
    assert updated.metrics == ["Metric A", "Metric B"]
    assert updated.sort_date == ~D[2025-03-01]
  end

  test "admin project index exposes delete action for projects", %{conn: conn} do
    project =
      insert_project(%{
        title: "Project To Delete",
        slug: "project-to-delete"
      })

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/projects")

    assert html =~ "Project To Delete"
    assert html =~ ~s(phx-value-action-key="delete")
    assert html =~ ~s(phx-value-item-id="#{project.id}")
    assert html =~ "Hapus"
  end

  defp log_in_admin(conn) do
    init_test_session(conn, admin_token: Accounts.generate_session_token(1))
  end

  defp form_attrs(attrs) do
    Map.merge(
      %{
        "title" => "Project",
        "slug" => "project",
        "summary" => "Summary",
        "description" => "Description",
        "problem" => "Problem",
        "solution" => "Solution",
        "result" => "Result",
        "role" => "Software Engineer",
        "tech_stack" => "Elixir\nPhoenix LiveView",
        "year" => "2026",
        "status" => "published",
        "featured" => "false",
        "project_type" => "personal_project",
        "platforms" => ["web"],
        "disciplines" => ["fullstack_engineering"],
        "case_study_visibility" => "public",
        "sort_order" => "0"
      },
      attrs
    )
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
