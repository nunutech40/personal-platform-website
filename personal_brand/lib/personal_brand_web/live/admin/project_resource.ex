defmodule PersonalBrandWeb.Admin.ProjectResource do
  use PersonalBrandWeb, :html

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
        rows: 3,
        index_column_class: "min-w-80"
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description",
        rows: 8,
        except: [:index]
      },
      problem: %{
        module: Backpex.Fields.Textarea,
        label: "Problem",
        rows: 5,
        except: [:index]
      },
      solution: %{
        module: Backpex.Fields.Textarea,
        label: "Solution",
        rows: 5,
        except: [:index]
      },
      result: %{
        module: Backpex.Fields.Textarea,
        label: "Results (one per line)",
        rows: 6,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index]
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Role"
      },
      tech_stack: %{
        module: Backpex.Fields.Textarea,
        label: "Tech Stack (one per line)",
        rows: 4,
        render: &render_list/1,
        render_form: &render_textarea/1
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
      },
      cover_image_id: %{
        module: Backpex.Fields.Text,
        label: "Cover Media ID",
        help_text: "Copy the media UUID from Admin > Media after uploading a cover image.",
        except: [:index]
      }
    ]
  end

  defp render_list(assigns) do
    assigns = assign(assigns, :display_value, display_value(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp render_textarea(assigns) do
    assigns =
      assign(assigns, :textarea_value, textarea_value(assigns[:value]))

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>
      <textarea
        id={@form[@name].id}
        name={@form[@name].name}
        rows={@field_options[:rows] || 4}
        class="textarea w-full"
      >{@textarea_value}</textarea>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp display_value(value) when is_list(value) and value != [], do: Enum.join(value, ", ")
  defp display_value(value) when is_binary(value), do: value
  defp display_value(_value), do: "-"
end
