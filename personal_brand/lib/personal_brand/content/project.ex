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

    timestamps()
  end

  def changeset(project, attrs) do
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
    |> validate_required([:title, :slug])
    |> unique_constraint(:slug)
  end
end
