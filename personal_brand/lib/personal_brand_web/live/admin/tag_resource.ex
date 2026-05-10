defmodule PersonalBrandWeb.Admin.TagResource do
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
