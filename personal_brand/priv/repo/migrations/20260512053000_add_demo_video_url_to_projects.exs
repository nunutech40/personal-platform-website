defmodule PersonalBrand.Repo.Migrations.AddDemoVideoUrlToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :demo_video_url, :string
    end
  end
end
