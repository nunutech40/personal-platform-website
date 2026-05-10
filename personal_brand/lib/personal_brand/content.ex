defmodule PersonalBrand.Content do
  @moduledoc """
  The Content context. Provides functions to query
  projects, posts, products, site settings, and themes.
  """

  alias PersonalBrand.Repo
  alias PersonalBrand.Content.Project
  alias PersonalBrand.Content.Post
  alias PersonalBrand.Content.Product
  alias PersonalBrand.Content.Media
  alias PersonalBrand.Content.SiteSetting
  alias PersonalBrand.Content.Theme

  import Ecto.Query

  # ── Admin Dashboard ─────────────────────────────────────

  def admin_dashboard_summary do
    %{
      counts: %{
        projects: Repo.aggregate(Project, :count, :id),
        posts: Repo.aggregate(Post, :count, :id),
        products: Repo.aggregate(Product, :count, :id),
        media: Repo.aggregate(Media, :count, :id)
      },
      drafts: %{
        projects: count_status(Project, "draft"),
        posts: count_status(Post, "draft")
      },
      latest_posts: latest(Post, :inserted_at, 5),
      latest_projects: latest(Project, :inserted_at, 5),
      latest_products: latest(Product, :inserted_at, 5),
      active_theme: active_theme_key()
    }
  end

  defp count_status(schema, status) do
    Repo.aggregate(from(item in schema, where: item.status == ^status), :count, :id)
  end

  defp latest(schema, order_field, limit) do
    Repo.all(
      from item in schema,
        order_by: [desc: field(item, ^order_field)],
        limit: ^limit
    )
  end

  defp active_theme_key do
    case get_site_settings() do
      nil -> "old_web_classic"
      settings -> settings.active_theme
    end
  end

  # ── Site Settings ────────────────────────────────────────

  def get_site_settings! do
    Repo.one!(SiteSetting)
  end

  def get_site_settings do
    Repo.one(SiteSetting)
  end

  # ── Projects ─────────────────────────────────────────────

  def list_projects do
    Repo.all(from p in Project, order_by: [desc: p.year])
  end

  def list_published_projects do
    Repo.all(
      from p in Project,
        where: p.status == "published",
        order_by: [desc: p.year]
    )
  end

  def list_featured_projects do
    Repo.all(
      from p in Project,
        where: p.featured == true and p.status == "published",
        order_by: [desc: p.year]
    )
  end

  def get_project_by_slug!(slug) do
    Repo.get_by!(Project, slug: slug)
  end

  def get_project_by_slug(slug) do
    Repo.get_by(Project, slug: slug)
  end

  # ── Posts ────────────────────────────────────────────────

  def list_posts do
    Repo.all(
      from p in Post,
        where: p.status == "published",
        order_by: [desc: p.published_at]
    )
  end

  def list_featured_posts do
    Repo.all(
      from p in Post,
        where: p.featured == true and p.status == "published",
        order_by: [desc: p.published_at]
    )
  end

  def get_post_by_slug!(slug) do
    Repo.get_by!(Post, slug: slug)
  end

  def get_post_by_slug(slug) do
    Repo.get_by(Post, slug: slug)
  end

  # ── Products ─────────────────────────────────────────────

  def list_products do
    Repo.all(from p in Product, order_by: [asc: p.title])
  end

  def list_active_products do
    Repo.all(
      from p in Product,
        where: p.status == "active",
        order_by: [asc: p.title]
    )
  end

  def list_featured_products do
    Repo.all(
      from p in Product,
        where: p.featured == true and p.status == "active",
        order_by: [asc: p.title]
    )
  end

  def get_product_by_slug!(slug) do
    Repo.get_by!(Product, slug: slug)
  end

  def get_product_by_slug(slug) do
    Repo.get_by(Product, slug: slug)
  end

  def get_active_product_by_slug!(slug) do
    Repo.get_by!(Product, slug: slug, status: "active")
  end

  def get_active_product_by_slug(slug) do
    Repo.get_by(Product, slug: slug, status: "active")
  end

  # ── Themes ───────────────────────────────────────────────

  def list_themes do
    Repo.all(from t in Theme, order_by: [asc: t.name])
  end

  def get_active_theme do
    settings = get_site_settings!()
    Repo.get_by(Theme, key: settings.active_theme)
  end
end
