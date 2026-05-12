defmodule PersonalBrand.Repo.Migrations.AddCertificateMediaToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :certificate_media_id, references(:media, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:projects, [:certificate_media_id])
  end
end
