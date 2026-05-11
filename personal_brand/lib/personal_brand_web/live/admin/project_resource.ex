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
  def panels do
    [
      identity: "Identity",
      classification: "Classification",
      recruiter_pitch: "Recruiter Pitch",
      case_study: "Case Study",
      evidence: "Evidence",
      media_links: "Media & Links"
    ]
  end

  @impl true
  def filters do
    [
      status: %{
        module: PersonalBrandWeb.Admin.Filters.ProjectStatus
      },
      featured: %{
        module: PersonalBrandWeb.Admin.Filters.ProjectFeatured
      }
    ]
  end

  @impl true
  def item_actions(default_actions) do
    default_actions
    |> Keyword.put(:edit, %{
      module: PersonalBrandWeb.Admin.ItemActions.EditProject,
      only: [:row, :show]
    })
    |> Keyword.put(:view_public, %{
      module: PersonalBrandWeb.Admin.ItemActions.ViewPublicProject,
      only: [:row, :show]
    })
  end

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
        searchable: true,
        panel: :identity
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug",
        help_text:
          "Leave blank on create to auto-generate. Be careful changing a published slug because public links depend on it.",
        panel: :identity
      },
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Summary",
        rows: 3,
        index_column_class: "min-w-80",
        panel: :recruiter_pitch
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description",
        rows: 8,
        except: [:index],
        panel: :case_study
      },
      problem: %{
        module: Backpex.Fields.Textarea,
        label: "Problem",
        rows: 5,
        except: [:index],
        panel: :case_study
      },
      solution: %{
        module: Backpex.Fields.Textarea,
        label: "Solution",
        rows: 5,
        except: [:index],
        panel: :case_study
      },
      architecture_notes: %{
        module: Backpex.Fields.Textarea,
        label: "Architecture Notes",
        rows: 6,
        except: [:index],
        panel: :case_study
      },
      tradeoffs: %{
        module: Backpex.Fields.Textarea,
        label: "Trade-offs",
        rows: 5,
        except: [:index],
        panel: :case_study
      },
      result: %{
        module: Backpex.Fields.Textarea,
        label: "Results (one per line)",
        rows: 6,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Role",
        searchable: true,
        panel: :classification
      },
      ownership: %{
        module: Backpex.Fields.Text,
        label: "Ownership",
        except: [:index],
        panel: :classification
      },
      team_size: %{
        module: Backpex.Fields.Text,
        label: "Team Size",
        except: [:index],
        panel: :classification
      },
      project_type: %{
        module: Backpex.Fields.Select,
        label: "Project Type",
        options: select_options(Project.project_types()),
        render: &render_label/1,
        panel: :classification
      },
      platforms: %{
        module: Backpex.Fields.Textarea,
        label: "Platforms (one per line)",
        rows: 4,
        help_text: "Allowed: #{Enum.join(Project.platforms(), ", ")}",
        render: &render_badges/1,
        render_form: &render_textarea/1,
        index_column_class: "min-w-40",
        panel: :classification
      },
      disciplines: %{
        module: Backpex.Fields.Textarea,
        label: "Disciplines (one per line)",
        rows: 5,
        help_text: "Allowed: #{Enum.join(Project.disciplines(), ", ")}",
        render: &render_badges/1,
        render_form: &render_textarea/1,
        index_column_class: "min-w-48",
        panel: :classification
      },
      tech_stack: %{
        module: Backpex.Fields.Textarea,
        label: "Tech Stack (one per line)",
        rows: 4,
        render: &render_list/1,
        render_form: &render_textarea/1,
        panel: :evidence
      },
      year: %{
        module: Backpex.Fields.Text,
        label: "Year",
        panel: :identity
      },
      duration: %{
        module: Backpex.Fields.Text,
        label: "Duration",
        panel: :identity
      },
      company: %{
        module: Backpex.Fields.Text,
        label: "Company",
        except: [:index],
        panel: :classification
      },
      client: %{
        module: Backpex.Fields.Text,
        label: "Client",
        except: [:index],
        panel: :classification
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: select_options(Project.statuses()),
        render: &render_status_badge/1,
        panel: :identity
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Featured",
        render: &render_featured_badge/1,
        panel: :identity
      },
      sort_order: %{
        module: Backpex.Fields.Number,
        label: "Sort Order",
        index_column_class: "w-24",
        help_text: "Lower numbers appear first. 0 = highest priority.",
        panel: :identity
      },
      impact_summary: %{
        module: Backpex.Fields.Textarea,
        label: "Impact Summary",
        rows: 3,
        except: [:index],
        panel: :recruiter_pitch
      },
      technical_highlights: %{
        module: Backpex.Fields.Textarea,
        label: "Technical Highlights (one per line)",
        rows: 6,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      metrics: %{
        module: Backpex.Fields.Textarea,
        label: "Metrics (one per line)",
        rows: 5,
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      case_study_visibility: %{
        module: Backpex.Fields.Select,
        label: "Case Study Visibility",
        options: select_options(Project.case_study_visibilities()),
        render: &render_label/1,
        panel: :case_study
      },
      demo_url: %{
        module: Backpex.Fields.Text,
        label: "Demo URL",
        panel: :media_links
      },
      github_url: %{
        module: Backpex.Fields.Text,
        label: "GitHub URL",
        panel: :media_links
      },
      app_store_url: %{
        module: Backpex.Fields.Text,
        label: "App Store URL",
        panel: :media_links
      },
      cover_image: %{
        module: Backpex.Fields.BelongsTo,
        label: "Cover Image",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Choose cover image",
        help_text: "Upload media first in Admin > Media, then select it here.",
        except: [:index],
        panel: :media_links
      },
      updated_at: %{
        module: Backpex.Fields.DateTime,
        label: "Updated",
        except: [:new, :edit],
        orderable: true
      }
    ]
  end

  @impl true
  def render_resource_slot(
        %{item: %{status: "published", slug: slug}} = assigns,
        :edit,
        :before_main
      ) do
    assigns = assign(assigns, :public_path, "/work/#{slug}")

    ~H"""
    <div class="alert alert-warning mb-4">
      <div>
        <p class="font-semibold">Published project URL: <a href={@public_path}>{@public_path}</a></p>
        <p class="text-sm">
          Changing the slug will change this public case study URL, so only edit it intentionally.
        </p>
      </div>
    </div>
    """
  end

  def render_resource_slot(assigns, :new, :before_main) do
    ~H"""
    <div class="alert alert-info mb-4">
      <p>
        Fill the title first. Slug can stay blank because the system will generate a unique public URL automatically.
      </p>
    </div>
    """
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

  defp render_status_badge(assigns) do
    assigns = assign(assigns, :display_value, display_label(assigns[:value]))

    status_class =
      case assigns[:value] do
        "published" -> "badge badge-success badge-sm"
        "draft" -> "badge badge-warning badge-sm"
        "archived" -> "badge badge-ghost badge-sm"
        _ -> "badge badge-outline badge-sm"
      end

    assigns = assign(assigns, :status_class, status_class)

    ~H"""
    <span class={@status_class}>{@display_value}</span>
    """
  end

  defp render_featured_badge(assigns) do
    ~H"""
    <span>
      <span :if={@value} class="badge badge-primary badge-sm">Featured</span>
      <span :if={!@value} class="text-slate-400">-</span>
    </span>
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
