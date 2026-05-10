defmodule PersonalBrand.Repo do
  use Ecto.Repo,
    otp_app: :personal_brand,
    adapter: Ecto.Adapters.Postgres
end
