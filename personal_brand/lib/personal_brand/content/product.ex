defmodule PersonalBrand.Content.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :title, :string
    field :slug, :string
    field :summary, :string
    field :description, :string
    field :product_type, :string, default: "digital"
    field :price, :decimal
    field :currency, :string, default: "USD"
    field :status, :string, default: "active"
    field :stock_status, :string, default: "in_stock"
    field :delivery_type, :string, default: "digital_download"
    field :checkout_url, :string
    field :featured, :boolean, default: false
    field :included, {:array, :string}, default: []
    field :faq, :map
    field :cover_image_id, :binary_id

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :title,
      :slug,
      :summary,
      :description,
      :product_type,
      :price,
      :currency,
      :status,
      :stock_status,
      :delivery_type,
      :checkout_url,
      :featured,
      :included,
      :faq,
      :cover_image_id
    ])
    |> validate_required([:title, :slug])
    |> unique_constraint(:slug)
  end
end
