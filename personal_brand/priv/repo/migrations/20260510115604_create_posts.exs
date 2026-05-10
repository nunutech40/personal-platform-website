defmodule PersonalBrand.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :excerpt, :text
      add :content_markdown, :text
      add :content_html, :text
      add :editor_type, :string, default: "markdown"
      add :editor_json, :map
      add :tags, {:array, :string}, default: []
      add :status, :string, default: "draft"
      add :featured, :boolean, default: false
      add :published_at, :utc_datetime
      add :reading_time, :integer
      add :seo_title, :string
      add :seo_description, :text
      add :cover_image_id, :binary_id
      add :og_image_id, :binary_id

      timestamps()
    end

    create unique_index(:posts, [:slug])
    create index(:posts, [:status])
    create index(:posts, [:published_at])
  end
end
