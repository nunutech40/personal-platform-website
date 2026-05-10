defmodule PersonalBrand.Repo.Migrations.CreateMedia do
  use Ecto.Migration

  def change do
    create table(:media, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :content_type, :string
      add :size, :integer
      add :url, :string, null: false
      add :alt_text, :string
      add :attachable_type, :string
      add :attachable_id, :binary_id

      timestamps()
    end

    create index(:media, [:attachable_type, :attachable_id])
  end
end
