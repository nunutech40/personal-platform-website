defmodule PersonalBrand.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :summary, :text
      add :description, :text
      add :product_type, :string, default: "digital"
      add :price, :decimal, precision: 10, scale: 2
      add :currency, :string, default: "USD"
      add :stock_status, :string, default: "in_stock"
      add :delivery_type, :string, default: "digital_download"
      add :checkout_url, :string
      add :featured, :boolean, default: false
      add :included, {:array, :string}, default: []
      add :faq, :map
      add :cover_image_id, :binary_id

      timestamps()
    end

    create unique_index(:products, [:slug])
    create index(:products, [:featured])
  end
end
