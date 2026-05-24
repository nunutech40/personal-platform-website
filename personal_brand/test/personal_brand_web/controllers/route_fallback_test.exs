defmodule PersonalBrandWeb.RouteFallbackTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts

  test "unknown admin route redirects unauthenticated users to login", %{conn: conn} do
    conn = get(conn, "/nunu-ops-7f3c/p")

    assert redirected_to(conn) == "/nunu-ops-7f3c/login"
  end

  test "unknown admin route redirects authenticated users to dashboard", %{conn: conn} do
    conn =
      conn
      |> init_test_session(admin_token: Accounts.generate_session_token(1))
      |> get("/nunu-ops-7f3c/p")

    assert redirected_to(conn) == "/nunu-ops-7f3c"
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
