defmodule PersonalBrand.Repo.Migrations.AddProductFulfillmentFields do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :fulfillment_type, :string, null: false, default: "instant_download"
      add :download_media_id, references(:media, type: :binary_id, on_delete: :nilify_all)
      add :requires_shipping, :boolean, null: false, default: false
      add :payment_provider, :string, null: false, default: "midtrans"
      add :checkout_mode, :string, null: false, default: "manual_link"
    end

    create index(:products, [:fulfillment_type])
    create index(:products, [:download_media_id])
  end
end
