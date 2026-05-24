defmodule PersonalBrandWeb.Admin.MediaSettingsThemeResourceTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts
  alias PersonalBrand.Content.Media
  alias PersonalBrand.Content.SiteSetting
  alias PersonalBrand.Content.Theme
  alias PersonalBrand.Repo

  import Phoenix.LiveViewTest

  test "GET /nunu-ops-7f3c/media/new renders standardized media form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/media/new")

    assert html =~ "Upload"
    assert html =~ "Metadata"
    assert html =~ "Upload maksimal 20MB"
    assert html =~ "external image/video"
    assert html =~ "Alt Text"
    assert html =~ "Storage Path"
  end

  test "GET /nunu-ops-7f3c/media includes preview and row actions", %{conn: conn} do
    media = insert_media(%{filename: "cover.png", url: "/uploads/media/cover.png"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/media")

    assert html =~ "cover.png"
    assert html =~ ~s(href="/nunu-ops-7f3c/media/#{media.id}/edit")
    assert html =~ ~s(href="/uploads/media/cover.png")
    assert html =~ ~s(phx-value-action-key="delete")
  end

  test "GET /nunu-ops-7f3c/media previews external image URL without content type", %{conn: conn} do
    insert_media(%{
      filename: "github-cover.png",
      content_type: nil,
      url: "https://raw.githubusercontent.com/nunutech40/repo/main/docs/assets/cover.png"
    })

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/media")

    assert html =~
             ~s(src="https://raw.githubusercontent.com/nunutech40/repo/main/docs/assets/cover.png")
  end

  test "GET /nunu-ops-7f3c/site-settings redirects directly to singleton edit form", %{
    conn: conn
  } do
    insert_theme(%{key: "old_web_classic", name: "Old Web Classic"})
    setting = insert_site_setting()

    assert {:error, {:live_redirect, %{to: path}}} =
             conn
             |> log_in_admin()
             |> live(~p"/nunu-ops-7f3c/site-settings")

    assert path == ~p"/nunu-ops-7f3c/site-settings/#{setting.id}/edit"
  end

  test "GET /nunu-ops-7f3c/site-settings/:id/edit keeps settings singleton actions clean", %{
    conn: conn
  } do
    insert_theme(%{key: "old_web_classic", name: "Old Web Classic"})
    setting = insert_site_setting()

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/site-settings/#{setting.id}/edit")

    assert html =~ "Nunu Test"
    refute html =~ "New Site Setting"
    refute html =~ "Delete"
    refute html =~ "Hapus"
  end

  test "GET /nunu-ops-7f3c/site-settings/:id/edit renders standardized settings form", %{
    conn: conn
  } do
    insert_theme(%{key: "old_web_classic", name: "Old Web Classic"})
    setting = insert_site_setting()

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/site-settings/#{setting.id}/edit")

    assert html =~ "Identitas Website"
    assert html =~ "Homepage CTA"
    assert html =~ "Profil"
    assert html =~ "About Page"
    assert html =~ "Now Page"
    assert html =~ "Support / Tips"
    assert html =~ "Payment Links"
    assert html =~ "Theme"
    assert html =~ "Social Links"
    assert html =~ "Saweria URL"
    assert html =~ "Buy Me Coffee URL"
    assert html =~ "Xendit Checkout URL"
    assert html =~ "Old Web Classic"
  end

  test "admin site settings form accepts social links and featured IDs textareas", %{conn: conn} do
    insert_theme(%{key: "old_web_classic", name: "Old Web Classic"})
    setting = insert_site_setting(%{site_name: "Existing Site"})
    project_id = Ecto.UUID.generate()
    product_id = Ecto.UUID.generate()

    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/site-settings/#{setting.id}/edit")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" =>
        site_setting_attrs(%{
          "social_links" =>
            "GitHub=https://github.com/nunu\nLinkedIn=https://linkedin.com/in/nunu",
          "about_tools" => "Elixir\nPhoenix LiveView",
          "about_values" => "Readable code\nUseful products",
          "now_updated_at" => "2026-05-12",
          "saweria_url" => "https://saweria.co/nunu",
          "buy_me_coffee_url" => "https://www.buymeacoffee.com/nunu",
          "xendit_checkout_url" => "https://checkout.xendit.co/example",
          "featured_project_ids" => project_id,
          "featured_product_ids" => product_id
        }),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/nunu-ops-7f3c/site-settings/#{setting.id}/edit")

    setting = Repo.get!(SiteSetting, setting.id)
    assert setting.site_name == "Nunu Test"
    assert setting.social_links["GitHub"] == "https://github.com/nunu"
    assert setting.about_tools == ["Elixir", "Phoenix LiveView"]
    assert setting.about_values == ["Readable code", "Useful products"]
    assert setting.now_updated_at == ~D[2026-05-12]
    assert setting.saweria_url == "https://saweria.co/nunu"
    assert setting.buy_me_coffee_url == "https://www.buymeacoffee.com/nunu"
    assert setting.xendit_checkout_url == "https://checkout.xendit.co/example"
    assert setting.featured_project_ids == [project_id]
    assert setting.featured_product_ids == [product_id]
  end

  test "GET /nunu-ops-7f3c/themes/new renders standardized theme form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/themes/new")

    assert html =~ "Info Theme"
    assert html =~ "Konfigurasi"
    assert html =~ "Config JSON"
    assert html =~ "Lowercase, angka, dan underscore saja"
  end

  test "admin theme form creates theme with JSON config", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/themes/new")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" =>
        theme_attrs(%{
          "key" => "clean_focus",
          "name" => "Clean Focus",
          "config" => ~s({"accent_color":"#111827"})
        }),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/nunu-ops-7f3c/themes")

    theme = Repo.get_by!(Theme, key: "clean_focus")
    assert theme.config == %{"accent_color" => "#111827"}
  end

  test "GET /nunu-ops-7f3c/themes includes edit preview row actions", %{conn: conn} do
    theme = insert_theme(%{key: "old_web_classic", name: "Old Web Classic"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/themes")

    assert html =~ "Old Web Classic"
    assert html =~ ~s(href="/nunu-ops-7f3c/themes/#{theme.id}/edit")
    assert html =~ ~s(href="/")
  end

  defp log_in_admin(conn) do
    init_test_session(conn, admin_token: Accounts.generate_session_token(1))
  end

  defp insert_media(attrs) do
    defaults = %{
      filename: "media.png",
      content_type: "image/png",
      size: 1200,
      url: "/uploads/media/media.png",
      alt_text: "Media preview"
    }

    %Media{}
    |> Media.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp insert_theme(attrs) do
    defaults = %{
      key: "theme_key",
      name: "Theme Name",
      description: "Theme description",
      is_active: true,
      config: %{}
    }

    %Theme{}
    |> Theme.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp insert_site_setting(attrs \\ %{}) do
    site_setting_attrs(%{})
    |> Map.merge(stringify_attrs(attrs))
    |> then(&SiteSetting.changeset(%SiteSetting{}, &1))
    |> Repo.insert!()
  end

  defp stringify_attrs(attrs) do
    Map.new(attrs, fn {key, value} -> {to_string(key), value} end)
  end

  defp site_setting_attrs(attrs) do
    Map.merge(
      %{
        "site_name" => "Nunu Test",
        "headline" => "Build and ship",
        "subheadline" => "Personal platform",
        "primary_cta_text" => "View Work",
        "primary_cta_url" => "/work",
        "secondary_cta_text" => "Read Writing",
        "secondary_cta_url" => "/writing",
        "active_theme" => "old_web_classic",
        "profile_name" => "Nunu Nugraha",
        "profile_title" => "Software Engineer",
        "profile_location" => "Jakarta",
        "profile_email" => "nunu@example.com",
        "profile_bio" => "Builder"
      },
      attrs
    )
  end

  defp theme_attrs(attrs) do
    Map.merge(
      %{
        "key" => "theme_key",
        "name" => "Theme Name",
        "description" => "Theme description",
        "is_active" => "true",
        "config" => "{}"
      },
      attrs
    )
  end
end
