defmodule PersonalBrandWeb.Admin.AuthControllerTest do
  use PersonalBrandWeb.ConnCase

  describe "GET /admin/login" do
    test "renders login form without exposing credential hint", %{conn: conn} do
      conn = get(conn, ~p"/admin/login")

      assert html_response(conn, 200) =~ "Nunu Admin"
      assert html_response(conn, 200) =~ "Sign in to manage content and site settings."
      refute html_response(conn, 200) =~ "admin123"
    end
  end

  describe "POST /admin/login" do
    test "logs in with admin username", %{conn: conn} do
      conn = post(conn, ~p"/admin/login", %{username: "admin", password: "admin123"})

      assert redirected_to(conn) == ~p"/admin"
      assert get_session(conn, :admin_token)
    end

    test "logs in with local admin email alias", %{conn: conn} do
      conn =
        post(conn, ~p"/admin/login", %{
          username: "admin@personalbrand.dev",
          password: "admin123"
        })

      assert redirected_to(conn) == ~p"/admin"
      assert get_session(conn, :admin_token)
    end

    test "renders an error for invalid credentials", %{conn: conn} do
      conn = post(conn, ~p"/admin/login", %{username: "admin", password: "wrong"})

      assert html_response(conn, 200) =~ "Invalid username or password"
      refute get_session(conn, :admin_token)
    end
  end
end
