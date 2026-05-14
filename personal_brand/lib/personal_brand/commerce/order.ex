defmodule PersonalBrand.Commerce.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orders" do
    field :kind, :string
    field :status, :string, default: "pending"
    field :provider, :string, default: "midtrans"
    field :provider_order_id, :string
    field :provider_transaction_id, :string
    field :buyer_email, :string
    field :amount, :decimal
    field :currency, :string, default: "IDR"
    field :checkout_url, :string
    field :metadata, :map, default: %{}
    field :paid_at, :utc_datetime
    field :fulfillment_status, :string, default: "unfulfilled"
    field :fulfilled_at, :utc_datetime

    belongs_to :post, PersonalBrand.Content.Post
    belongs_to :product, PersonalBrand.Content.Product

    has_many :access_grants, PersonalBrand.Commerce.AccessGrant

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :kind,
      :status,
      :provider,
      :provider_order_id,
      :provider_transaction_id,
      :buyer_email,
      :amount,
      :currency,
      :post_id,
      :product_id,
      :checkout_url,
      :metadata,
      :paid_at,
      :fulfillment_status,
      :fulfilled_at
    ])
    |> validate_required([
      :kind,
      :status,
      :provider,
      :provider_order_id,
      :buyer_email,
      :amount,
      :currency
    ])
    |> validate_inclusion(:kind, ["post_access", "tip", "product_purchase"])
    |> validate_inclusion(:status, ["pending", "paid", "failed", "expired", "refunded"])
    |> validate_inclusion(:fulfillment_status, ["unfulfilled", "fulfilled", "not_required"])
    |> validate_inclusion(:provider, ["midtrans", "manual"])
    |> validate_format(:buyer_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> validate_format(:currency, ~r/^[A-Z]{3}$/, message: "must be a 3-letter currency code")
    |> validate_format(:checkout_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_number(:amount, greater_than: 0)
    |> validate_order_target()
    |> unique_constraint(:provider_order_id)
  end

  defp validate_order_target(changeset) do
    kind = get_field(changeset, :kind)
    post_id = get_field(changeset, :post_id)
    product_id = get_field(changeset, :product_id)

    cond do
      kind in ["post_access", "tip"] and is_nil(post_id) ->
        add_error(changeset, :post_id, "is required for post orders")

      kind == "product_purchase" and is_nil(product_id) ->
        add_error(changeset, :product_id, "is required for product orders")

      true ->
        changeset
    end
  end
end
