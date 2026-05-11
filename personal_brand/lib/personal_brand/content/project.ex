defmodule PersonalBrand.Content.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :title, :string
    field :slug, :string
    field :summary, :string
    field :description, :string
    field :problem, :string
    field :solution, :string
    field :result, {:array, :string}, default: []
    field :role, :string
    field :tech_stack, {:array, :string}, default: []
    field :year, :string
    field :status, :string, default: "draft"
    field :featured, :boolean, default: false
    field :demo_url, :string
    field :github_url, :string
    field :cover_image_id, :binary_id

    many_to_many :tags, PersonalBrand.Content.Tag,
      join_through: "project_tags",
      on_replace: :delete

    timestamps()
  end

  def changeset(project, attrs) do
    attrs = normalize_list_textareas(attrs)

    project
    |> cast(attrs, [
      :title,
      :slug,
      :summary,
      :description,
      :problem,
      :solution,
      :result,
      :role,
      :tech_stack,
      :year,
      :status,
      :featured,
      :demo_url,
      :github_url,
      :cover_image_id
    ])
    |> validate_required([:title, :slug, :status, :year])
    |> validate_length(:title, min: 2, max: 200)
    |> validate_length(:slug, min: 2, max: 200)
    |> validate_length(:summary, max: 500)
    |> validate_length(:role, max: 100)
    |> validate_inclusion(:status, ["draft", "published", "archived"])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_format(:demo_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_format(:github_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> unique_constraint(:slug)
  end

  defp normalize_list_textareas(attrs) when is_map(attrs) do
    attrs
    |> normalize_list_textarea(:result)
    |> normalize_list_textarea(:tech_stack)
  end

  defp normalize_list_textareas(attrs), do: attrs

  defp normalize_list_textarea(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_textarea_value/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_textarea_value/1)

      true ->
        attrs
    end
  end

  defp split_textarea_value(value) do
    value
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
