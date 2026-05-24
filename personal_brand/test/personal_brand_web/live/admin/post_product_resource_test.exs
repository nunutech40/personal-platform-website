defmodule PersonalBrandWeb.Admin.PostProductResourceTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts
  alias PersonalBrand.Content.Post
  alias PersonalBrand.Content.Product
  alias PersonalBrand.Repo

  import Phoenix.LiveViewTest

  test "GET /nunu-ops-7f3c/posts/new renders standardized writing form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/posts/new")

    assert html =~ "Info Dasar"
    assert html =~ "Konten"
    assert html =~ "Publishing"
    assert html =~ "Monetisasi"
    assert html =~ "Tipe Akses"
    assert html =~ "Opsi Jumlah Tips"
    assert html =~ "Media"
    assert html =~ "Cover Image"
    assert html =~ "Open Graph Image"
    assert html =~ "Kosongkan saat membuat post baru"
    assert html =~ "Saran:"
    assert html =~ "Phoenix LiveView"
  end

  test "admin post form creates a post without manual slug", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/posts/new")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" => post_attrs(%{"title" => "Admin Writing Post", "slug" => ""}),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/nunu-ops-7f3c/posts")

    post = Repo.get_by!(Post, slug: "admin-writing-post")
    assert post.title == "Admin Writing Post"
    assert post.tags == ["Elixir", "Phoenix LiveView"]
  end

  test "admin post form saves tips access type with required amount options", %{conn: conn} do
    post = insert_post(%{title: "Mode Switch Post", slug: "mode-switch-post"})

    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/posts/#{post.id}/edit")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" =>
        post_attrs(%{
          "title" => "Mode Switch Post",
          "slug" => "mode-switch-post",
          "access_type" => "tips",
          "price" => "25000",
          "currency" => "IDR",
          "tip_amount_options" => "10000\n15000\n25000"
        }),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/nunu-ops-7f3c/posts")

    post = Repo.get_by!(Post, slug: "mode-switch-post")
    assert post.access_type == "tips"
    assert post.price == nil
    assert post.tip_amount_options == [10000, 15000, 25000]
  end

  test "admin post form keeps tips invalid when amount options are blank", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/posts/new")

    html =
      view
      |> element("#resource-form")
      |> render_submit(%{
        "change" =>
          post_attrs(%{
            "title" => "Tips Without Amounts",
            "slug" => "",
            "access_type" => "tips",
            "tip_amount_options" => ""
          }),
        "save-type" => "save"
      })

    assert html =~ "must contain at least one amount for tips posts"
    refute Repo.get_by(Post, slug: "tips-without-amounts")
  end

  test "GET /nunu-ops-7f3c/posts includes edit preview and delete row actions", %{conn: conn} do
    post = insert_post(%{title: "Post Row Actions", slug: "post-row-actions"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/posts")

    assert html =~ "Post Row Actions"
    assert html =~ ~s(href="/nunu-ops-7f3c/posts/#{post.id}/edit")
    assert html =~ ~s(href="/writing/post-row-actions")
    assert html =~ ~s(phx-value-action-key="delete")
  end

  test "GET /nunu-ops-7f3c/products/new renders standardized product form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/products/new")

    assert html =~ "Info Dasar"
    assert html =~ "Monetisasi"
    assert html =~ "Delivery"
    assert html =~ "Preview untuk Checkout"
    assert html =~ "CTA Checkout"
    assert html =~ "Kosongkan saat membuat produk baru"
    assert html =~ ~s(value="IDR")
    assert html =~ "Usage examples"
  end

  test "admin product form creates a product without manual slug", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/products/new")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" => product_attrs(%{"title" => "Admin Product", "slug" => ""}),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/nunu-ops-7f3c/products")

    product = Repo.get_by!(Product, slug: "admin-product")
    assert product.title == "Admin Product"
    assert product.included == ["Download files", "Usage examples"]
  end

  test "GET /nunu-ops-7f3c/products includes edit preview and delete row actions", %{conn: conn} do
    product = insert_product(%{title: "Product Row Actions", slug: "product-row-actions"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/products")

    assert html =~ "Product Row Actions"
    assert html =~ ~s(href="/nunu-ops-7f3c/products/#{product.id}/edit")
    assert html =~ ~s(href="/products/product-row-actions")
    assert html =~ ~s(phx-value-action-key="delete")
  end

  test "GET /nunu-ops-7f3c/products empty state is polished and hides bulk delete", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/nunu-ops-7f3c/products")

    assert html =~ "Belum ada data yang dibuat."
    assert html =~ "Mulai dengan satu item yang rapi."
    assert html =~ "New Product"
    refute html =~ ">Delete<"
    refute html =~ ~s(name="select_per_page[value]")
  end

  defp log_in_admin(conn) do
    init_test_session(conn, admin_token: Accounts.generate_session_token(1))
  end

  defp post_attrs(attrs) do
    Map.merge(
      %{
        "title" => "Post",
        "slug" => "post",
        "excerpt" => "Short post excerpt",
        "content_markdown" => "# Post",
        "tags" => "Elixir\nPhoenix LiveView",
        "status" => "published",
        "featured" => "false",
        "reading_time" => "5"
      },
      attrs
    )
  end

  defp product_attrs(attrs) do
    Map.merge(
      %{
        "title" => "Product",
        "slug" => "product",
        "summary" => "Useful product summary",
        "description" => "Product description",
        "status" => "active",
        "product_type" => "digital",
        "price" => "29.00",
        "currency" => "IDR",
        "stock_status" => "in_stock",
        "delivery_type" => "digital_download",
        "checkout_url" => "",
        "paid_excerpt" => "Checkout preview",
        "paywall_cta" => "Beli produk ini",
        "featured" => "false",
        "included" => "Download files\nUsage examples"
      },
      attrs
    )
  end

  defp insert_post(attrs) do
    defaults = %{
      title: "Post",
      slug: "post",
      excerpt: "Excerpt",
      content_markdown: "# Post",
      tags: ["Elixir"],
      status: "published",
      featured: false,
      reading_time: 5
    }

    %Post{}
    |> Post.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp insert_product(attrs) do
    defaults = %{
      title: "Product",
      slug: "product",
      summary: "Summary",
      description: "Description",
      product_type: "digital",
      price: Decimal.new("29.00"),
      currency: "IDR",
      status: "active",
      stock_status: "in_stock",
      delivery_type: "digital_download",
      checkout_url: nil,
      featured: false,
      included: ["Download files"]
    }

    %Product{}
    |> Product.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end
end
