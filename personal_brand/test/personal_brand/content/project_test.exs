defmodule PersonalBrand.Content.ProjectTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Project

  @valid_attrs %{
    title: "Test Project",
    slug: "test-project",
    summary: "A test project",
    description: "Full description",
    problem: "The problem",
    solution: "The solution",
    result: ["Result 1", "Result 2"],
    role: "Developer",
    tech_stack: ["Elixir", "Phoenix"],
    year: "2026",
    status: "draft",
    featured: false,
    demo_url: nil,
    demo_video_url: nil,
    github_url: nil,
    app_store_url: nil,
    project_type: "personal_project",
    platforms: ["web"],
    disciplines: ["fullstack_engineering"],
    ownership: "Solo builder",
    duration: "2026",
    impact_summary: "Recruiter-ready case study",
    technical_highlights: ["Phoenix LiveView"],
    architecture_notes: "Context-driven architecture",
    tradeoffs: "Kept taxonomy as arrays for MVP speed",
    metrics: ["150 tests passing"],
    case_study_visibility: "public",
    sort_order: 1
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing title" do
      attrs = Map.delete(@valid_attrs, :title)
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:title] == ["can't be blank"]
    end

    test "generates slug from title when slug is missing" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-project"
    end

    test "generates slug from title when slug is blank" do
      attrs = %{@valid_attrs | slug: ""}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-project"
    end

    test "enforces unique slug constraint" do
      %Project{}
      |> Project.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Project{}
               |> Project.changeset(%{@valid_attrs | title: "Another Project"})
               |> Repo.insert()
    end

    test "sets default status to draft" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert get_field(changeset, :status) == "draft"
    end

    test "sets default featured to false" do
      changeset = Project.changeset(%Project{}, @valid_attrs)
      assert get_field(changeset, :featured) == false
    end

    test "accepts array fields" do
      attrs = %{@valid_attrs | result: ["A", "B"], tech_stack: ["Elixir", "Phoenix"]}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :result) == ["A", "B"]
      assert get_field(changeset, :tech_stack) == ["Elixir", "Phoenix"]
    end

    test "accepts newline separated array fields from admin forms" do
      attrs = %{
        @valid_attrs
        | result: "Result A\nResult B",
          tech_stack: "Elixir\nPhoenix LiveView\nPostgreSQL",
          platforms: "ios\nmacos",
          disciplines: "ios_development\narchitecture",
          technical_highlights: "SPM modularization\nCoordinator routing",
          metrics: "Reduced UI hangs\nImproved maintainability"
      }

      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :result) == ["Result A", "Result B"]
      assert get_field(changeset, :tech_stack) == ["Elixir", "Phoenix LiveView", "PostgreSQL"]
      assert get_field(changeset, :platforms) == ["ios", "macos"]
      assert get_field(changeset, :disciplines) == ["ios_development", "architecture"]

      assert get_field(changeset, :technical_highlights) == [
               "SPM modularization",
               "Coordinator routing"
             ]

      assert get_field(changeset, :metrics) == ["Reduced UI hangs", "Improved maintainability"]
    end

    test "accepts published status" do
      attrs = %{@valid_attrs | status: "published"}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :status) == "published"
    end

    test "accepts archived status" do
      attrs = %{@valid_attrs | status: "archived"}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :status) == "archived"
    end

    test "rejects missing year" do
      attrs = Map.delete(@valid_attrs, :year)
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:year] == ["can't be blank"]
    end

    test "rejects invalid status" do
      attrs = %{@valid_attrs | status: "deleted"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects invalid taxonomy values" do
      attrs = %{
        @valid_attrs
        | project_type: "random",
          platforms: ["ios", "desktop"],
          disciplines: ["ios_development", "random"],
          case_study_visibility: "secret"
      }

      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset)[:project_type]
      assert "is invalid" in errors_on(changeset)[:case_study_visibility]
      assert ["contains invalid values: desktop"] == errors_on(changeset)[:platforms]
      assert ["contains invalid values: random"] == errors_on(changeset)[:disciplines]
    end

    test "rejects slug with uppercase letters" do
      attrs = %{@valid_attrs | slug: "Test-Project"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects slug with spaces" do
      attrs = %{@valid_attrs | slug: "test project"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects demo_url without http scheme" do
      attrs = %{@valid_attrs | demo_url: "example.com"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects github_url without http scheme" do
      attrs = %{@valid_attrs | github_url: "example.com"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects demo_video_url without http scheme" do
      attrs = %{@valid_attrs | demo_video_url: "videos/demo.mp4"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "rejects app_store_url without http scheme" do
      attrs = %{@valid_attrs | app_store_url: "apps.apple.com/app/example"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end

    test "accepts demo_url with https" do
      attrs = %{@valid_attrs | demo_url: "https://example.com"}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
    end

    test "accepts github_url with https" do
      attrs = %{@valid_attrs | github_url: "https://github.com/user/repo"}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
    end

    test "accepts demo_video_url with https" do
      attrs = %{
        @valid_attrs
        | demo_video_url:
            "https://raw.githubusercontent.com/nunutech40/repo/main/docs/demo/demo.mp4"
      }

      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
    end

    test "accepts app_store_url with https" do
      attrs = %{@valid_attrs | app_store_url: "https://apps.apple.com/app/example"}
      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
    end

    test "allows blank optional URLs from admin forms" do
      attrs = %{
        @valid_attrs
        | demo_url: "",
          demo_video_url: "",
          github_url: "",
          app_store_url: ""
      }

      changeset = Project.changeset(%Project{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :demo_url) == nil
      assert get_field(changeset, :demo_video_url) == nil
      assert get_field(changeset, :github_url) == nil
      assert get_field(changeset, :app_store_url) == nil
    end

    test "rejects title shorter than min length" do
      attrs = %{@valid_attrs | title: "A"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end
  end
end
