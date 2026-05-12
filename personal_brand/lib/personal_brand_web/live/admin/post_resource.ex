defmodule PersonalBrandWeb.Admin.PostResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Post
  alias PersonalBrandWeb.Admin.ResourceUI

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Post,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &__MODULE__.update_changeset/3
    ]

  @impl true
  def singular_name, do: "Post"

  @impl true
  def plural_name, do: "Writing Posts"

  @impl true
  def panels do
    [
      identity: "Info Dasar",
      content: "Konten",
      publishing: "Publishing",
      seo: "SEO"
    ]
  end

  @impl true
  def item_actions(default_actions),
    do: ResourceUI.item_actions_without_bulk_delete(default_actions)

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def render_resource_slot(assigns, :index, :main) do
    ~H"""
    <ResourceUI.index_main {assigns} />
    """
  end

  @impl true
  def fields do
    [
      admin_actions: %{
        module: Backpex.Fields.Text,
        label: "Aksi",
        only: [:index],
        render: &render_admin_actions/1,
        index_column_class: "min-w-64"
      },
      title: %{
        module: Backpex.Fields.Text,
        label: "Judul Tulisan",
        placeholder: "Contoh: Building a Production-Ready Flutter App in 2026",
        help_text: "Judul yang tampil di halaman Writing dan detail post.",
        searchable: true,
        panel: :identity
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "URL Tulisan (slug)",
        placeholder: "building-production-ready-flutter-app-2026",
        help_text:
          "Kosongkan saat membuat post baru, sistem akan buat otomatis dari judul. Ubah slug published hanya kalau memang perlu.",
        panel: :identity
      },
      excerpt: %{
        module: Backpex.Fields.Textarea,
        label: "Ringkasan",
        rows: 3,
        placeholder:
          "Satu-dua kalimat yang menjelaskan isi tulisan dan kenapa pembaca perlu membacanya.",
        help_text: "Dipakai di list Writing dan metadata fallback.",
        index_column_class: "min-w-80",
        panel: :identity
      },
      content_markdown: %{
        module: PersonalBrandWeb.Admin.Fields.MarkdownEditor,
        label: "Konten Markdown",
        rows: 18,
        help_text: "Gunakan Markdown untuk heading, link, list, gambar, dan code block.",
        except: [:index],
        panel: :content
      },
      tags: %{
        module: Backpex.Fields.Textarea,
        label: "Tags",
        rows: 4,
        placeholder: "Flutter\nPhoenix LiveView\nArchitecture",
        help_text:
          "Satu tag per baris atau pisahkan dengan koma. Saran tag dari post existing ditampilkan di bawah field jika ada.",
        render: &render_badges/1,
        render_form: &render_tags_textarea/1,
        panel: :content
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [{"Draft", "draft"}, {"Published", "published"}, {"Archived", "archived"}],
        render: &render_status_badge/1,
        panel: :publishing
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Unggulan di homepage/writing",
        help_text: "Aktifkan untuk tulisan yang ingin ditonjolkan sebelum tulisan biasa.",
        render: &render_featured_badge/1,
        render_form: &render_featured_toggle/1,
        panel: :publishing
      },
      published_at: %{
        module: Backpex.Fields.DateTime,
        label: "Tanggal Publish",
        help_text: "Isi saat post siap tampil sebagai published.",
        panel: :publishing
      },
      reading_time: %{
        module: Backpex.Fields.Number,
        label: "Waktu Baca (menit)",
        placeholder: "5",
        help_text: "Angka 1-120 menit.",
        panel: :publishing
      },
      seo_title: %{
        module: Backpex.Fields.Text,
        label: "SEO Title",
        placeholder: "Contoh: Production-Ready Flutter App Checklist",
        help_text: "Opsional. Maksimal 70 karakter.",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :seo
      },
      seo_description: %{
        module: Backpex.Fields.Textarea,
        label: "SEO Description",
        rows: 3,
        placeholder:
          "Ringkasan 1 kalimat untuk search engine dan social preview. Maksimal 160 karakter.",
        help_text: "Opsional. Maksimal 160 karakter.",
        except: [:index],
        panel: :seo
      }
    ]
  end

  def create_changeset(post, attrs, _metadata) do
    post
    |> Post.changeset(Content.put_unique_post_slug(attrs))
  end

  def update_changeset(post, attrs, _metadata), do: Post.changeset(post, attrs)

  defp render_admin_actions(assigns) do
    assigns = assign(assigns, :public_path, "/writing/#{assigns.item.slug}")

    ~H"""
    <div class="flex min-w-64 items-center gap-2">
      <.link
        navigate={"/admin/posts/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Ubah
      </.link>
      <.link
        navigate={@public_path}
        class="rounded border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
      >
        Lihat Publik
      </.link>
      <button
        type="button"
        phx-click="item-action"
        phx-value-action-key="delete"
        phx-value-item-id={@primary_key}
        class="rounded border border-red-200 px-2 py-1 text-xs font-semibold text-red-700 transition hover:border-red-300 hover:bg-red-50"
      >
        Hapus
      </button>
    </div>
    """
  end

  defp render_tags_textarea(assigns) do
    assigns =
      assigns
      |> assign(:textarea_value, textarea_value(assigns[:value]))
      |> assign(:suggestions, post_tag_suggestions())

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
      <div :if={@suggestions != []} class="mt-2 flex flex-wrap gap-1 text-sm">
        <span class="mr-1 text-slate-500">Saran:</span>
        <span :for={tag <- @suggestions} class="rounded bg-slate-100 px-2 py-1 text-slate-700">
          {tag}
        </span>
      </div>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_suggested_text_input(assigns) do
    suggestions = Content.list_post_field_values(assigns.name)

    assigns =
      assigns
      |> assign(:suggestions, suggestions)
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
        list={if @suggestions == [], do: nil, else: @list_id}
        class="input w-full"
      />
      <datalist :if={@suggestions != []} id={@list_id}>
        <option :for={value <- @suggestions} value={value}></option>
      </datalist>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_badges(assigns) do
    assigns = assign(assigns, :values, list_value(assigns[:value]))

    ~H"""
    <div class="flex max-w-80 flex-wrap gap-1">
      <span :for={value <- @values} class="badge badge-outline badge-sm">{value}</span>
      <span :if={@values == []}>-</span>
    </div>
    """
  end

  defp render_status_badge(assigns) do
    status_class =
      case assigns[:value] do
        "published" -> "badge badge-success badge-sm"
        "draft" -> "badge badge-warning badge-sm"
        "archived" -> "badge badge-ghost badge-sm"
        _status -> "badge badge-outline badge-sm"
      end

    assigns = assign(assigns, :status_class, status_class)

    ~H"""
    <span class={@status_class}>{@value}</span>
    """
  end

  defp render_featured_badge(assigns) do
    ~H"""
    <span>
      <span :if={@value} class="badge badge-primary badge-sm">Unggulan</span>
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
          /> Biasa
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
          /> Unggulan
        </label>
      </div>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp post_tag_suggestions do
    (Content.list_post_array_values(:tags) ++
       ["Elixir", "Phoenix LiveView", "Flutter", "iOS", "Architecture"])
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp list_value(value) when is_list(value), do: value
  defp list_value(value) when is_binary(value) and value != "", do: [value]
  defp list_value(_value), do: []
end
