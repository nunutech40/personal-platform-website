defmodule PersonalBrand.Repo.Migrations.AddBestThreeAndPostClaps do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :best_three, :boolean, null: false, default: false
    end

    alter table(:posts) do
      add :clap_count, :integer, null: false, default: 0
    end

    create index(:projects, [:best_three])
    create index(:posts, [:clap_count])
  end
end
