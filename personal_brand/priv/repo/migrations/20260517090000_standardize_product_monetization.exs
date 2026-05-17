defmodule PersonalBrand.Repo.Migrations.StandardizeProductMonetization do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :paid_excerpt, :text
      add :paywall_cta, :string
      modify :currency, :string, default: "IDR"
    end
  end
end
