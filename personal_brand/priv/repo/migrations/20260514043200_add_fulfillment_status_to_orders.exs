defmodule PersonalBrand.Repo.Migrations.AddFulfillmentStatusToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :fulfillment_status, :string, null: false, default: "unfulfilled"
      add :fulfilled_at, :utc_datetime
    end

    create index(:orders, [:fulfillment_status])
  end
end
