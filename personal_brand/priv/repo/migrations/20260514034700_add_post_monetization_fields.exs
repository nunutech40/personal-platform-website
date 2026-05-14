defmodule PersonalBrand.Repo.Migrations.AddPostMonetizationFields do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :access_type, :string, null: false, default: "free"
      add :price, :decimal
      add :currency, :string, null: false, default: "IDR"
      add :tip_amount_options, {:array, :integer}, null: false, default: []
      add :paid_excerpt, :text
      add :paywall_cta, :text
      add :payment_provider, :string
      add :checkout_url, :string
    end
  end
end
