defmodule PersonalBrand.Repo.Migrations.UpdateProductCheckoutDefaults do
  use Ecto.Migration

  def change do
    alter table(:products) do
      modify :checkout_mode, :string, null: false, default: "midtrans_snap"
      modify :payment_provider, :string, null: false, default: "midtrans"
    end
  end
end
