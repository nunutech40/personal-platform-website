defmodule PersonalBrand.Repo.Migrations.AddSortDateToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :sort_date, :date
    end

    create index(:projects, [:sort_order, :sort_date])
  end
end
