defmodule PersonalBrand.Content.Theme do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "themes" do
    field :key, :string
    field :name, :string
    field :description, :string
    field :is_active, :boolean, default: false
    field :config, :map

    timestamps()
  end

  def changeset(theme, attrs) do
    theme
    |> cast(attrs, [:key, :name, :description, :is_active, :config])
    |> validate_required([:key, :name])
    |> unique_constraint(:key)
  end
end
