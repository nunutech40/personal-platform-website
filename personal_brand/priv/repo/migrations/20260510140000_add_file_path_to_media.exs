defmodule PersonalBrand.Repo.Migrations.AddFilePathToMedia do
  use Ecto.Migration

  def change do
    alter table(:media) do
      add :file_path, :string
    end
  end
end
