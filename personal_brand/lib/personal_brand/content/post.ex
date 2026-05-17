defmodule PersonalBrand.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias PersonalBrand.Content.Markdown

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :slug, :string
    field :excerpt, :string
    field :content_markdown, :string
    field :content_html, :string
    field :editor_type, :string, default: "markdown"
    field :editor_json, :map
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "draft"
    field :featured, :boolean, default: false
    field :clap_count, :integer, default: 0
    field :published_at, :utc_datetime
    field :reading_time, :integer
    field :seo_title, :string
    field :seo_description, :string
    field :access_type, :string, default: "free"
    field :price, :decimal
    field :currency, :string, default: "IDR"
    field :tip_amount_options, {:array, :integer}, default: []
    field :paid_excerpt, :string
    field :paywall_cta, :string
    field :payment_provider, :string
    field :checkout_url, :string
    belongs_to :cover_image, PersonalBrand.Content.Media
    belongs_to :og_image, PersonalBrand.Content.Media

    many_to_many :tag_relations, PersonalBrand.Content.Tag,
      join_through: "post_tags",
      on_replace: :delete

    timestamps()
  end

  def changeset(post, attrs) do
    attrs =
      attrs
      |> prune_inactive_monetization_values()
      |> normalize_list_inputs()
      |> normalize_blank_values()
      |> put_default_monetization_values(post)
      |> put_generated_slug()
      |> put_rendered_content_html()

    post
    |> cast(attrs, [
      :title,
      :slug,
      :excerpt,
      :content_markdown,
      :content_html,
      :editor_type,
      :editor_json,
      :tags,
      :status,
      :featured,
      :clap_count,
      :published_at,
      :reading_time,
      :seo_title,
      :seo_description,
      :access_type,
      :price,
      :currency,
      :tip_amount_options,
      :paid_excerpt,
      :paywall_cta,
      :payment_provider,
      :checkout_url,
      :cover_image_id,
      :og_image_id
    ])
    |> validate_required([:title, :slug, :status])
    |> validate_length(:title, min: 2, max: 300)
    |> validate_length(:slug, min: 2, max: 300)
    |> validate_length(:excerpt, max: 500)
    |> validate_length(:seo_title, max: 70)
    |> validate_length(:seo_description, max: 160)
    |> validate_inclusion(:status, ["draft", "published", "archived"])
    |> validate_inclusion(:editor_type, ["markdown", "rich_text"])
    |> validate_inclusion(:access_type, ["free", "tips", "paid"])
    |> validate_inclusion(:payment_provider, ["manual_link", "midtrans", nil])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_number(:reading_time, greater_than_or_equal_to: 1, less_than_or_equal_to: 120)
    |> validate_number(:clap_count, greater_than_or_equal_to: 0)
    |> validate_currency()
    |> validate_tip_amount_options()
    |> validate_checkout_url()
    |> validate_paid_price()
    |> validate_payment_config()
    |> unique_constraint(:slug)
  end

  def slugify(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  def slugify(_value), do: ""

  def render_content(%__MODULE__{} = post) do
    post.content_html || Markdown.to_html(post.content_markdown) || ""
  end

  defp normalize_list_inputs(attrs) when is_map(attrs) do
    attrs
    |> normalize_list_input(:tags)
    |> normalize_integer_list_input(:tip_amount_options)
  end

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
    |> String.split(~r/[\r\n,]+/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_list_value(value) do
    value
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_integer_list_input(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_integer_list_value/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_integer_list_value/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &normalize_integer_list_value/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &normalize_integer_list_value/1)

      true ->
        attrs
    end
  end

  defp split_integer_list_value(value) do
    value
    |> String.split(~r/[\r\n,]+/, trim: true)
    |> normalize_integer_list_value()
  end

  defp normalize_integer_list_value(values) do
    values
    |> Enum.map(&normalize_integer_input/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_integer_input(value) when is_integer(value), do: value

  defp normalize_integer_input(value), do: value |> to_string() |> String.trim()

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

  defp put_rendered_content_html(attrs) when is_map(attrs) do
    case get_attr(attrs, :content_markdown) do
      value when is_binary(value) ->
        put_attr(attrs, :content_html, Markdown.to_html(value))

      _value ->
        attrs
    end
  end

  defp put_rendered_content_html(attrs), do: attrs

  defp get_attr(attrs, field), do: Map.get(attrs, field) || Map.get(attrs, Atom.to_string(field))

  defp put_attr(attrs, field, value) do
    string_key = Atom.to_string(field)

    cond do
      Map.has_key?(attrs, field) -> Map.put(attrs, field, value)
      Map.has_key?(attrs, string_key) -> Map.put(attrs, string_key, value)
      Enum.any?(Map.keys(attrs), &is_binary/1) -> Map.put(attrs, string_key, value)
      true -> Map.put(attrs, field, value)
    end
  end

  defp blank?(value), do: is_nil(value) or value == ""

  defp prune_inactive_monetization_values(attrs) when is_map(attrs) do
    case get_attr(attrs, :access_type) do
      "free" ->
        attrs
        |> delete_attr(:price)
        |> delete_attr(:currency)
        |> delete_attr(:tip_amount_options)
        |> delete_attr(:payment_provider)
        |> delete_attr(:checkout_url)

      "paid" ->
        delete_attr(attrs, :tip_amount_options)

      "tips" ->
        delete_attr(attrs, :price)

      _other ->
        attrs
    end
  end

  defp prune_inactive_monetization_values(attrs), do: attrs

  defp delete_attr(attrs, field) do
    attrs
    |> Map.delete(field)
    |> Map.delete(Atom.to_string(field))
  end

  defp normalize_blank_values(attrs) when is_map(attrs) do
    attrs
    |> normalize_blank_value(:payment_provider)
    |> normalize_blank_value(:checkout_url)
    |> normalize_blank_value(:paid_excerpt)
    |> normalize_blank_value(:paywall_cta)
    |> normalize_blank_value(:currency)
    |> normalize_blank_value(:access_type)
  end

  defp normalize_blank_values(attrs), do: attrs

  defp normalize_blank_value(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      Map.get(attrs, field) == "" -> Map.put(attrs, field, nil)
      Map.get(attrs, string_key) == "" -> Map.put(attrs, string_key, nil)
      true -> attrs
    end
  end

  defp put_default_monetization_values(attrs, post) when is_map(attrs) do
    attrs
    |> put_default_access_type(post)
    |> put_default_if_blank(:currency, "IDR")
    |> put_default_payment_provider()
  end

  defp put_default_monetization_values(attrs, _post), do: attrs

  defp put_default_access_type(attrs, post) do
    cond do
      !blank?(get_attr(attrs, :access_type)) ->
        attrs

      is_nil(Map.get(post, :id)) ->
        put_attr(attrs, :access_type, "free")

      Map.has_key?(attrs, :access_type) or Map.has_key?(attrs, "access_type") ->
        put_attr(attrs, :access_type, "free")

      true ->
        attrs
    end
  end

  defp put_default_if_blank(attrs, field, value) do
    if blank?(get_attr(attrs, field)), do: put_attr(attrs, field, value), else: attrs
  end

  defp put_default_payment_provider(attrs) do
    if get_attr(attrs, :access_type) in ["tips", "paid"] do
      put_default_if_blank(attrs, :payment_provider, "midtrans")
    else
      attrs
    end
  end

  defp validate_currency(changeset) do
    if get_field(changeset, :access_type) in ["tips", "paid"] do
      validate_format(changeset, :currency, ~r/^[A-Z]{3}$/,
        message: "must be a 3-letter currency code"
      )
    else
      changeset
    end
  end

  defp validate_tip_amount_options(changeset) do
    tip_amount_options = get_field(changeset, :tip_amount_options) || []

    changeset =
      if get_field(changeset, :access_type) == "tips" and Enum.empty?(tip_amount_options) do
        add_error(
          changeset,
          :tip_amount_options,
          "must contain at least one amount for tips posts"
        )
      else
        changeset
      end

    if Enum.any?(tip_amount_options, &(&1 <= 0)) do
      add_error(changeset, :tip_amount_options, "must contain positive amounts only")
    else
      changeset
    end
  end

  defp validate_checkout_url(changeset) do
    if get_field(changeset, :access_type) == "free" do
      changeset
    else
      validate_active_checkout_url(changeset)
    end
  end

  defp validate_active_checkout_url(changeset) do
    case get_field(changeset, :checkout_url) do
      nil ->
        changeset

      "" ->
        changeset

      url when is_binary(url) ->
        if String.starts_with?(url, "http://") or String.starts_with?(url, "https://") do
          changeset
        else
          add_error(changeset, :checkout_url, "must start with http:// or https://")
        end

      _ ->
        changeset
    end
  end

  defp validate_paid_price(changeset) do
    access_type = get_field(changeset, :access_type)
    price = get_field(changeset, :price)

    if access_type == "paid" and
         (is_nil(price) or Decimal.compare(price, Decimal.new("0")) != :gt) do
      add_error(changeset, :price, "must be greater than 0 for paid posts")
    else
      changeset
    end
  end

  defp validate_payment_config(changeset) do
    monetized? = get_field(changeset, :access_type) in ["tips", "paid"]
    manual_link? = get_field(changeset, :payment_provider) == "manual_link"
    checkout_url = get_field(changeset, :checkout_url)

    if monetized? and manual_link? and blank?(checkout_url) do
      add_error(changeset, :checkout_url, "is required when payment provider is Manual Link")
    else
      changeset
    end
  end
end
