defmodule PersonalBrandWeb.Admin.ProjectResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Project

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Project,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &Project.changeset/3
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
        label: "Title",
        searchable: true
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug",
        help_text:
          "Leave blank on create to auto-generate. Be careful changing a published slug because public links depend on it."
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
      architecture_notes: %{
        module: Backpex.Fields.Textarea,
        label: "Architecture Notes",
        rows: 6,
        except: [:index]
      },
      tradeoffs: %{
        module: Backpex.Fields.Textarea,
        label: "Trade-offs",
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
        label: "Role",
        searchable: true
      },
      ownership: %{
        module: Backpex.Fields.Text,
        label: "Ownership",
        except: [:index]
      },
      project_type: %{
        module: Backpex.Fields.Select,
        label: "Project Type",
        options: select_options(Project.project_types()),
        render: &render_label/1
      },
      platforms: %{
        module: Backpex.Fields.Textarea,
        label: "Platforms (one per line)",
        rows: 4,
        help_text: "Allowed: #{Enum.join(Project.platforms(), ", ")}",
        render: &render_badges/1,
        render_form: &render_textarea/1
      },
      disciplines: %{
        module: Backpex.Fields.Textarea,
        label: "Disciplines (one per line)",
        rows: 5,
        help_text: "Allowed: #{Enum.join(Project.disciplines(), ", ")}",
        render: &render_badges/1,
        render_form: &render_textarea/1
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
      duration: %{
        module: Backpex.Fields.Text,
        label: "Duration"
      },
      company: %{
        module: Backpex.Fields.Text,
        label: "Company",
        except: [:index]
      },
      client: %{
        module: Backpex.Fields.Text,
        label: "Client",
        except: [:index]
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: select_options(Project.statuses())
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Featured"
      },
      sort_order: %{
        module: Backpex.Fields.Number,
        label: "Sort Order"
      },
      impact_summary: %{
        module: Backpex.Fields.Textarea,
        label: "Impact Summary",
        rows: 3,
        except: [:index]
      },
      technical_highlights: %{
        module: Backpex.Fields.Textarea,
        label: "Technical Highlights (one per line)",
        rows: 6,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index]
      },
      metrics: %{
        module: Backpex.Fields.Textarea,
        label: "Metrics (one per line)",
        rows: 5,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index]
      },
      case_study_visibility: %{
        module: Backpex.Fields.Select,
        label: "Case Study Visibility",
        options: select_options(Project.case_study_visibilities()),
        render: &render_label/1
      },
      demo_url: %{
        module: Backpex.Fields.Text,
        label: "Demo URL"
      },
      github_url: %{
        module: Backpex.Fields.Text,
        label: "GitHub URL"
      },
      app_store_url: %{
        module: Backpex.Fields.Text,
        label: "App Store URL"
      },
      cover_image: %{
        module: Backpex.Fields.BelongsTo,
        label: "Cover Image",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Choose cover image",
        help_text: "Upload media first in Admin > Media, then select it here.",
        except: [:index]
      }
    ]
  end

  def create_changeset(project, attrs, metadata) do
    project
    |> Project.changeset(Content.put_unique_project_slug(attrs), metadata)
  end

  defp select_options(values), do: Enum.map(values, &{Project.label_for(&1), &1})

  defp render_label(assigns) do
    assigns = assign(assigns, :display_value, display_label(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp render_badges(assigns) do
    assigns = assign(assigns, :values, list_value(assigns[:value]))

    ~H"""
    <div class="flex max-w-80 flex-wrap gap-1">
      <span :for={value <- @values} class="badge badge-outline badge-sm">
        {display_label(value)}
      </span>
      <span :if={@values == []}>-</span>
    </div>
    """
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

  defp list_value(value) when is_list(value), do: value
  defp list_value(value) when is_binary(value) and value != "", do: [value]
  defp list_value(_value), do: []

  defp display_label(value) when is_binary(value), do: Project.label_for(value)
  defp display_label(_value), do: "-"

  defp display_value(value) when is_list(value) and value != [], do: Enum.join(value, ", ")
  defp display_value(value) when is_binary(value), do: value
  defp display_value(_value), do: "-"
end
