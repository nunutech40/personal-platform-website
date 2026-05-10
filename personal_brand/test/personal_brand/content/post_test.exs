defmodule PersonalBrand.Content.PostTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Post

  @valid_attrs %{
    title: "Test Post",
    slug: "test-post",
    excerpt: "A test excerpt",
    content_markdown: "# Hello",
    content_html: "<h1>Hello</h1>",
    tags: ["Elixir", "Phoenix"],
    status: "draft",
    featured: false,
    published_at: ~U[2026-01-01 00:00:00Z],
    reading_time: 5
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing title" do
      attrs = Map.delete(@valid_attrs, :title)
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:title] == ["can't be blank"]
    end

    test "rejects missing slug" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:slug] == ["can't be blank"]
    end

    test "enforces unique slug constraint" do
      %Post{}
      |> Post.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Post{}
               |> Post.changeset(%{@valid_attrs | title: "Another Post"})
               |> Repo.insert()
    end

    test "sets default status to draft" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert get_field(changeset, :status) == "draft"
    end

    test "sets default featured to false" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert get_field(changeset, :featured) == false
    end

    test "accepts published status with published_at" do
      attrs = %{@valid_attrs | status: "published"}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :status) == "published"
    end

    test "accepts tags as array" do
      attrs = %{@valid_attrs | tags: ["Elixir", "Phoenix", "Testing"]}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :tags) == ["Elixir", "Phoenix", "Testing"]
    end

    test "accepts seo fields" do
      attrs =
        Map.merge(@valid_attrs, %{seo_title: "SEO Title", seo_description: "SEO Description"})

      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :seo_title) == "SEO Title"
      assert get_field(changeset, :seo_description) == "SEO Description"
    end
  end
end
