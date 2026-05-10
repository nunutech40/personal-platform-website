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
    github_url: nil
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

    test "rejects missing slug" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:slug] == ["can't be blank"]
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

    test "rejects title shorter than min length" do
      attrs = %{@valid_attrs | title: "A"}
      changeset = Project.changeset(%Project{}, attrs)
      refute changeset.valid?
    end
  end
end
