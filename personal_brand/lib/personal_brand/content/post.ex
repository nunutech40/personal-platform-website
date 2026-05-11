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
end
