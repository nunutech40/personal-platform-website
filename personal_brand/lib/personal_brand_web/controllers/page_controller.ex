defmodule PersonalBrandWeb.PageController do
  use PersonalBrandWeb, :controller

  def index(conn, _params) do
    token = get_session(conn, :admin_token)

    case token && PersonalBrand.Accounts.verify_session_token(token) do
      {:ok, _admin_id} ->
        redirect(conn, to: "/admin")

      _ ->
        redirect(conn, to: "/admin/login")
    end
  end
end
