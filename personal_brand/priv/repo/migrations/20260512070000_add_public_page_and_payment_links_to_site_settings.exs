defmodule PersonalBrand.Repo.Migrations.AddPublicPageAndPaymentLinksToSiteSettings do
  use Ecto.Migration

  def change do
    alter table(:site_settings) do
      add :about_intro, :text
      add :about_focus, :text
      add :about_tools, {:array, :string}, null: false, default: []
      add :about_values, {:array, :string}, null: false, default: []
      add :now_building, :text
      add :now_learning, :text
      add :now_focus, :text
      add :now_updated_at, :date
      add :saweria_url, :string
      add :buy_me_coffee_url, :string
      add :tips_cta_title, :string
      add :tips_cta_body, :text
      add :xendit_checkout_url, :string
      add :xendit_webhook_url, :string
    end
  end
end
