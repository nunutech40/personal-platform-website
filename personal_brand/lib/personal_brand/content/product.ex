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
    field :currency, :string, default: "IDR"
    field :status, :string, default: "active"
    field :stock_status, :string, default: "in_stock"
    field :delivery_type, :string, default: "digital_download"
    field :checkout_url, :string
    field :paid_excerpt, :string
    field :paywall_cta, :string
    field :fulfillment_type, :string, default: "instant_download"
    field :download_media_id, :binary_id
    field :requires_shipping, :boolean, default: false
    field :payment_provider, :string, default: "midtrans"
    field :checkout_mode, :string, default: "midtrans_snap"
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
    attrs =
      attrs
      |> normalize_list_inputs()
      |> normalize_blank_urls()
      |> put_payment_provider_from_checkout_mode()
      |> put_generated_slug()

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
      :paid_excerpt,
      :paywall_cta,
      :fulfillment_type,
      :download_media_id,
      :requires_shipping,
      :payment_provider,
      :checkout_mode,
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
    |> validate_inclusion(:fulfillment_type, [
      "instant_download",
      "email_delivery",
      "manual_confirmation",
      "physical_shipping"
    ])
    |> validate_inclusion(:payment_provider, ["midtrans", "manual_link"])
    |> validate_inclusion(:checkout_mode, ["manual_link", "midtrans_snap"])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_format(:checkout_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_number(:price, greater_than: 0)
    |> validate_format(:currency, ~r/^[A-Z]{3}$/, message: "must be a 3-letter currency code")
    |> validate_product_checkout_config()
    |> validate_fulfillment_config()
    |> unique_constraint(:slug)
  end

  def slugify(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  def slugify(_value), do: ""

  defp normalize_list_inputs(attrs) when is_map(attrs), do: normalize_list_input(attrs, :included)
  defp normalize_list_inputs(attrs), do: attrs

  defp normalize_list_input(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_list_value/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_list_value/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &normalize_list_value/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &normalize_list_value/1)

      true ->
        attrs
    end
  end

  defp split_list_value(value) do
    value
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_list_value(value) do
    value
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_blank_urls(attrs) when is_map(attrs) do
    attrs
    |> normalize_blank_value(:checkout_url)
    |> normalize_blank_value(:paid_excerpt)
    |> normalize_blank_value(:paywall_cta)
    |> put_default_if_blank(:currency, "IDR")
  end

  defp normalize_blank_urls(attrs), do: attrs

  defp put_payment_provider_from_checkout_mode(attrs) when is_map(attrs) do
    case get_attr(attrs, :checkout_mode) do
      "manual_link" -> put_attr(attrs, :payment_provider, "manual_link")
      "midtrans_snap" -> put_attr(attrs, :payment_provider, "midtrans")
      _other -> attrs
    end
  end

  defp put_payment_provider_from_checkout_mode(attrs), do: attrs

  defp put_default_if_blank(attrs, field, value) do
    current = get_attr(attrs, field)

    if blank?(current) do
      put_attr(attrs, field, value)
    else
      attrs
    end
  end

  defp normalize_blank_value(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      Map.get(attrs, field) == "" -> Map.put(attrs, field, nil)
      Map.get(attrs, string_key) == "" -> Map.put(attrs, string_key, nil)
      true -> attrs
    end
  end

  defp put_generated_slug(attrs) when is_map(attrs) do
    slug = get_attr(attrs, :slug)
    title = get_attr(attrs, :title)

    if blank?(slug) and is_binary(title) do
      put_attr(attrs, :slug, slugify(title))
    else
      attrs
    end
  end

  defp put_generated_slug(attrs), do: attrs

  defp get_attr(attrs, field), do: Map.get(attrs, field) || Map.get(attrs, Atom.to_string(field))

  defp put_attr(attrs, field, value) do
    cond do
      Map.has_key?(attrs, field) -> Map.put(attrs, field, value)
      Map.has_key?(attrs, Atom.to_string(field)) -> Map.put(attrs, Atom.to_string(field), value)
      true -> Map.put(attrs, field, value)
    end
  end

  defp blank?(value), do: is_nil(value) or value == ""

  defp validate_product_checkout_config(changeset) do
    active? = get_field(changeset, :status) == "active"
    manual_link? = get_field(changeset, :checkout_mode) == "manual_link"
    checkout_url = get_field(changeset, :checkout_url)

    if active? and manual_link? and blank?(checkout_url) do
      add_error(changeset, :checkout_url, "is required when checkout mode is Manual Link")
    else
      changeset
    end
  end

  defp validate_fulfillment_config(changeset) do
    requires_shipping? = get_field(changeset, :requires_shipping)
    physical_shipping? = get_field(changeset, :fulfillment_type) == "physical_shipping"

    cond do
      requires_shipping? and not physical_shipping? ->
        add_error(
          changeset,
          :fulfillment_type,
          "must be physical_shipping when shipping is required"
        )

      physical_shipping? and not requires_shipping? ->
        add_error(changeset, :requires_shipping, "must be true for physical shipping")

      true ->
        changeset
    end
  end
end
