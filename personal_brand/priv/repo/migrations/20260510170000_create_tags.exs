defmodule PersonalBrand.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
    create unique_index(:tags, [:slug])

    # ── Pivot: project_tags ──────────────────────────────────
    create table(:project_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      add :tag_id, references(:tags, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:project_tags, [:project_id, :tag_id])
    create index(:project_tags, [:tag_id])

    # ── Pivot: post_tags ─────────────────────────────────────
    create table(:post_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:post_tags, [:post_id, :tag_id])
    create index(:post_tags, [:tag_id])

    # ── Pivot: product_tags ──────────────────────────────────
    create table(:product_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      add :tag_id, references(:tags, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:product_tags, [:product_id, :tag_id])
    create index(:product_tags, [:tag_id])
  end
end
