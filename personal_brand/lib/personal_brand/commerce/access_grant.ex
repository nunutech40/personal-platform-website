defmodule PersonalBrand.Commerce.AccessGrant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "access_grants" do
    field :buyer_email, :string
    field :token_hash, :string
    field :expires_at, :utc_datetime
    field :used_at, :utc_datetime

    belongs_to :order, PersonalBrand.Commerce.Order
    belongs_to :post, PersonalBrand.Content.Post
    belongs_to :product, PersonalBrand.Content.Product

    timestamps()
  end

  def changeset(access_grant, attrs) do
    access_grant
    |> cast(attrs, [
      :order_id,
      :post_id,
      :product_id,
      :buyer_email,
      :token_hash,
      :expires_at,
      :used_at
    ])
    |> validate_required([:order_id, :buyer_email, :token_hash])
    |> validate_format(:buyer_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> unique_constraint(:token_hash)
  end
end
