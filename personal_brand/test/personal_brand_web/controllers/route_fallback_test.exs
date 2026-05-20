defmodule PersonalBrandWeb.RouteFallbackTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts

  test "unknown admin route redirects unauthenticated users to login", %{conn: conn} do
    conn = get(conn, "/admin/p")

    assert redirected_to(conn) == "/admin/login"
  end

  test "unknown admin route redirects authenticated users to dashboard", %{conn: conn} do
    conn =
      conn
      |> init_test_session(admin_token: Accounts.generate_session_token(1))
      |> get("/admin/p")

    assert redirected_to(conn) == "/admin"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Admin page tidak ditemukan."
  end

  test "unknown public route renders the public not found page", %{conn: conn} do
    html =
      conn
      |> get("/not-a-real-page")
      |> html_response(200)

    assert html =~ "Page Not Found"
    refute html =~ "Phoenix.Router.NoRouteError"
  end
end
