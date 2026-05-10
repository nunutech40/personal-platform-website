defmodule PersonalBrandWeb.Admin.SiteSettingResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.SiteSetting,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Site Setting"

  @impl true
  def plural_name, do: "Site Settings"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      site_name: %{
        module: Backpex.Fields.Text,
        label: "Site Name"
      },
      headline: %{
        module: Backpex.Fields.Textarea,
        label: "Headline"
      },
      subheadline: %{
        module: Backpex.Fields.Textarea,
        label: "Subheadline"
      },
      primary_cta_text: %{
        module: Backpex.Fields.Text,
        label: "Primary CTA Text"
      },
      primary_cta_url: %{
        module: Backpex.Fields.Text,
        label: "Primary CTA URL"
      },
      secondary_cta_text: %{
        module: Backpex.Fields.Text,
        label: "Secondary CTA Text"
      },
      secondary_cta_url: %{
        module: Backpex.Fields.Text,
        label: "Secondary CTA URL"
      },
      active_theme: %{
        module: Backpex.Fields.Text,
        label: "Active Theme"
      },
      profile_name: %{
        module: Backpex.Fields.Text,
        label: "Profile Name"
      },
      profile_title: %{
        module: Backpex.Fields.Text,
        label: "Profile Title"
      },
      profile_location: %{
        module: Backpex.Fields.Text,
        label: "Location"
      },
      profile_email: %{
        module: Backpex.Fields.Text,
        label: "Email"
      },
      profile_bio: %{
        module: Backpex.Fields.Textarea,
        label: "Bio"
      }
    ]
  end
end
