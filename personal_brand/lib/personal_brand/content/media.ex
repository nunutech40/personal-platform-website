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
    field :file_path, :string
    field :alt_text, :string
    field :attachable_type, :string
    field :attachable_id, :binary_id

    timestamps()
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [
      :filename,
      :content_type,
      :size,
      :url,
      :file_path,
      :alt_text,
      :attachable_type,
      :attachable_id
    ])
    |> validate_required([:filename, :url])
    |> validate_length(:filename, min: 1, max: 255)
    |> validate_length(:alt_text, max: 500)
    |> validate_format(:url, ~r/^(https?:\/\/|\/uploads\/)/,
      message: "must start with http://, https://, or /uploads/"
    )
    |> validate_number(:size, greater_than_or_equal_to: 0)
  end
end
