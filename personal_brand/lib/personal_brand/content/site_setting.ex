defmodule PersonalBrand.Content.SiteSetting do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "site_settings" do
    field :site_name, :string, default: "Nunu Nugraha"
    field :headline, :string
    field :subheadline, :string
    field :primary_cta_text, :string, default: "View Work"
    field :primary_cta_url, :string, default: "/work"
    field :secondary_cta_text, :string, default: "Read Writing"
    field :secondary_cta_url, :string, default: "/writing"
    field :active_theme, :string, default: "old_web_classic"
    field :profile_name, :string
    field :profile_title, :string
    field :profile_location, :string
    field :profile_email, :string
    field :profile_bio, :string
    field :social_links, :map
    field :about_intro, :string
    field :about_focus, :string
    field :about_tools, {:array, :string}, default: []
    field :about_values, {:array, :string}, default: []
    field :now_building, :string
    field :now_learning, :string
    field :now_focus, :string
    field :now_updated_at, :date
    field :saweria_url, :string
    field :buy_me_coffee_url, :string
    field :tips_cta_title, :string
    field :tips_cta_body, :string
    field :xendit_checkout_url, :string
    field :xendit_webhook_url, :string
    field :featured_project_ids, {:array, :binary_id}, default: []
    field :featured_product_ids, {:array, :binary_id}, default: []

    timestamps()
  end

  def changeset(site_setting, attrs) do
    attrs =
      attrs
      |> normalize_social_links()
      |> normalize_list_input(:about_tools)
      |> normalize_list_input(:about_values)
      |> normalize_blank_urls()
      |> normalize_id_list(:featured_project_ids)
      |> normalize_id_list(:featured_product_ids)

    site_setting
    |> cast(attrs, [
      :site_name,
      :headline,
      :subheadline,
      :primary_cta_text,
      :primary_cta_url,
      :secondary_cta_text,
      :secondary_cta_url,
      :active_theme,
      :profile_name,
      :profile_title,
      :profile_location,
      :profile_email,
      :profile_bio,
      :social_links,
      :about_intro,
      :about_focus,
      :about_tools,
      :about_values,
      :now_building,
      :now_learning,
      :now_focus,
      :now_updated_at,
      :saweria_url,
      :buy_me_coffee_url,
      :tips_cta_title,
      :tips_cta_body,
      :xendit_checkout_url,
      :xendit_webhook_url,
      :featured_project_ids,
      :featured_product_ids
    ])
    |> validate_required([
      :site_name,
      :headline,
      :primary_cta_text,
      :primary_cta_url,
      :active_theme,
      :profile_name,
      :profile_email
    ])
    |> validate_length(:site_name, min: 1, max: 100)
    |> validate_length(:headline, max: 300)
    |> validate_length(:subheadline, max: 500)
    |> validate_length(:profile_name, min: 1, max: 100)
    |> validate_length(:profile_title, max: 200)
    |> validate_length(:profile_location, max: 200)
    |> validate_length(:tips_cta_title, max: 120)
    |> validate_format(:profile_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> validate_format(:primary_cta_url, ~r/^\//, message: "must start with /")
    |> validate_format(:secondary_cta_url, ~r/^\//, message: "must start with /")
    |> validate_format(:active_theme, ~r/^[a-z0-9_]+$/,
      message: "must be lowercase alphanumeric with underscores only"
    )
    |> validate_url(:saweria_url)
    |> validate_url(:buy_me_coffee_url)
    |> validate_url(:xendit_checkout_url)
    |> validate_url(:xendit_webhook_url)
  end

  defp normalize_blank_urls(attrs) when is_map(attrs) do
    attrs
    |> normalize_blank_value(:saweria_url)
    |> normalize_blank_value(:buy_me_coffee_url)
    |> normalize_blank_value(:xendit_checkout_url)
    |> normalize_blank_value(:xendit_webhook_url)
  end

  defp normalize_blank_urls(attrs), do: attrs

  defp normalize_blank_value(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      Map.get(attrs, field) == "" -> Map.put(attrs, field, nil)
      Map.get(attrs, string_key) == "" -> Map.put(attrs, string_key, nil)
      true -> attrs
    end
  end

  defp validate_url(changeset, field) do
    validate_format(changeset, field, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
  end

  defp normalize_social_links(attrs) when is_map(attrs) do
    normalize_map_textarea(attrs, :social_links)
  end

  defp normalize_social_links(attrs), do: attrs

  defp normalize_list_input(attrs, field) when is_map(attrs) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_lines/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_lines/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &clean_list/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &clean_list/1)

      true ->
        attrs
    end
  end

  defp normalize_list_input(attrs, _field), do: attrs

  defp normalize_map_textarea(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &parse_key_value_lines/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &parse_key_value_lines/1)

      true ->
        attrs
    end
  end

  defp parse_key_value_lines(value) do
    value
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ~r/\s*=\s*/, parts: 2) do
        [key, url] when key != "" and url != "" ->
          Map.put(acc, String.trim(key), String.trim(url))

        _parts ->
          acc
      end
    end)
  end

  defp normalize_id_list(attrs, field) when is_map(attrs) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_id_lines/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_id_lines/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &clean_id_list/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &clean_id_list/1)

      true ->
        attrs
    end
  end

  defp normalize_id_list(attrs, _field), do: attrs

  defp split_id_lines(value) do
    value
    |> String.split(~r/[\r\n,]+/, trim: true)
    |> clean_id_list()
  end

  defp split_lines(value) do
    value
    |> String.split(~r/\r?\n/, trim: true)
    |> clean_list()
  end

  defp clean_list(values) do
    values
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp clean_id_list(values) do
    values
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
