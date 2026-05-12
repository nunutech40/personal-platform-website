defmodule PersonalBrandWeb.Admin.DashboardLiveTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts

  import Phoenix.LiveViewTest

  test "GET /admin renders with an empty database", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin")

    assert html =~ "Dashboard"
    assert html =~ "Projects"
    assert html =~ "0 drafts"
    assert html =~ "old_web_classic"
  end

  defp log_in_admin(conn) do
    init_test_session(conn, admin_token: Accounts.generate_session_token(1))
  end
end
