defmodule PersonalBrand.CommerceTest do
  use PersonalBrand.DataCase

  alias PersonalBrand.Commerce
  alias PersonalBrand.Commerce.{AccessGrant, Order}
  alias PersonalBrand.Content.{Post, Product}

  import Swoosh.TestAssertions

  setup do
    original = Application.get_env(:personal_brand, :midtrans)

    on_exit(fn ->
      Application.put_env(:personal_brand, :midtrans, original)
    end)

    Application.put_env(:personal_brand, :midtrans, server_key: nil, environment: "sandbox")

    :ok
  end

  test "creates manual post access order and hashed access grant" do
    post = insert_paid_post()

    assert {:ok,
            %{
              order: %Order{} = order,
              access_grant: %AccessGrant{} = grant,
              access_token: access_token,
              redirect_url: "https://example.com/pay-post"
            }} =
             Commerce.create_post_access_checkout(post, "reader@example.com",
               success_url: "http://localhost:4002/payment/success",
               notification_url: "http://localhost:4002/webhooks/midtrans"
             )

    refute Commerce.valid_post_access?(post, access_token)
    refute grant.token_hash == access_token
    assert order.kind == "post_access"
    assert order.status == "pending"
    assert order.provider == "manual"
    assert order.post_id == post.id
  end

  test "midtrans webhook verifies signature, marks order paid, and unlocks token" do
    post = insert_paid_post()

    {:ok, %{order: order, access_token: access_token}} =
      Commerce.create_post_access_checkout(post, "reader@example.com",
        success_url: "http://localhost:4002/payment/success",
        notification_url: "http://localhost:4002/webhooks/midtrans"
      )

    Application.put_env(:personal_brand, :midtrans,
      server_key: "server-key",
      environment: "sandbox"
    )

    payload = midtrans_payload(order, "settlement")

    assert {:ok, %Order{status: "paid", paid_at: paid_at} = paid_order} =
             Commerce.handle_midtrans_notification(payload)

    assert paid_at
    assert paid_order.fulfillment_status == "fulfilled"
    assert paid_order.fulfilled_at
    assert Commerce.valid_post_access?(post, access_token)

    assert_email_sent(
      subject: "[Personal Brand] Pembayaran masuk - Paid Post",
      to: [{"", "r.fajarnugraha@gmail.com"}]
    )
  end

  test "midtrans webhook sends paid product notification once" do
    product = insert_product()

    {:ok, %{order: order}} =
      Commerce.create_product_purchase_checkout(product, "buyer@example.com",
        success_url: "http://localhost:4002/payment/success",
        notification_url: "http://localhost:4002/webhooks/midtrans"
      )

    Application.put_env(:personal_brand, :midtrans,
      server_key: "server-key",
      environment: "sandbox"
    )

    payload = midtrans_payload(order, "settlement")

    assert {:ok, %Order{status: "paid"}} = Commerce.handle_midtrans_notification(payload)

    assert_email_sent(
      subject: "[Personal Brand] Pembayaran masuk - Digital Product",
      to: [{"", "r.fajarnugraha@gmail.com"}]
    )

    assert {:ok, %Order{status: "paid"}} = Commerce.handle_midtrans_notification(payload)
    refute_email_sent(subject: "[Personal Brand] Pembayaran masuk - Digital Product")
  end

  test "midtrans webhook rejects invalid signature" do
    Application.put_env(:personal_brand, :midtrans,
      server_key: "server-key",
      environment: "sandbox"
    )

    order = insert_order()

    payload =
      order
      |> midtrans_payload("settlement")
      |> Map.put("signature_key", "bad")

    assert {:error, :invalid_signature} = Commerce.handle_midtrans_notification(payload)
  end

  test "creates product purchase order" do
    product = insert_product()

    assert {:ok, %{order: %Order{} = order, access_grant: %AccessGrant{} = grant}} =
             Commerce.create_product_purchase_checkout(product, "buyer@example.com",
               success_url: "http://localhost:4002/payment/success",
               notification_url: "http://localhost:4002/webhooks/midtrans"
             )

    assert order.kind == "product_purchase"
    assert order.product_id == product.id
    assert grant.product_id == product.id
  end

  test "creates tips order from one of the configured amount options" do
    post =
      insert_paid_post(%{
        slug: "tips-post",
        access_type: "tips",
        price: nil,
        tip_amount_options: [10000, 20000]
      })

    assert {:ok, %{order: %Order{} = order}} =
             Commerce.create_post_access_checkout(
               post,
               "reader@example.com",
               [
                 success_url: "http://localhost:4002/payment/success",
                 notification_url: "http://localhost:4002/webhooks/midtrans"
               ],
               %{"tip_amount" => "20000"}
             )

    assert order.kind == "tip"
    assert order.amount == Decimal.new("20000")
  end

  test "rejects unavailable tips amount" do
    post =
      insert_paid_post(%{
        slug: "tips-post",
        access_type: "tips",
        price: nil,
        tip_amount_options: [10000, 20000]
      })

    assert {:error, :invalid_tip_amount} =
             Commerce.create_post_access_checkout(
               post,
               "reader@example.com",
               [
                 success_url: "http://localhost:4002/payment/success",
                 notification_url: "http://localhost:4002/webhooks/midtrans"
               ],
               %{"tip_amount" => "15000"}
             )
  end

  defp insert_paid_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(
      Map.merge(
        %{
          title: "Paid Post",
          slug: "paid-post",
          excerpt: "Preview",
          content_markdown: "Secret body",
          status: "published",
          reading_time: 5,
          access_type: "paid",
          price: Decimal.new("25000"),
          currency: "IDR",
          checkout_url: "https://example.com/pay-post"
        },
        attrs
      )
    )
    |> Repo.insert!()
  end

  defp insert_product do
    %Product{}
    |> Product.changeset(%{
      title: "Digital Product",
      slug: "digital-product",
      summary: "Summary",
      product_type: "digital",
      price: Decimal.new("49000"),
      currency: "IDR",
      status: "active",
      stock_status: "in_stock",
      delivery_type: "digital_download",
      checkout_url: "https://example.com/pay-product"
    })
    |> Repo.insert!()
  end

  defp insert_order do
    post = insert_paid_post()

    %Order{}
    |> Order.changeset(%{
      kind: "post_access",
      status: "pending",
      provider: "midtrans",
      provider_order_id: "post-test",
      buyer_email: "reader@example.com",
      amount: Decimal.new("25000"),
      currency: "IDR",
      post_id: post.id,
      fulfillment_status: "unfulfilled"
    })
    |> Repo.insert!()
  end

  defp midtrans_payload(order, transaction_status) do
    gross_amount = "#{Decimal.to_string(order.amount, :normal)}.00"

    signature =
      :crypto.hash(
        :sha512,
        order.provider_order_id <> "200" <> gross_amount <> "server-key"
      )
      |> Base.encode16(case: :lower)

    %{
      "order_id" => order.provider_order_id,
      "status_code" => "200",
      "gross_amount" => gross_amount,
      "transaction_status" => transaction_status,
      "transaction_id" => "midtrans-tx-1",
      "fraud_status" => "accept",
      "signature_key" => signature
    }
  end
end
