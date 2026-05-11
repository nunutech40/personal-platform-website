defmodule PersonalBrand.Repo.Migrations.AddPortfolioFieldsToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :project_type, :string
      add :company, :string
      add :client, :string
      add :platforms, {:array, :string}, null: false, default: []
      add :disciplines, {:array, :string}, null: false, default: []
      add :ownership, :string
      add :team_size, :string
      add :duration, :string
      add :impact_summary, :text
      add :technical_highlights, {:array, :string}, null: false, default: []
      add :architecture_notes, :text
      add :tradeoffs, :text
      add :metrics, {:array, :string}, null: false, default: []
      add :app_store_url, :string
      add :case_study_visibility, :string, null: false, default: "public"
      add :sort_order, :integer, null: false, default: 0
    end

    create index(:projects, [:sort_order])
    create index(:projects, [:status, :sort_order])
    create index(:projects, [:platforms], using: :gin)
    create index(:projects, [:disciplines], using: :gin)
  end
end
