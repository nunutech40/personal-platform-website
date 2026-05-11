defmodule PersonalBrandWeb.Admin.ItemActions.ViewPublicProject do
  @moduledoc """
  Row action for opening a project's public case study.
  """

  use BackpexWeb, :item_action

  @impl Backpex.ItemAction
  def icon(assigns, _item) do
    ~H"""
    <Backpex.HTML.CoreComponents.icon
      name="hero-arrow-top-right-on-square"
      class="h-5 w-5 cursor-pointer transition duration-75 hover:scale-110 hover:text-info"
    />
    """
  end

  @impl Backpex.ItemAction
  def label(_assigns, _item), do: "View public"

  @impl Backpex.ItemAction
  def link(_assigns, item), do: "/work/#{item.slug}"
end
