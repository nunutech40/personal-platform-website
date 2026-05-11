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

    many_to_many :tags, PersonalBrand.Content.Tag,
      join_through: "product_tags",
      on_replace: :delete

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
    |> validate_required([:title, :slug, :product_type, :status, :price, :currency])
    |> validate_length(:title, min: 2, max: 200)
    |> validate_length(:slug, min: 2, max: 200)
    |> validate_length(:summary, max: 500)
    |> validate_inclusion(:status, ["active", "draft", "archived", "coming_soon"])
    |> validate_inclusion(:product_type, ["digital", "physical", "service"])
    |> validate_inclusion(:stock_status, ["in_stock", "out_of_stock", "pre_order"])
    |> validate_inclusion(:delivery_type, [
      "digital_download",
      "email_delivery",
      "physical_delivery"
    ])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_format(:checkout_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_length(:currency, is: 3, message: "must be a 3-letter currency code (e.g. USD)")
    |> unique_constraint(:slug)
  end
end
