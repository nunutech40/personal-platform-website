defmodule PersonalBrand.ContentTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content
  alias PersonalBrand.Content.{Project, Post, Product, SiteSetting, Theme}

  describe "projects" do
    @valid_attrs %{
      title: "Test Project",
      slug: "test-project",
      summary: "A test project",
      description: "Full description",
      problem: "The problem",
      solution: "The solution",
      result: ["Result 1"],
      role: "Developer",
      tech_stack: ["Elixir"],
      year: "2026",
      status: "draft",
      featured: false,
      project_type: "personal_project",
      platforms: ["web"],
      disciplines: ["fullstack_developer"],
      case_study_visibility: "public"
    }

    def project_fixture(attrs \\ %{}) do
      {:ok, project} =
        %Project{}
        |> Project.changeset(Map.merge(@valid_attrs, attrs))
        |> Repo.insert()

      project
    end

    test "list_projects/0 returns all projects ordered by manual order then year/month" do
      p1 =
        project_fixture(%{
          slug: "project-a",
          year: "2024",
          title: "Alpha",
          sort_order: 3,
          sort_date: ~D[2024-06-01]
        })

      p2 =
        project_fixture(%{
          slug: "project-b",
          year: "2026",
          title: "Beta",
          sort_order: 1,
          sort_date: ~D[2026-01-01]
        })

      p3 =
        project_fixture(%{
          slug: "project-c",
          year: "2025",
          title: "Gamma",
          sort_order: 2,
          sort_date: ~D[2025-04-01]
        })

      projects = Content.list_projects()
      assert Enum.map(projects, & &1.id) == [p2.id, p3.id, p1.id]
    end

    test "list_published_projects/0 sorts same order projects by sort_date desc" do
      older =
        project_fixture(%{
          slug: "older-project",
          status: "published",
          sort_order: 0,
          sort_date: ~D[2024-01-01]
        })

      newer =
        project_fixture(%{
          slug: "newer-project",
          status: "published",
          sort_order: 0,
          sort_date: ~D[2025-03-01]
        })

      no_month =
        project_fixture(%{
          slug: "no-month-project",
          status: "published",
          sort_order: 0,
          year: "2026",
          sort_date: nil
        })

      projects = Content.list_published_projects()
      assert Enum.map(projects, & &1.id) == [newer.id, older.id, no_month.id]
    end

    test "list_published_projects/0 returns only published projects" do
      project_fixture(%{slug: "draft-project", status: "draft"})
      project_fixture(%{slug: "pub-project", status: "published"})
      project_fixture(%{slug: "arch-project", status: "archived"})

      published = Content.list_published_projects()
      assert length(published) == 1
      assert hd(published).slug == "pub-project"
    end

    test "list_published_projects/1 filters by discipline and platform" do
      project_fixture(%{
        slug: "ios-project",
        status: "published",
        platforms: ["ios"],
        disciplines: ["ios_developer"]
      })

      project_fixture(%{
        slug: "backend-project",
        status: "published",
        platforms: ["backend"],
        disciplines: ["backend_developer"]
      })

      assert [%{slug: "ios-project"}] =
               Content.list_published_projects(discipline: "ios_developer")

      assert [%{slug: "backend-project"}] = Content.list_published_projects(platform: "backend")
    end

    test "list_featured_projects/0 returns only featured published projects" do
      project_fixture(%{slug: "featured-pub", featured: true, status: "published"})
      project_fixture(%{slug: "featured-draft", featured: true, status: "draft"})
      project_fixture(%{slug: "not-featured", featured: false, status: "published"})

      featured = Content.list_featured_projects()
      assert length(featured) == 1
      assert hd(featured).slug == "featured-pub"
    end

    test "list_best_three_projects/0 returns only best three published projects limited to three" do
      project_fixture(%{slug: "best-a", best_three: true, status: "published", sort_order: 0})
      project_fixture(%{slug: "best-b", best_three: true, status: "published", sort_order: 1})
      project_fixture(%{slug: "best-c", best_three: true, status: "published", sort_order: 2})
      project_fixture(%{slug: "best-d", best_three: true, status: "published", sort_order: 3})
      project_fixture(%{slug: "best-draft", best_three: true, status: "draft", sort_order: 0})

      best_three = Content.list_best_three_projects()

      assert Enum.map(best_three, & &1.slug) == ["best-a", "best-b", "best-c"]
    end

    test "get_project_by_slug/1 returns project by slug" do
      project = project_fixture(%{slug: "my-project"})
      assert Content.get_project_by_slug("my-project").id == project.id
    end

    test "get_project_by_slug/1 returns nil for missing slug" do
      assert Content.get_project_by_slug("nonexistent") == nil
    end

    test "get_project_by_slug!/1 returns project or raises" do
      project = project_fixture(%{slug: "my-project"})
      assert Content.get_project_by_slug!("my-project").id == project.id

      assert_raise Ecto.NoResultsError, fn ->
        Content.get_project_by_slug!("nonexistent")
      end
    end

    test "get_published_project_by_slug/1 hides drafts" do
      project_fixture(%{slug: "draft-project", status: "draft"})
      published = project_fixture(%{slug: "published-project", status: "published"})

      assert Content.get_published_project_by_slug("draft-project") == nil
      assert Content.get_published_project_by_slug("published-project").id == published.id
    end

    test "create_project/1 auto-generates unique slug when blank" do
      assert {:ok, first} =
               Content.create_project(%{
                 @valid_attrs
                 | title: "RajaOngkir iOS App",
                   slug: "",
                   status: "published"
               })

      assert {:ok, second} =
               Content.create_project(%{
                 @valid_attrs
                 | title: "RajaOngkir iOS App",
                   slug: "",
                   status: "published"
               })

      assert first.slug == "rajaongkir-ios-app"
      assert second.slug == "rajaongkir-ios-app-2"
    end

    test "create_project/1 rejects invalid manual slug" do
      assert {:error, changeset} =
               Content.create_project(%{
                 @valid_attrs
                 | title: "Manual Slug Project",
                   slug: "Manual Slug"
               })

      refute changeset.valid?
      assert errors_on(changeset)[:slug] == ["must be lowercase alphanumeric with hyphens only"]
    end
  end

  describe "posts" do
    @valid_attrs %{
      title: "Test Post",
      slug: "test-post",
      excerpt: "Excerpt",
      content_markdown: "# Hello",
      status: "draft",
      featured: false,
      published_at: ~U[2026-01-01 00:00:00Z]
    }

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        %Post{}
        |> Post.changeset(Map.merge(@valid_attrs, attrs))
        |> Repo.insert()

      post
    end

    test "list_posts/0 returns only published posts ordered by clap count then published_at desc" do
      p1 =
        post_fixture(%{
          slug: "post-a",
          status: "published",
          clap_count: 10,
          published_at: ~U[2026-03-01 00:00:00Z]
        })

      p2 =
        post_fixture(%{
          slug: "post-b",
          status: "published",
          clap_count: 2,
          published_at: ~U[2026-06-01 00:00:00Z]
        })

      post_fixture(%{slug: "draft-post", status: "draft"})

      posts = Content.list_posts()
      assert length(posts) == 2
      assert Enum.map(posts, & &1.id) == [p1.id, p2.id]
    end

    test "clap_post/1 increments post clap count" do
      post = post_fixture(%{clap_count: 2})

      updated = Content.clap_post(post)

      assert updated.clap_count == 3
    end

    test "list_featured_posts/0 returns only featured published posts" do
      post_fixture(%{slug: "featured-pub", featured: true, status: "published"})
      post_fixture(%{slug: "featured-draft", featured: true, status: "draft"})
      post_fixture(%{slug: "not-featured", featured: false, status: "published"})

      featured = Content.list_featured_posts()
      assert length(featured) == 1
      assert hd(featured).slug == "featured-pub"
    end

    test "get_post_by_slug/1 returns post by slug" do
      post = post_fixture(%{slug: "my-post"})
      assert Content.get_post_by_slug("my-post").id == post.id
    end

    test "get_post_by_slug/1 returns nil for missing slug" do
      assert Content.get_post_by_slug("nonexistent") == nil
    end

    test "get_post_by_slug!/1 returns post or raises" do
      post = post_fixture(%{slug: "my-post"})
      assert Content.get_post_by_slug!("my-post").id == post.id

      assert_raise Ecto.NoResultsError, fn ->
        Content.get_post_by_slug!("nonexistent")
      end
    end
  end

  describe "products" do
    @valid_attrs %{
      title: "Test Product",
      slug: "test-product",
      summary: "A test product",
      product_type: "digital",
      price: Decimal.new("29.00"),
      currency: "USD",
      status: "active"
    }

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        %Product{}
        |> Product.changeset(Map.merge(@valid_attrs, attrs))
        |> Repo.insert()

      product
    end

    test "list_products/0 returns all products ordered by title asc" do
      p1 = product_fixture(%{slug: "product-a", title: "Alpha"})
      p2 = product_fixture(%{slug: "product-b", title: "Beta"})
      p3 = product_fixture(%{slug: "product-c", title: "Gamma"})

      products = Content.list_products()
      assert Enum.map(products, & &1.id) == [p1.id, p2.id, p3.id]
    end

    test "list_featured_products/0 returns only featured products" do
      product_fixture(%{slug: "featured-prod", featured: true})
      product_fixture(%{slug: "not-featured", featured: false})

      featured = Content.list_featured_products()
      assert length(featured) == 1
      assert hd(featured).slug == "featured-prod"
    end

    test "get_product_by_slug/1 returns product by slug" do
      product = product_fixture(%{slug: "my-product"})
      assert Content.get_product_by_slug("my-product").id == product.id
    end

    test "get_product_by_slug/1 returns nil for missing slug" do
      assert Content.get_product_by_slug("nonexistent") == nil
    end

    test "get_product_by_slug!/1 returns product or raises" do
      product = product_fixture(%{slug: "my-product"})
      assert Content.get_product_by_slug!("my-product").id == product.id

      assert_raise Ecto.NoResultsError, fn ->
        Content.get_product_by_slug!("nonexistent")
      end
    end
  end

  describe "site_settings" do
    test "get_site_settings/0 returns site settings" do
      Repo.insert!(%SiteSetting{site_name: "Test Site"})
      settings = Content.get_site_settings()
      assert settings.site_name == "Test Site"
    end

    test "get_site_settings/0 returns nil when no settings exist" do
      assert Content.get_site_settings() == nil
    end

    test "get_site_settings!/0 returns site settings or raises" do
      Repo.insert!(%SiteSetting{site_name: "Test Site"})
      assert Content.get_site_settings!().site_name == "Test Site"

      Repo.delete_all(SiteSetting)

      assert_raise Ecto.NoResultsError, fn ->
        Content.get_site_settings!()
      end
    end
  end

  describe "themes" do
    @valid_attrs %{key: "my_theme", name: "My Theme"}

    def theme_fixture(attrs \\ %{}) do
      {:ok, theme} =
        %Theme{}
        |> Theme.changeset(Map.merge(@valid_attrs, attrs))
        |> Repo.insert()

      theme
    end

    test "list_themes/0 returns all themes ordered by name asc" do
      t1 = theme_fixture(%{key: "theme_b", name: "Beta"})
      t2 = theme_fixture(%{key: "theme_a", name: "Alpha"})

      themes = Content.list_themes()
      assert Enum.map(themes, & &1.id) == [t2.id, t1.id]
    end

    test "get_active_theme/0 returns theme matching site settings active_theme" do
      Repo.insert!(%SiteSetting{active_theme: "my_theme"})
      theme_fixture(%{key: "my_theme", name: "My Theme"})
      theme_fixture(%{key: "other_theme", name: "Other"})

      active = Content.get_active_theme()
      assert active.key == "my_theme"
    end

    test "get_active_theme/0 returns nil when theme key does not exist" do
      Repo.insert!(%SiteSetting{active_theme: "nonexistent_theme"})
      assert Content.get_active_theme() == nil
    end

    test "get_active_theme/0 returns nil when settings are empty" do
      assert Content.get_active_theme() == nil
    end
  end
end
