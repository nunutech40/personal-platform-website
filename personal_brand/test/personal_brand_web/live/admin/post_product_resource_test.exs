defmodule PersonalBrandWeb.Admin.PostProductResourceTest do
  use PersonalBrandWeb.ConnCase

  alias PersonalBrand.Accounts
  alias PersonalBrand.Content.Post
  alias PersonalBrand.Content.Product
  alias PersonalBrand.Repo

  import Phoenix.LiveViewTest

  test "GET /admin/posts/new renders standardized writing form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/posts/new")

    assert html =~ "Info Dasar"
    assert html =~ "Konten"
    assert html =~ "Publishing"
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
      |> live(~p"/admin/posts/new")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" => post_attrs(%{"title" => "Admin Writing Post", "slug" => ""}),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/admin/posts")

    post = Repo.get_by!(Post, slug: "admin-writing-post")
    assert post.title == "Admin Writing Post"
    assert post.tags == ["Elixir", "Phoenix LiveView"]
  end

  test "GET /admin/posts includes edit preview and delete row actions", %{conn: conn} do
    post = insert_post(%{title: "Post Row Actions", slug: "post-row-actions"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/posts")

    assert html =~ "Post Row Actions"
    assert html =~ ~s(href="/admin/posts/#{post.id}/edit")
    assert html =~ ~s(href="/writing/post-row-actions")
    assert html =~ ~s(phx-value-action-key="delete")
  end

  test "GET /admin/products/new renders standardized product form", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/products/new")

    assert html =~ "Info Dasar"
    assert html =~ "Commerce"
    assert html =~ "Delivery"
    assert html =~ "Kosongkan saat membuat produk baru"
    assert html =~ ~s(value="USD")
    assert html =~ "Usage examples"
  end

  test "admin product form creates a product without manual slug", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/products/new")

    view
    |> element("#resource-form")
    |> render_submit(%{
      "change" => product_attrs(%{"title" => "Admin Product", "slug" => ""}),
      "save-type" => "save"
    })

    assert_redirect(view, ~p"/admin/products")

    product = Repo.get_by!(Product, slug: "admin-product")
    assert product.title == "Admin Product"
    assert product.included == ["Download files", "Usage examples"]
  end

  test "GET /admin/products includes edit preview and delete row actions", %{conn: conn} do
    product = insert_product(%{title: "Product Row Actions", slug: "product-row-actions"})

    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/products")

    assert html =~ "Product Row Actions"
    assert html =~ ~s(href="/admin/products/#{product.id}/edit")
    assert html =~ ~s(href="/products/product-row-actions")
    assert html =~ ~s(phx-value-action-key="delete")
  end

  test "GET /admin/products empty state is polished and hides bulk delete", %{conn: conn} do
    {:ok, _view, html} =
      conn
      |> log_in_admin()
      |> live(~p"/admin/products")

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
        "currency" => "USD",
        "stock_status" => "in_stock",
        "delivery_type" => "digital_download",
        "checkout_url" => "",
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
      currency: "USD",
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
