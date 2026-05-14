defmodule PersonalBrandWeb.CommerceController do
  use PersonalBrandWeb, :controller

  alias PersonalBrand.Commerce
  alias PersonalBrand.Commerce.Order
  alias PersonalBrand.Content
  alias PersonalBrand.Repo

  def create_post_checkout(conn, %{"slug" => slug, "buyer_email" => buyer_email} = params) do
    with post when not is_nil(post) <- Content.get_post_by_slug(slug),
         {:ok, %{redirect_url: redirect_url}} <-
           Commerce.create_post_access_checkout(
             post,
             buyer_email,
             checkout_url_opts(conn),
             params
           ) do
      redirect(conn, external: redirect_url)
    else
      nil ->
        conn
        |> put_flash(:error, "Post tidak ditemukan.")
        |> redirect(to: ~p"/writing")

      {:error, reason} ->
        conn
        |> put_flash(:error, checkout_error(reason))
        |> redirect(to: ~p"/writing/#{slug}")
    end
  end

  def create_product_checkout(conn, %{"slug" => slug, "buyer_email" => buyer_email}) do
    with product when not is_nil(product) <- Content.get_active_product_by_slug(slug),
         {:ok, %{redirect_url: redirect_url}} <-
           Commerce.create_product_purchase_checkout(
             product,
             buyer_email,
             checkout_url_opts(conn)
           ) do
      redirect(conn, external: redirect_url)
    else
      nil ->
        conn
        |> put_flash(:error, "Product tidak ditemukan.")
        |> redirect(to: ~p"/products")

      {:error, reason} ->
        conn
        |> put_flash(:error, checkout_error(reason))
        |> redirect(to: ~p"/products/#{slug}")
    end
  end

  def payment_success(conn, %{"order_id" => provider_order_id, "access_token" => access_token}) do
    case Commerce.get_order_by_provider_order_id(provider_order_id) |> preload_order_target() do
      %Order{status: "paid", post: %{slug: slug}} ->
        redirect(conn, to: ~p"/writing/#{slug}?access_token=#{access_token}")

      %Order{status: "paid", product: %{title: title}} ->
        html(conn, success_page("Payment confirmed", "Akses untuk #{title} sudah aktif."))

      %Order{} ->
        html(
          conn,
          success_page(
            "Payment is being verified",
            "Pembayaran sudah kembali dari Midtrans. Jika status belum berubah, tunggu webhook beberapa saat lalu refresh halaman ini."
          )
        )

      nil ->
        conn
        |> put_status(:not_found)
        |> html(success_page("Order not found", "Order ID tidak ditemukan."))
    end
  end

  def payment_success(conn, _params) do
    html(
      conn,
      success_page("Payment received", "Terima kasih. Status pembayaran sedang diverifikasi.")
    )
  end

  def midtrans_webhook(conn, params) do
    case Commerce.handle_midtrans_notification(params) do
      {:ok, _order} ->
        json(conn, %{ok: true})

      {:error, :invalid_signature} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{ok: false, error: "invalid_signature"})

      {:error, :order_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{ok: false, error: "order_not_found"})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{ok: false, error: inspect(reason)})
    end
  end

  defp checkout_url_opts(conn) do
    [
      success_url: url(conn, ~p"/payment/success"),
      notification_url: url(conn, ~p"/webhooks/midtrans")
    ]
  end

  defp preload_order_target(nil), do: nil
  defp preload_order_target(order), do: Repo.preload(order, [:post, :product])

  defp checkout_error(:payment_not_configured),
    do: "Pembayaran belum dikonfigurasi. Isi MIDTRANS_SERVER_KEY atau checkout URL manual."

  defp checkout_error(:not_paid_post), do: "Post ini belum diset sebagai paid post."
  defp checkout_error(:invalid_price), do: "Harga belum valid."
  defp checkout_error(:invalid_tip_amount), do: "Pilih nominal tips yang tersedia."
  defp checkout_error(_reason), do: "Checkout belum bisa dibuat. Cek konfigurasi pembayaran."

  defp success_page(title, body) do
    """
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{title}</title>
      </head>
      <body>
        <main style="max-width: 680px; margin: 48px auto; font-family: system-ui, sans-serif; line-height: 1.6;">
          <h1>#{title}</h1>
          <p>#{body}</p>
          <p><a href="/writing">Back to writing</a> · <a href="/products">Products</a></p>
        </main>
      </body>
    </html>
    """
  end
end
