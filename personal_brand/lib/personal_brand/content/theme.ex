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
    attrs = normalize_config(attrs)

    theme
    |> cast(attrs, [:key, :name, :description, :is_active, :config])
    |> validate_required([:key, :name])
    |> validate_length(:key, min: 2, max: 100)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_format(:key, ~r/^[a-z0-9_]+$/,
      message: "must be lowercase alphanumeric with underscores only"
    )
    |> unique_constraint(:key)
  end

  defp normalize_config(attrs) when is_map(attrs) do
    string_key = "config"

    cond do
      is_binary(Map.get(attrs, :config)) ->
        Map.update!(attrs, :config, &parse_config/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &parse_config/1)

      true ->
        attrs
    end
  end

  defp normalize_config(attrs), do: attrs

  defp parse_config(value) do
    value = String.trim(value)

    cond do
      value == "" ->
        %{}

      true ->
        case Jason.decode(value) do
          {:ok, decoded} when is_map(decoded) -> decoded
          _error -> value
        end
    end
  end
end
