defmodule PersonalBrand.Repo.Migrations.CreateThemes do
  use Ecto.Migration

  def change do
    create table(:themes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :is_active, :boolean, default: false
      add :config, :map

      timestamps()
    end

    create unique_index(:themes, [:key])
  end
end
