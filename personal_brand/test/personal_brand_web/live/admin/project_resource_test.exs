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

    assert html =~ "Identity"
    assert html =~ "Classification"
    assert html =~ "Recruiter Pitch"
    assert html =~ "Fill the title first"
    assert html =~ "Cover Image"
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

    assert html =~ "Published project URL"
    assert html =~ "/work/personal-platform-website"
    assert html =~ "Changing the slug will change this public case study URL"
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
    assert html =~ "View public"
    assert html =~ ~s(href="/work/rajaongkir-ios-app")
    assert html =~ "Updated"
  end

  defp log_in_admin(conn) do
    init_test_session(conn, admin_token: Accounts.generate_session_token(1))
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
