defmodule PersonalBrand.Repo.Migrations.AddStatusToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :status, :string, default: "active"
    end

    create index(:products, [:status])
  end
end
