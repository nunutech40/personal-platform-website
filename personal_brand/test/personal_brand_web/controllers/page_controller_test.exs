defmodule PersonalBrandWeb.PageControllerTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Repo
  alias PersonalBrand.Content.SiteSetting

  setup do
    Repo.insert!(%SiteSetting{
      site_name: "Test Site",
      headline: "Peace of mind from prototype to production",
      subheadline: "A test subheadline",
      active_theme: "old_web_classic"
    })

    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
