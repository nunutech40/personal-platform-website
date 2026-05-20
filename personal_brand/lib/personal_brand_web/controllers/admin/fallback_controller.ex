defmodule PersonalBrandWeb.Admin.FallbackController do
  use PersonalBrandWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_flash(:error, "Admin page tidak ditemukan.")
    |> redirect(to: "/admin")
  end
end
