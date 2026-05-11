defmodule PersonalBrand.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :slug, :string
    field :excerpt, :string
    field :content_markdown, :string
    field :content_html, :string
    field :editor_type, :string, default: "markdown"
    field :editor_json, :map
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "draft"
    field :featured, :boolean, default: false
    field :published_at, :utc_datetime
    field :reading_time, :integer
    field :seo_title, :string
    field :seo_description, :string
    field :cover_image_id, :binary_id
    field :og_image_id, :binary_id

    many_to_many :tag_relations, PersonalBrand.Content.Tag,
      join_through: "post_tags",
      on_replace: :delete

    timestamps()
  end

  def changeset(post, attrs) do
    attrs =
      attrs
      |> normalize_list_inputs()
      |> put_generated_slug()

    post
    |> cast(attrs, [
      :title,
      :slug,
      :excerpt,
      :content_markdown,
      :content_html,
      :editor_type,
      :editor_json,
      :tags,
      :status,
      :featured,
      :published_at,
      :reading_time,
      :seo_title,
      :seo_description,
      :cover_image_id,
      :og_image_id
    ])
    |> validate_required([:title, :slug, :status])
    |> validate_length(:title, min: 2, max: 300)
    |> validate_length(:slug, min: 2, max: 300)
    |> validate_length(:excerpt, max: 500)
    |> validate_length(:seo_title, max: 70)
    |> validate_length(:seo_description, max: 160)
    |> validate_inclusion(:status, ["draft", "published", "archived"])
    |> validate_inclusion(:editor_type, ["markdown", "rich_text"])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_number(:reading_time, greater_than_or_equal_to: 1, less_than_or_equal_to: 120)
    |> unique_constraint(:slug)
  end

  def slugify(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  def slugify(_value), do: ""

  defp normalize_list_inputs(attrs) when is_map(attrs), do: normalize_list_input(attrs, :tags)
  defp normalize_list_inputs(attrs), do: attrs

  defp normalize_list_input(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_list_value/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_list_value/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &normalize_list_value/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &normalize_list_value/1)

      true ->
        attrs
    end
  end

  defp split_list_value(value) do
    value
    |> String.split(~r/[\r\n,]+/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_list_value(value) do
    value
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp put_generated_slug(attrs) when is_map(attrs) do
    slug = get_attr(attrs, :slug)
    title = get_attr(attrs, :title)

    if blank?(slug) and is_binary(title) do
      put_attr(attrs, :slug, slugify(title))
    else
      attrs
    end
  end

  defp put_generated_slug(attrs), do: attrs

  defp get_attr(attrs, field), do: Map.get(attrs, field) || Map.get(attrs, Atom.to_string(field))

  defp put_attr(attrs, field, value) do
    cond do
      Map.has_key?(attrs, field) -> Map.put(attrs, field, value)
      Map.has_key?(attrs, Atom.to_string(field)) -> Map.put(attrs, Atom.to_string(field), value)
      true -> Map.put(attrs, field, value)
    end
  end

  defp blank?(value), do: is_nil(value) or value == ""
end
