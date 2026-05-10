defmodule PersonalBrand.Repo.Migrations.CreateSiteSettings do
  use Ecto.Migration

  def change do
    create table(:site_settings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :site_name, :string, default: "Nunu Nugraha"
      add :headline, :text
      add :subheadline, :text
      add :primary_cta_text, :string, default: "View Work"
      add :primary_cta_url, :string, default: "/work"
      add :secondary_cta_text, :string, default: "Read Writing"
      add :secondary_cta_url, :string, default: "/writing"
      add :active_theme, :string, default: "old_web_classic"
      add :profile_name, :string
      add :profile_title, :string
      add :profile_location, :string
      add :profile_email, :string
      add :profile_bio, :text
      add :social_links, :map
      add :featured_project_ids, {:array, :binary_id}, default: []
      add :featured_product_ids, {:array, :binary_id}, default: []

      timestamps()
    end
  end
end
