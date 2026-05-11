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
  def item_actions(default_actions) do
    default_actions
    |> Keyword.put(:show, %{
      module: Backpex.ItemActions.Show,
      only: [:show]
    })
    |> Keyword.put(:edit, %{
      module: PersonalBrandWeb.Admin.ItemActions.EditProject,
      only: [:show]
    })
    |> Keyword.put(:view_public, %{
      module: PersonalBrandWeb.Admin.ItemActions.ViewPublicProject,
      only: [:show]
    })
    |> Keyword.put(:delete, %{
      module: Backpex.ItemActions.Delete,
      only: [:show]
    })
  end

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      admin_actions: %{
        module: Backpex.Fields.Text,
        label: "Actions",
        only: [:index],
        render: &render_admin_actions/1,
        index_column_class: "min-w-64"
      },
      title: %{
        module: Backpex.Fields.Text,
        label: "Title",
        placeholder: "Personal Platform Website",
        searchable: true,
        panel: :identity
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug",
        placeholder: "personal-platform-website",
        help_text:
          "Leave blank on create to auto-generate. Be careful changing a published slug because public links depend on it.",
        panel: :identity
      },
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Summary",
        rows: 3,
        placeholder:
          "Platform personal berbasis Phoenix LiveView untuk portfolio, writing, product catalog, dan admin CMS.",
        index_column_class: "min-w-80",
        panel: :recruiter_pitch
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description",
        rows: 8,
        placeholder:
          "Jelaskan konteks project, siapa user-nya, scope pekerjaan, dan kenapa project ini penting untuk portfolio recruiter.",
        except: [:index],
        panel: :case_study
      },
      problem: %{
        module: Backpex.Fields.Textarea,
        label: "Problem",
        rows: 5,
        placeholder:
          "Portfolio sebelumnya sulit di-update, data tersebar, dan recruiter tidak cepat melihat role, impact, serta technical depth.",
        except: [:index],
        panel: :case_study
      },
      solution: %{
        module: Backpex.Fields.Textarea,
        label: "Solution",
        rows: 5,
        placeholder:
          "Membangun Phoenix LiveView CMS dengan PostgreSQL, Backpex admin, auto slug, taxonomy project, dan halaman case study publik.",
        except: [:index],
        panel: :case_study
      },
      architecture_notes: %{
        module: Backpex.Fields.Textarea,
        label: "Architecture Notes",
        rows: 6,
        placeholder:
          "Content context mengatur query published/draft. Public route membaca project by slug. Admin memakai Backpex resource dan Ecto changeset.",
        except: [:index],
        panel: :case_study
      },
      tradeoffs: %{
        module: Backpex.Fields.Textarea,
        label: "Trade-offs",
        rows: 5,
        placeholder:
          "Taxonomy memakai enum-array dulu agar cepat ship; taxonomy table dan gallery media bisa ditambahkan saat kebutuhan admin makin kompleks.",
        except: [:index],
        panel: :case_study
      },
      result: %{
        module: Backpex.Fields.Textarea,
        label: "Results (one per line)",
        rows: 6,
        placeholder:
          "Recruiter bisa scan project lebih cepat\nAdmin bisa create/edit project tanpa raw database access\nPublic case study bisa dibuka lewat /work/:slug",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Role",
        placeholder: "Full-stack Engineer / Mobile Engineering Lead",
        render_form: &render_suggested_text_input/1,
        searchable: true,
        panel: :classification
      },
      ownership: %{
        module: Backpex.Fields.Text,
        label: "Ownership",
        placeholder:
          "Solo builder end-to-end: schema, admin CMS, public UI, tests, deployment workflow",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      team_size: %{
        module: Backpex.Fields.Text,
        label: "Team Size",
        placeholder: "Solo / 2 iOS engineers / Cross-functional team of 6",
        render_form: &render_suggested_text_input/1,
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
        module: Backpex.Fields.MultiSelect,
        label: "Platforms",
        options: fn _assigns -> taxonomy_options(:platforms, Project.platforms()) end,
        prompt: "Choose existing platforms",
        help_text: "Choose from existing/allowed platform keys to avoid duplicate spelling.",
        render: &render_badges/1,
        index_column_class: "min-w-40",
        panel: :classification
      },
      disciplines: %{
        module: Backpex.Fields.MultiSelect,
        label: "Disciplines",
        options: fn _assigns -> taxonomy_options(:disciplines, Project.disciplines()) end,
        prompt: "Choose existing disciplines",
        help_text: "Choose from existing/allowed discipline keys to avoid duplicate spelling.",
        render: &render_badges/1,
        index_column_class: "min-w-48",
        panel: :classification
      },
      tech_stack: %{
        module: Backpex.Fields.Textarea,
        label: "Tech Stack (one per line)",
        rows: 4,
        placeholder: "Elixir\nPhoenix LiveView\nPostgreSQL\nBackpex",
        render: &render_list/1,
        render_form: &render_textarea/1,
        panel: :evidence
      },
      year: %{
        module: Backpex.Fields.Text,
        label: "Year",
        placeholder: "2026",
        panel: :identity
      },
      duration: %{
        module: Backpex.Fields.Text,
        label: "Duration",
        placeholder: "Jan 2026 - May 2026 / 3 months",
        panel: :identity
      },
      company: %{
        module: Backpex.Fields.Text,
        label: "Company",
        placeholder: "Personal Project / Komerce / Prodia",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      client: %{
        module: Backpex.Fields.Text,
        label: "Client",
        placeholder: "Internal portfolio / Confidential client / Public users",
        render_form: &render_suggested_text_input/1,
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
        label: "Featured on homepage/work",
        help_text: "Turn on for projects that should be highlighted before regular projects.",
        render: &render_featured_badge/1,
        render_form: &render_featured_toggle/1,
        panel: :identity
      },
      sort_order: %{
        module: Backpex.Fields.Number,
        label: "Sort Order (lower appears first)",
        placeholder: "0",
        index_column_class: "w-24",
        help_text: "Use 0 for the most important project, then 10, 20, 30 for the next projects.",
        panel: :identity
      },
      impact_summary: %{
        module: Backpex.Fields.Textarea,
        label: "Impact Summary",
        rows: 3,
        placeholder:
          "Mengubah portfolio dari halaman statis menjadi CMS yang bisa cepat di-update untuk kebutuhan melamar kerja.",
        except: [:index],
        panel: :recruiter_pitch
      },
      technical_highlights: %{
        module: Backpex.Fields.Textarea,
        label: "Technical Highlights (one per line)",
        rows: 6,
        placeholder:
          "Auto-generated unique slug\nAdmin CRUD dengan Backpex\nPublic filtering by platform/discipline\nTests untuk create/edit/detail visibility",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      metrics: %{
        module: Backpex.Fields.Textarea,
        label: "Metrics (one per line)",
        rows: 5,
        placeholder:
          "169 automated tests passing\n5 recruiter-ready projects published\nAdmin create/edit workflow covered by tests",
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
        placeholder: "https://nununugraha.dev/work/personal-platform-website",
        panel: :media_links
      },
      github_url: %{
        module: Backpex.Fields.Text,
        label: "GitHub URL",
        placeholder: "https://github.com/nunutech40/personal-platform-website",
        panel: :media_links
      },
      app_store_url: %{
        module: Backpex.Fields.Text,
        label: "App Store URL",
        placeholder: "https://apps.apple.com/app/example/id123456789",
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

  defp taxonomy_options(field, allowed_values) do
    existing_values =
      field
      |> Content.list_project_array_values()
      |> Enum.filter(&(&1 in allowed_values))

    (existing_values ++ allowed_values)
    |> Enum.uniq()
    |> Enum.map(&{Project.label_for(&1), &1})
  end

  defp suggested_project_values(field, fallback_values) do
    field
    |> Content.list_project_field_values()
    |> Kernel.++(fallback_values)
    |> Enum.reject(&(is_nil(&1) or String.trim(&1) == ""))
    |> Enum.uniq()
  end

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

  defp render_admin_actions(assigns) do
    assigns = assign(assigns, :public_path, "/work/#{assigns.item.slug}")

    ~H"""
    <div class="flex min-w-64 items-center gap-2">
      <.link
        navigate={"/admin/projects/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Edit
      </.link>
      <.link
        navigate={@public_path}
        class="rounded border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
      >
        Preview
      </.link>
      <button
        type="button"
        phx-click="item-action"
        phx-value-action-key="delete"
        phx-value-item-id={@primary_key}
        class="rounded border border-red-200 px-2 py-1 text-xs font-semibold text-red-700 transition hover:border-red-300 hover:bg-red-50"
      >
        Delete
      </button>
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

  defp render_featured_toggle(assigns) do
    checked? = Phoenix.HTML.Form.normalize_value("checkbox", assigns.form[assigns.name].value)

    assigns = assign(assigns, :checked?, checked?)

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>

      <div class="inline-flex items-center rounded-md border border-slate-300 bg-slate-100 p-1">
        <input type="hidden" name={@form[@name].name} value="false" tabindex="-1" aria-hidden="true" />
        <label class={[
          "cursor-pointer rounded px-3 py-1.5 text-sm font-semibold transition",
          !@checked? && "bg-white text-slate-900 shadow-sm",
          @checked? && "text-slate-500 hover:text-slate-800"
        ]}>
          <input
            id={@form[@name].id}
            type="radio"
            name={@form[@name].name}
            value="false"
            checked={!@checked?}
            class="sr-only"
          /> Regular
        </label>
        <label class={[
          "cursor-pointer rounded px-3 py-1.5 text-sm font-semibold transition",
          @checked? && "bg-blue-600 text-white shadow-sm",
          !@checked? && "text-slate-500 hover:text-slate-800"
        ]}>
          <input
            type="radio"
            name={@form[@name].name}
            value="true"
            checked={@checked?}
            class="sr-only"
          /> Featured
        </label>
      </div>

      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_suggested_text_input(assigns) do
    assigns =
      assigns
      |> assign(:suggestions, suggested_values_for(assigns.name))
      |> assign(:list_id, "#{assigns.form[assigns.name].id}_suggestions")

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>
      <input
        id={@form[@name].id}
        name={@form[@name].name}
        value={Phoenix.HTML.Form.normalize_value("text", @form[@name].value)}
        placeholder={@field_options[:placeholder]}
        list={@list_id}
        class="input w-full"
      />
      <datalist id={@list_id}>
        <option :for={value <- @suggestions} value={value}></option>
      </datalist>
      <p :if={@suggestions != []} class="mt-2 text-sm opacity-70">
        Suggestions come from existing project data plus common portfolio values.
      </p>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp suggested_values_for(:role) do
    suggested_project_values(:role, [
      "Full-stack Engineer",
      "Mobile Engineering Lead",
      "iOS Developer"
    ])
  end

  defp suggested_values_for(:ownership) do
    suggested_project_values(:ownership, [
      "Solo builder end-to-end",
      "Feature owner",
      "Technical lead"
    ])
  end

  defp suggested_values_for(:team_size) do
    suggested_project_values(:team_size, [
      "Solo",
      "2 engineers",
      "Cross-functional team of 6"
    ])
  end

  defp suggested_values_for(:company) do
    suggested_project_values(:company, [
      "Personal Project",
      "Komerce",
      "Prodia"
    ])
  end

  defp suggested_values_for(:client) do
    suggested_project_values(:client, [
      "Internal portfolio",
      "Confidential client",
      "Public users"
    ])
  end

  defp suggested_values_for(_field), do: []

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
        placeholder={@field_options[:placeholder]}
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
