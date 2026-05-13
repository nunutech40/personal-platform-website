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
  alias PersonalBrand.Content.Tag

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

  # ── Media ────────────────────────────────────────────────

  def get_media(id) when is_binary(id) do
    Repo.get(Media, id)
  end

  def get_media(_id), do: nil

  def list_media_by_ids(ids) when is_list(ids) do
    ids = Enum.reject(ids, &is_nil/1)

    if ids == [] do
      []
    else
      Repo.all(from m in Media, where: m.id in ^ids)
    end
  end

  # ── Projects ─────────────────────────────────────────────

  def list_projects do
    Repo.all(from p in Project, order_by: ^project_order())
  end

  def list_project_field_values(field)
      when field in [:role, :ownership, :team_size, :company, :client] do
    Repo.all(
      from p in Project,
        where: not is_nil(field(p, ^field)) and field(p, ^field) != "",
        distinct: field(p, ^field),
        order_by: field(p, ^field),
        select: field(p, ^field)
    )
  end

  def list_project_array_values(field) when field in [:platforms, :disciplines] do
    Project
    |> Repo.all()
    |> Enum.flat_map(&(Map.get(&1, field) || []))
    |> Enum.reject(&(is_nil(&1) or String.trim(&1) == ""))
    |> Enum.uniq()
    |> Enum.sort()
  end

  def list_post_field_values(field) when field in [:seo_title] do
    list_text_field_values(Post, field)
  end

  def list_post_array_values(:tags) do
    Post
    |> Repo.all()
    |> Enum.flat_map(&(&1.tags || []))
    |> clean_distinct_values()
  end

  def list_product_field_values(field) when field in [:currency] do
    list_text_field_values(Product, field)
  end

  def list_product_array_values(:included) do
    Product
    |> Repo.all()
    |> Enum.flat_map(&(&1.included || []))
    |> clean_distinct_values()
  end

  @projects_per_page 9

  def projects_per_page, do: @projects_per_page

  def list_published_projects(opts \\ []) do
    discipline = Keyword.get(opts, :discipline)
    platform = Keyword.get(opts, :platform)
    limit = Keyword.get(opts, :limit, @projects_per_page)
    offset = Keyword.get(opts, :offset, 0)

    from(p in Project,
      where: p.status == "published",
      order_by: ^project_order(),
      limit: ^limit,
      offset: ^offset
    )
    |> maybe_filter_discipline(discipline)
    |> maybe_filter_platform(platform)
    |> Repo.all()
  end

  def count_published_projects(opts \\ []) do
    discipline = Keyword.get(opts, :discipline)
    platform = Keyword.get(opts, :platform)

    from(p in Project, where: p.status == "published")
    |> maybe_filter_discipline(discipline)
    |> maybe_filter_platform(platform)
    |> Repo.aggregate(:count, :id)
  end

  defp maybe_filter_discipline(query, nil), do: query
  defp maybe_filter_discipline(query, ""), do: query

  defp maybe_filter_discipline(query, discipline) do
    from p in query, where: ^discipline in p.disciplines
  end

  defp maybe_filter_platform(query, nil), do: query
  defp maybe_filter_platform(query, ""), do: query

  defp maybe_filter_platform(query, platform) do
    from p in query, where: ^platform in p.platforms
  end

  def list_featured_projects do
    Repo.all(
      from p in Project,
        where: p.featured == true and p.status == "published",
        order_by: ^project_order()
    )
  end

  def create_project(attrs) do
    attrs = put_unique_project_slug(attrs)

    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  defp project_order do
    [
      asc: :sort_order,
      desc_nulls_last: :sort_date,
      desc: :year,
      desc: :inserted_at
    ]
  end

  def get_project_by_slug!(slug) do
    Repo.get_by!(Project, slug: slug)
  end

  def get_project_by_slug(slug) do
    Repo.get_by(Project, slug: slug)
  end

  def get_published_project_by_slug(slug) do
    Repo.get_by(Project, slug: slug, status: "published")
  end

  def unique_project_slug(attrs) when is_map(attrs) do
    resolve_unique_project_slug(attrs)
  end

  def put_unique_project_slug(attrs) when is_map(attrs) do
    put_unique_slug(attrs, &unique_project_slug/1)
  end

  # ── Posts ────────────────────────────────────────────────

  @posts_per_page 9

  def posts_per_page, do: @posts_per_page

  def list_posts(opts \\ []) do
    limit = Keyword.get(opts, :limit, @posts_per_page)
    offset = Keyword.get(opts, :offset, 0)

    Repo.all(
      from p in Post,
        where: p.status == "published",
        order_by: [desc: p.published_at],
        limit: ^limit,
        offset: ^offset
    )
  end

  def count_published_posts do
    Repo.aggregate(from(p in Post, where: p.status == "published"), :count, :id)
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

  def unique_post_slug(attrs) when is_map(attrs), do: resolve_unique_slug(attrs, Post)

  def put_unique_post_slug(attrs) when is_map(attrs) do
    put_unique_slug(attrs, &unique_post_slug/1)
  end

  # ── Products ─────────────────────────────────────────────

  @products_per_page 9

  def products_per_page, do: @products_per_page

  def list_products(opts \\ []) do
    limit = Keyword.get(opts, :limit, @products_per_page)
    offset = Keyword.get(opts, :offset, 0)

    Repo.all(
      from p in Product,
        where: p.status == "active",
        order_by: [asc: p.title],
        limit: ^limit,
        offset: ^offset
    )
  end

  def count_published_products do
    Repo.aggregate(from(p in Product, where: p.status == "active"), :count, :id)
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

  def unique_product_slug(attrs) when is_map(attrs), do: resolve_unique_slug(attrs, Product)

  def put_unique_product_slug(attrs) when is_map(attrs) do
    put_unique_slug(attrs, &unique_product_slug/1)
  end

  # ── Themes ───────────────────────────────────────────────

  def list_themes do
    Repo.all(from t in Theme, order_by: [asc: t.name])
  end

  def get_active_theme do
    case get_site_settings() do
      nil -> nil
      settings -> Repo.get_by(Theme, key: settings.active_theme)
    end
  end

  # ── Tags ──────────────────────────────────────────────────

  def list_tags do
    Repo.all(from t in Tag, order_by: [asc: t.name])
  end

  def get_tag_by_slug!(slug) do
    Repo.get_by!(Tag, slug: slug)
  end

  def get_tag_by_slug(slug) do
    Repo.get_by(Tag, slug: slug)
  end

  def list_projects_by_tag(tag_slug) do
    Repo.all(
      from p in Project,
        join: pt in "project_tags",
        on: pt.project_id == p.id,
        join: t in Tag,
        on: t.id == pt.tag_id,
        where: t.slug == ^tag_slug and p.status == "published",
        order_by: [desc: p.year],
        preload: [:tags]
    )
  end

  def list_posts_by_tag(tag_slug) do
    Repo.all(
      from p in Post,
        join: pt in "post_tags",
        on: pt.post_id == p.id,
        join: t in Tag,
        on: t.id == pt.tag_id,
        where: t.slug == ^tag_slug and p.status == "published",
        order_by: [desc: p.published_at],
        preload: [:tag_relations]
    )
  end

  def list_products_by_tag(tag_slug) do
    Repo.all(
      from p in Product,
        join: pt in "product_tags",
        on: pt.product_id == p.id,
        join: t in Tag,
        on: t.id == pt.tag_id,
        where: t.slug == ^tag_slug and p.status == "active",
        order_by: [asc: p.title],
        preload: [:tags]
    )
  end

  defp resolve_unique_project_slug(attrs) do
    resolve_unique_slug(attrs, Project)
  end

  defp resolve_unique_slug(attrs, schema) do
    base_slug =
      attrs
      |> attr(:slug)
      |> fallback(attr(attrs, :title))
      |> Project.slugify()

    do_resolve_unique_slug(base_slug, schema, 1)
  end

  defp do_resolve_unique_slug("", _schema, _counter), do: ""

  defp do_resolve_unique_slug(base_slug, schema, 1) do
    if Repo.exists?(from item in schema, where: item.slug == ^base_slug) do
      do_resolve_unique_slug(base_slug, schema, 2)
    else
      base_slug
    end
  end

  defp do_resolve_unique_slug(base_slug, schema, counter) do
    candidate = "#{base_slug}-#{counter}"

    if Repo.exists?(from item in schema, where: item.slug == ^candidate) do
      do_resolve_unique_slug(base_slug, schema, counter + 1)
    else
      candidate
    end
  end

  defp put_unique_slug(attrs, slug_fun) do
    if attr(attrs, :slug) in [nil, ""] do
      slug = slug_fun.(attrs)

      cond do
        slug == "" -> attrs
        Map.has_key?(attrs, "slug") -> Map.put(attrs, "slug", slug)
        true -> Map.put(attrs, :slug, slug)
      end
    else
      attrs
    end
  end

  defp list_text_field_values(schema, field) do
    Repo.all(
      from item in schema,
        where: not is_nil(field(item, ^field)) and field(item, ^field) != "",
        distinct: field(item, ^field),
        order_by: field(item, ^field),
        select: field(item, ^field)
    )
  end

  defp clean_distinct_values(values) do
    values
    |> Enum.reject(&(is_nil(&1) or String.trim(&1) == ""))
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp attr(attrs, key), do: Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key))
  defp fallback(value, fallback_value) when value in [nil, ""], do: fallback_value
  defp fallback(value, _fallback_value), do: value
end
