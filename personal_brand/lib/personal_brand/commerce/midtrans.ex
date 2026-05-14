defmodule PersonalBrand.Commerce.Midtrans do
  @moduledoc """
  Minimal Midtrans Snap Redirect and HTTP notification helpers.

  Secrets are read from runtime env config, never from CMS data.
  """

  alias PersonalBrand.Commerce.Order

  @sandbox_url "https://app.sandbox.midtrans.com/snap/v1/transactions"
  @production_url "https://app.midtrans.com/snap/v1/transactions"

  def configured? do
    server_key() not in [nil, ""]
  end

  def create_snap_redirect(%Order{} = order, opts \\ []) do
    with {:ok, server_key} <- fetch_server_key(),
         {:ok, body} <- encode_body(order, opts),
         {:ok, response_body} <- post_snap(server_key, body),
         {:ok, response} <- Jason.decode(response_body),
         {:ok, redirect_url} <- fetch_redirect_url(response) do
      {:ok, %{redirect_url: redirect_url, token: response["token"], raw_response: response}}
    end
  end

  def signature_valid?(payload) when is_map(payload) do
    with {:ok, server_key} <- fetch_server_key(),
         order_id when is_binary(order_id) <- payload["order_id"],
         status_code when is_binary(status_code) <- payload["status_code"],
         gross_amount when is_binary(gross_amount) <- payload["gross_amount"],
         signature_key when is_binary(signature_key) <- payload["signature_key"] do
      expected =
        :crypto.hash(:sha512, order_id <> status_code <> gross_amount <> server_key)
        |> Base.encode16(case: :lower)

      Plug.Crypto.secure_compare(expected, signature_key)
    else
      _ -> false
    end
  end

  def payment_status(payload) do
    transaction_status = payload["transaction_status"]
    fraud_status = payload["fraud_status"]

    cond do
      transaction_status == "settlement" -> "paid"
      transaction_status == "capture" and fraud_status in [nil, "accept"] -> "paid"
      transaction_status == "pending" -> "pending"
      transaction_status in ["deny", "cancel", "failure"] -> "failed"
      transaction_status == "expire" -> "expired"
      transaction_status in ["refund", "partial_refund"] -> "refunded"
      true -> "pending"
    end
  end

  defp fetch_server_key do
    case server_key() do
      nil -> {:error, :missing_server_key}
      "" -> {:error, :missing_server_key}
      value -> {:ok, value}
    end
  end

  defp server_key do
    :personal_brand
    |> Application.get_env(:midtrans, [])
    |> Keyword.get(:server_key)
  end

  defp encode_body(order, opts) do
    finish_url = Keyword.fetch!(opts, :finish_url)
    notification_url = Keyword.get(opts, :notification_url)

    body = %{
      transaction_details: %{
        order_id: order.provider_order_id,
        gross_amount: order.amount |> Decimal.round(0) |> Decimal.to_integer()
      },
      customer_details: %{
        email: order.buyer_email
      },
      item_details: [
        %{
          id: order.kind,
          price: order.amount |> Decimal.round(0) |> Decimal.to_integer(),
          quantity: 1,
          name: order_label(order)
        }
      ],
      callbacks: %{
        finish: finish_url
      }
    }

    body =
      if notification_url do
        Map.put(body, :notification_url, notification_url)
      else
        body
      end

    Jason.encode(body)
  end

  defp post_snap(server_key, body) do
    :inets.start()
    :ssl.start()

    headers = [
      {~c"Authorization", ~c"Basic " ++ String.to_charlist(Base.encode64(server_key <> ":"))},
      {~c"Accept", ~c"application/json"}
    ]

    request = {to_charlist(snap_url()), headers, ~c"application/json", body}

    case :httpc.request(:post, request, [], body_format: :binary) do
      {:ok, {{_, status, _}, _headers, response_body}} when status in 200..299 ->
        {:ok, response_body}

      {:ok, {{_, status, _}, _headers, response_body}} ->
        {:error, {:midtrans_http_error, status, response_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp snap_url do
    case Application.get_env(:personal_brand, :midtrans, [])[:environment] do
      "production" -> @production_url
      _environment -> @sandbox_url
    end
  end

  defp fetch_redirect_url(%{"redirect_url" => redirect_url}) when is_binary(redirect_url),
    do: {:ok, redirect_url}

  defp fetch_redirect_url(_response), do: {:error, :missing_redirect_url}

  defp order_label(%Order{kind: "post_access"}), do: "Paid writing access"
  defp order_label(%Order{kind: "tip"}), do: "Writing support tip"
  defp order_label(%Order{kind: "product_purchase"}), do: "Product purchase"
end
