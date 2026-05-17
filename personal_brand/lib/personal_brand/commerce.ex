defmodule PersonalBrand.Commerce do
  @moduledoc """
  Commerce boundary for paid writing, product purchases, and payment notifications.
  """

  alias Ecto.Multi
  alias PersonalBrand.Commerce.{AccessGrant, Midtrans, Order, PaymentNotifier}
  alias PersonalBrand.Content.{Post, Product}
  alias PersonalBrand.Repo

  import Ecto.Query

  @token_bytes 32

  def list_orders do
    Repo.all(from o in Order, order_by: [desc: o.inserted_at])
  end

  def get_order_by_provider_order_id(provider_order_id) when is_binary(provider_order_id) do
    Repo.get_by(Order, provider_order_id: provider_order_id)
  end

  def create_post_access_checkout(%Post{} = post, buyer_email, url_opts, attrs \\ %{}) do
    with {:ok, amount} <- post_access_amount(post, attrs) do
      create_checkout(
        %{
          kind: post_order_kind(post),
          amount: amount,
          currency: post.currency || "IDR",
          post_id: post.id,
          buyer_email: buyer_email,
          fallback_checkout_url: post.checkout_url,
          prefer_midtrans?: post.payment_provider == "midtrans"
        },
        url_opts
      )
    end
  end

  def create_product_purchase_checkout(%Product{} = product, buyer_email, url_opts) do
    create_checkout(
      %{
        kind: "product_purchase",
        amount: product.price,
        currency: product.currency || "IDR",
        product_id: product.id,
        buyer_email: buyer_email,
        fallback_checkout_url: product.checkout_url,
        prefer_midtrans?: product.checkout_mode == "midtrans_snap"
      },
      url_opts
    )
  end

  def valid_post_access?(%Post{} = post, token) when is_binary(token) and token != "" do
    token_hash = hash_token(token)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    query =
      from grant in AccessGrant,
        join: order in assoc(grant, :order),
        where:
          grant.post_id == ^post.id and
            grant.token_hash == ^token_hash and
            order.status == "paid" and
            (is_nil(grant.expires_at) or grant.expires_at > ^now),
        select: grant

    case Repo.one(query) do
      nil ->
        false

      grant ->
        grant
        |> AccessGrant.changeset(%{used_at: now})
        |> Repo.update()

        true
    end
  end

  def valid_post_access?(_post, _token), do: false

  def handle_midtrans_notification(payload) when is_map(payload) do
    if Midtrans.signature_valid?(payload) do
      apply_midtrans_notification(payload)
    else
      {:error, :invalid_signature}
    end
  end

  defp apply_midtrans_notification(payload) do
    provider_order_id = payload["order_id"]
    status = Midtrans.payment_status(payload)
    transaction_id = payload["transaction_id"]

    Repo.transaction(fn ->
      order =
        provider_order_id
        |> get_order_by_provider_order_id()
        |> case do
          nil -> Repo.rollback(:order_not_found)
          order -> order
        end

      paid_at =
        if status == "paid" and is_nil(order.paid_at) do
          DateTime.utc_now() |> DateTime.truncate(:second)
        else
          order.paid_at
        end

      notify_paid? = status == "paid" and is_nil(order.paid_at)

      fulfillment_status =
        if status == "paid" and order.kind in ["post_access", "tip"] do
          "fulfilled"
        else
          order.fulfillment_status
        end

      metadata =
        order.metadata
        |> Map.put("last_midtrans_notification", payload)

      {:ok, order} =
        order
        |> Order.changeset(%{
          status: status,
          provider_transaction_id: transaction_id,
          paid_at: paid_at,
          fulfillment_status: fulfillment_status,
          fulfilled_at:
            if(fulfillment_status == "fulfilled", do: paid_at, else: order.fulfilled_at),
          metadata: metadata
        })
        |> Repo.update()

      %{order: order, notify_paid?: notify_paid?}
    end)
    |> case do
      {:ok, %{order: order, notify_paid?: true}} ->
        PaymentNotifier.notify_order_paid(order)
        {:ok, order}

      {:ok, %{order: order}} ->
        {:ok, order}

      other ->
        other
    end
  end

  defp create_checkout(attrs, url_opts) do
    raw_token = generate_token()
    provider_order_id = generate_provider_order_id(attrs.kind)

    Multi.new()
    |> Multi.insert(:order, fn _changes ->
      Order.changeset(%Order{}, %{
        kind: attrs.kind,
        status: "pending",
        provider:
          if(Midtrans.configured?() and attrs.prefer_midtrans?, do: "midtrans", else: "manual"),
        provider_order_id: provider_order_id,
        buyer_email: attrs.buyer_email,
        amount: attrs.amount,
        currency: attrs.currency,
        post_id: Map.get(attrs, :post_id),
        product_id: Map.get(attrs, :product_id),
        metadata: %{}
      })
    end)
    |> Multi.insert(:access_grant, fn %{order: order} ->
      AccessGrant.changeset(%AccessGrant{}, %{
        order_id: order.id,
        post_id: order.post_id,
        product_id: order.product_id,
        buyer_email: order.buyer_email,
        token_hash: hash_token(raw_token)
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{order: order, access_grant: access_grant}} ->
        prepare_redirect(
          order,
          access_grant,
          raw_token,
          attrs.fallback_checkout_url,
          attrs.prefer_midtrans?,
          url_opts
        )

      {:error, _step, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp prepare_redirect(
         order,
         access_grant,
         raw_token,
         fallback_checkout_url,
         prefer_midtrans?,
         url_opts
       ) do
    finish_url = finish_url(order, raw_token, url_opts)
    notification_url = Keyword.get(url_opts, :notification_url)

    cond do
      prefer_midtrans? and Midtrans.configured?() ->
        case Midtrans.create_snap_redirect(order,
               finish_url: finish_url,
               notification_url: notification_url
             ) do
          {:ok, %{redirect_url: redirect_url} = snap} ->
            update_order_checkout(order, redirect_url, snap)

            {:ok,
             %{
               order: order,
               access_grant: access_grant,
               access_token: raw_token,
               redirect_url: redirect_url
             }}

          {:error, reason} ->
            {:error, reason}
        end

      is_binary(fallback_checkout_url) and fallback_checkout_url != "" ->
        update_order_checkout(order, fallback_checkout_url, %{mode: "manual_link"})

        {:ok,
         %{
           order: order,
           access_grant: access_grant,
           access_token: raw_token,
           redirect_url: fallback_checkout_url
         }}

      true ->
        {:error, :payment_not_configured}
    end
  end

  defp update_order_checkout(order, checkout_url, provider_payload) do
    metadata =
      order.metadata
      |> Map.put("provider_payload", provider_payload)

    order
    |> Order.changeset(%{checkout_url: checkout_url, metadata: metadata})
    |> Repo.update()
  end

  defp finish_url(order, raw_token, url_opts) do
    base_url = Keyword.fetch!(url_opts, :success_url)

    query =
      URI.encode_query(%{
        order_id: order.provider_order_id,
        access_token: raw_token
      })

    separator = if String.contains?(base_url, "?"), do: "&", else: "?"
    base_url <> separator <> query
  end

  defp post_access_amount(%Post{access_type: "paid", price: %Decimal{} = price}, _attrs) do
    if Decimal.compare(price, Decimal.new("0")) == :gt do
      {:ok, price}
    else
      {:error, :invalid_price}
    end
  end

  defp post_access_amount(%Post{access_type: "tips", tip_amount_options: options}, attrs) do
    amount = Map.get(attrs, "tip_amount") || Map.get(attrs, :tip_amount)
    parsed_amount = parse_amount(amount)

    if parsed_amount && parsed_amount in options do
      {:ok, Decimal.new(parsed_amount)}
    else
      {:error, :invalid_tip_amount}
    end
  end

  defp post_access_amount(_post, _attrs), do: {:error, :not_paid_post}

  defp post_order_kind(%Post{access_type: "tips"}), do: "tip"
  defp post_order_kind(_post), do: "post_access"

  defp parse_amount(amount) when is_integer(amount), do: amount

  defp parse_amount(amount) when is_binary(amount) do
    case Integer.parse(amount) do
      {amount, ""} -> amount
      _invalid -> nil
    end
  end

  defp parse_amount(_amount), do: nil

  defp generate_provider_order_id(kind) do
    prefix =
      case kind do
        "post_access" -> "post"
        "tip" -> "tip"
        "product_purchase" -> "product"
      end

    "#{prefix}-#{System.system_time(:second)}-#{Base.url_encode64(:crypto.strong_rand_bytes(6), padding: false)}"
  end

  defp generate_token do
    @token_bytes
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  defp hash_token(token) do
    :crypto.hash(:sha256, token)
    |> Base.encode16(case: :lower)
  end
end
