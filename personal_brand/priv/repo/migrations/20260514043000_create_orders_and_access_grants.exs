defmodule PersonalBrand.Repo.Migrations.CreateOrdersAndAccessGrants do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :kind, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :provider, :string, null: false, default: "midtrans"
      add :provider_order_id, :string, null: false
      add :provider_transaction_id, :string
      add :buyer_email, :string, null: false
      add :amount, :decimal, null: false
      add :currency, :string, null: false, default: "IDR"
      add :post_id, references(:posts, type: :binary_id, on_delete: :nilify_all)
      add :product_id, references(:products, type: :binary_id, on_delete: :nilify_all)
      add :checkout_url, :text
      add :metadata, :map, null: false, default: %{}
      add :paid_at, :utc_datetime

      timestamps()
    end

    create unique_index(:orders, [:provider_order_id])
    create index(:orders, [:kind])
    create index(:orders, [:status])
    create index(:orders, [:buyer_email])
    create index(:orders, [:post_id])
    create index(:orders, [:product_id])

    create table(:access_grants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order_id, references(:orders, type: :binary_id, on_delete: :delete_all), null: false
      add :post_id, references(:posts, type: :binary_id, on_delete: :nilify_all)
      add :product_id, references(:products, type: :binary_id, on_delete: :nilify_all)
      add :buyer_email, :string, null: false
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime
      add :used_at, :utc_datetime

      timestamps()
    end

    create unique_index(:access_grants, [:token_hash])
    create index(:access_grants, [:order_id])
    create index(:access_grants, [:post_id])
    create index(:access_grants, [:product_id])
    create index(:access_grants, [:buyer_email])
  end
end
