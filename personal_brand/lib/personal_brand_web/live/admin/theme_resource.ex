defmodule PersonalBrandWeb.Admin.ThemeResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Theme,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Theme"

  @impl true
  def plural_name, do: "Themes"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      key: %{
        module: Backpex.Fields.Text,
        label: "Key"
      },
      name: %{
        module: Backpex.Fields.Text,
        label: "Name"
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description"
      },
      is_active: %{
        module: Backpex.Fields.Boolean,
        label: "Active"
      }
    ]
  end
end
