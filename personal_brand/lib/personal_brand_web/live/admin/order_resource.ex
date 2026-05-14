defmodule PersonalBrandWeb.Admin.OrderResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Commerce.Order
  alias PersonalBrandWeb.Admin.ResourceUI

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Order,
      repo: PersonalBrand.Repo,
      update_changeset: &__MODULE__.update_changeset/3
    ],
    init_order: %{by: :inserted_at, direction: :desc}

  @impl true
  def singular_name, do: "Order"

  @impl true
  def plural_name, do: "Orders"

  @impl true
  def panels do
    [
      payment: "Payment",
      buyer: "Buyer",
      content: "Content",
      provider: "Provider"
    ]
  end

  @impl true
  def item_actions(default_actions) do
    default_actions
    |> Keyword.delete(:new)
    |> Keyword.delete(:edit)
    |> Keyword.delete(:delete)
  end

  @impl true
  def can?(_assigns, action, _item) when action in [:new, :edit, :delete], do: false
  def can?(_assigns, _action, _item), do: true

  @impl true
  def layout(_assigns), do: {PersonalBrandWeb.Layouts, :admin}

  @impl true
  def render_resource_slot(assigns, :index, :main) do
    ~H"""
    <ResourceUI.index_main {assigns} />
    """
  end

  @impl true
  def fields do
    [
      kind: %{
        module: Backpex.Fields.Select,
        label: "Kind",
        options: [
          {"Post Access", "post_access"},
          {"Tip", "tip"},
          {"Product Purchase", "product_purchase"}
        ],
        panel: :payment
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [
          {"Pending", "pending"},
          {"Paid", "paid"},
          {"Failed", "failed"},
          {"Expired", "expired"},
          {"Refunded", "refunded"}
        ],
        render: &render_status_badge/1,
        panel: :payment
      },
      amount: %{
        module: Backpex.Fields.Number,
        label: "Amount",
        panel: :payment
      },
      fulfillment_status: %{
        module: Backpex.Fields.Select,
        label: "Fulfillment",
        options: [
          {"Unfulfilled", "unfulfilled"},
          {"Fulfilled", "fulfilled"},
          {"Not Required", "not_required"}
        ],
        render: &render_fulfillment_badge/1,
        panel: :payment
      },
      currency: %{
        module: Backpex.Fields.Text,
        label: "Currency",
        panel: :payment
      },
      buyer_email: %{
        module: Backpex.Fields.Text,
        label: "Buyer Email",
        searchable: true,
        panel: :buyer
      },
      post_id: %{
        module: Backpex.Fields.Text,
        label: "Post ID",
        except: [:index],
        panel: :content
      },
      product_id: %{
        module: Backpex.Fields.Text,
        label: "Product ID",
        except: [:index],
        panel: :content
      },
      provider: %{
        module: Backpex.Fields.Text,
        label: "Provider",
        panel: :provider
      },
      provider_order_id: %{
        module: Backpex.Fields.Text,
        label: "Provider Order ID",
        searchable: true,
        panel: :provider
      },
      provider_transaction_id: %{
        module: Backpex.Fields.Text,
        label: "Provider Transaction ID",
        except: [:index],
        panel: :provider
      },
      checkout_url: %{
        module: Backpex.Fields.Text,
        label: "Checkout URL",
        except: [:index],
        panel: :provider
      },
      paid_at: %{
        module: Backpex.Fields.DateTime,
        label: "Paid At",
        panel: :payment
      },
      fulfilled_at: %{
        module: Backpex.Fields.DateTime,
        label: "Fulfilled At",
        except: [:index],
        panel: :payment
      },
      inserted_at: %{
        module: Backpex.Fields.DateTime,
        label: "Created",
        orderable: true,
        panel: :payment
      }
    ]
  end

  def update_changeset(order, attrs, _metadata), do: Order.changeset(order, attrs)

  defp render_status_badge(assigns) do
    status_class =
      case assigns[:value] do
        "paid" -> "badge badge-success badge-sm"
        "pending" -> "badge badge-warning badge-sm"
        "failed" -> "badge badge-error badge-sm"
        "expired" -> "badge badge-ghost badge-sm"
        "refunded" -> "badge badge-info badge-sm"
        _status -> "badge badge-outline badge-sm"
      end

    assigns = assign(assigns, :status_class, status_class)

    ~H"""
    <span class={@status_class}>{@value}</span>
    """
  end

  defp render_fulfillment_badge(assigns) do
    status_class =
      case assigns[:value] do
        "fulfilled" -> "badge badge-success badge-sm"
        "unfulfilled" -> "badge badge-warning badge-sm"
        "not_required" -> "badge badge-ghost badge-sm"
        _status -> "badge badge-outline badge-sm"
      end

    assigns = assign(assigns, :status_class, status_class)

    ~H"""
    <span class={@status_class}>{@value}</span>
    """
  end
end
