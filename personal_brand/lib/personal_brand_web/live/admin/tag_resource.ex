defmodule PersonalBrandWeb.Admin.TagResource do
  use PersonalBrandWeb, :html

  alias PersonalBrandWeb.Admin.ResourceUI

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Tag,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Tag"

  @impl true
  def plural_name, do: "Tags"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def item_actions(default_actions),
    do: ResourceUI.item_actions_without_bulk_delete(default_actions)

  @impl true
  def render_resource_slot(assigns, :index, :main) do
    ~H"""
    <ResourceUI.index_main {assigns} />
    """
  end

  @impl true
  def fields do
    [
      name: %{
        module: Backpex.Fields.Text,
        label: "Name"
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug"
      }
    ]
  end
end
