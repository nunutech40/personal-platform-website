defmodule PersonalBrand.Content do
  @moduledoc """
  The Content context. Provides functions to query
  projects, posts, products, site settings, and themes.
  """

  alias PersonalBrand.Repo
  alias PersonalBrand.Content.Project
  alias PersonalBrand.Content.Post
  alias PersonalBrand.Content.Product
  alias PersonalBrand.Content.SiteSetting
  alias PersonalBrand.Content.Theme

  import Ecto.Query

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

  def list_featured_products do
    Repo.all(
      from p in Product,
        where: p.featured == true,
        order_by: [asc: p.title]
    )
  end

  def get_product_by_slug!(slug) do
    Repo.get_by!(Product, slug: slug)
  end

  def get_product_by_slug(slug) do
    Repo.get_by(Product, slug: slug)
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
