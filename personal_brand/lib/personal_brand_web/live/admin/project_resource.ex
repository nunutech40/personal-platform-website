defmodule PersonalBrandWeb.Admin.ProjectResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Project,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Project"

  @impl true
  def plural_name, do: "Projects"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      title: %{
        module: Backpex.Fields.Text,
        label: "Title"
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug"
      },
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Summary",
        rows: 3
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description",
        rows: 8
      },
      problem: %{
        module: Backpex.Fields.Textarea,
        label: "Problem",
        rows: 5
      },
      solution: %{
        module: Backpex.Fields.Textarea,
        label: "Solution",
        rows: 5
      },
      result: %{
        module: Backpex.Fields.Text,
        label: "Results (one per line)"
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Role"
      },
      tech_stack: %{
        module: Backpex.Fields.Text,
        label: "Tech Stack (comma separated)"
      },
      year: %{
        module: Backpex.Fields.Text,
        label: "Year"
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [{"Draft", "draft"}, {"Published", "published"}, {"Archived", "archived"}]
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Featured"
      },
      demo_url: %{
        module: Backpex.Fields.Text,
        label: "Demo URL"
      },
      github_url: %{
        module: Backpex.Fields.Text,
        label: "GitHub URL"
      }
    ]
  end
end
