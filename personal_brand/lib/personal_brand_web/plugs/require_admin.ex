defmodule PersonalBrandWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug that checks for a valid admin session token.
  Redirects to /admin/login if not authenticated.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    token = get_session(conn, :admin_token)

    case token && PersonalBrand.Accounts.verify_session_token(token) do
      {:ok, _admin_id} ->
        conn

      _ ->
        conn
        |> Phoenix.Controller.redirect(to: "/admin/login")
        |> halt()
    end
  end
end
