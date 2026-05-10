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
    field :featured_project_ids, {:array, :binary_id}, default: []
    field :featured_product_ids, {:array, :binary_id}, default: []

    timestamps()
  end

  def changeset(site_setting, attrs) do
    site_setting
    |> cast(attrs, [:site_name, :headline, :subheadline,
                    :primary_cta_text, :primary_cta_url,
                    :secondary_cta_text, :secondary_cta_url,
                    :active_theme, :profile_name, :profile_title,
                    :profile_location, :profile_email, :profile_bio,
                    :social_links, :featured_project_ids, :featured_product_ids])
  end
end
