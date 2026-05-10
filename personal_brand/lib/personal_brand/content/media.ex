defmodule PersonalBrand.Content.Media do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "media" do
    field :filename, :string
    field :content_type, :string
    field :size, :integer
    field :url, :string
    field :alt_text, :string
    field :attachable_type, :string
    field :attachable_id, :binary_id

    timestamps()
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [:filename, :content_type, :size, :url, :alt_text,
                    :attachable_type, :attachable_id])
    |> validate_required([:filename, :url])
  end
end
