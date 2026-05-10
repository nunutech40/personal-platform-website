defmodule PersonalBrandWeb.Admin.AuthController do
  use PersonalBrandWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case PersonalBrand.Accounts.authenticate(username, password) do
      {:ok, admin} ->
        token = PersonalBrand.Accounts.generate_session_token(admin.id)

        conn
        |> put_session(:admin_token, token)
        |> configure_session(renew: true)
        |> redirect(to: "/admin")

      {:error, :invalid_credentials} ->
        render(conn, :new, error: "Invalid username or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/admin/login")
  end
end
