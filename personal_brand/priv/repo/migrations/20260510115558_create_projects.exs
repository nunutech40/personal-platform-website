defmodule PersonalBrand.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :summary, :text
      add :description, :text
      add :problem, :text
      add :solution, :text
      add :result, {:array, :string}, default: []
      add :role, :string
      add :tech_stack, {:array, :string}, default: []
      add :year, :string
      add :status, :string, default: "draft"
      add :featured, :boolean, default: false
      add :demo_url, :string
      add :github_url, :string
      add :cover_image_id, :binary_id

      timestamps()
    end

    create unique_index(:projects, [:slug])
    create index(:projects, [:status])
    create index(:projects, [:featured])
  end
end
