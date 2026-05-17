defmodule PersonalBrand.Commerce.PaymentNotifier do
  @moduledoc """
  Sends owner-facing notifications for paid commerce orders.
  """

  require Logger

  import Swoosh.Email

  alias PersonalBrand.Commerce.Order
  alias PersonalBrand.Mailer
  alias PersonalBrand.Repo

  def notify_order_paid(%Order{} = order) do
    order = Repo.preload(order, [:post, :product])

    if mailer_configured?() do
      order
      |> paid_order_email()
      |> Mailer.deliver()
      |> case do
        {:ok, _metadata} ->
          :ok

        {:error, reason} ->
          Logger.error("Failed to send paid order notification: #{inspect(reason)}")
          {:error, reason}
      end
    else
      Logger.warning("Skipping paid order notification because SMTP is not configured")
      {:error, :mailer_not_configured}
    end
  end

  defp mailer_configured? do
    config = Application.get_env(:personal_brand, Mailer, [])

    case Keyword.get(config, :adapter) do
      Swoosh.Adapters.SMTP -> present?(Keyword.get(config, :relay))
      nil -> false
      _other_adapter -> true
    end
  end

  defp paid_order_email(order) do
    config = Application.get_env(:personal_brand, :payment_notifications, [])
    to = Keyword.fetch!(config, :to)
    from = Keyword.fetch!(config, :from)

    new()
    |> to(to)
    |> from(from)
    |> subject("[Personal Brand] Pembayaran masuk - #{order_label(order)}")
    |> text_body(text_body(order))
  end

  defp text_body(order) do
    """
    Ada pembayaran masuk di Personal Brand Platform.

    Tipe order: #{order.kind}
    Item: #{order_label(order)}
    Buyer email: #{order.buyer_email}
    Amount: #{order.currency} #{Decimal.to_string(order.amount, :normal)}
    Provider: #{order.provider}
    Provider order ID: #{order.provider_order_id}
    Provider transaction ID: #{order.provider_transaction_id || "-"}
    Paid at: #{format_datetime(order.paid_at)}

    Cek detailnya di Midtrans dashboard dan /admin/orders.
    """
  end

  defp order_label(%Order{post: %{title: title}}) when is_binary(title), do: title
  defp order_label(%Order{product: %{title: title}}) when is_binary(title), do: title
  defp order_label(%Order{kind: kind}), do: kind

  defp format_datetime(nil), do: "-"
  defp format_datetime(datetime), do: DateTime.to_iso8601(datetime)

  defp present?(value), do: is_binary(value) and String.trim(value) != ""
end
