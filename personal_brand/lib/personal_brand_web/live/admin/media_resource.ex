defmodule PersonalBrandWeb.Admin.MediaResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Media,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Media"

  @impl true
  def plural_name, do: "Media"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      filename: %{
        module: Backpex.Fields.Text,
        label: "Filename"
      },
      content_type: %{
        module: Backpex.Fields.Text,
        label: "Content Type"
      },
      size: %{
        module: Backpex.Fields.Number,
        label: "Size (bytes)"
      },
      url: %{
        module: Backpex.Fields.Text,
        label: "URL"
      },
      alt_text: %{
        module: Backpex.Fields.Text,
        label: "Alt Text"
      }
    ]
  end
end
