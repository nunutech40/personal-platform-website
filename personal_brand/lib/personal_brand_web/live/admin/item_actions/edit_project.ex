defmodule PersonalBrandWeb.Admin.ItemActions.EditProject do
  @moduledoc """
  Visible row action for editing a project from the admin index.
  """

  use BackpexWeb, :item_action

  alias Backpex.Router

  @impl Backpex.ItemAction
  def icon(assigns, _item) do
    ~H"""
    <span class="inline-flex items-center gap-1 rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50">
      <Backpex.HTML.CoreComponents.icon name="hero-pencil-square" class="h-4 w-4" /> Edit
    </span>
    """
  end

  @impl Backpex.ItemAction
  def label(_assigns, _item), do: "Edit"

  @impl Backpex.ItemAction
  def link(assigns, item) do
    query_params =
      case Map.get(assigns, :return_to) do
        nil -> %{}
        return_to -> %{return_to: return_to}
      end

    Router.get_path(
      assigns.socket,
      assigns.live_resource,
      assigns.params,
      :edit,
      item,
      query_params
    )
  end
end
