defmodule PersonalBrandWeb.Admin.ThemeResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content.Theme

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Theme,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &__MODULE__.update_changeset/3
    ]

  @impl true
  def singular_name, do: "Theme"

  @impl true
  def plural_name, do: "Themes"

  @impl true
  def panels do
    [
      identity: "Info Theme",
      config: "Konfigurasi"
    ]
  end

  @impl true
  def item_actions(default_actions) do
    Keyword.update!(default_actions, :delete, &Map.put(&1, :only, [:index]))
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
        label: "Aksi",
        only: [:index],
        render: &render_admin_actions/1,
        index_column_class: "min-w-48"
      },
      key: %{
        module: Backpex.Fields.Text,
        label: "Theme Key",
        placeholder: "old_web_classic",
        help_text:
          "Lowercase, angka, dan underscore saja. Dipakai oleh site_settings.active_theme.",
        searchable: true,
        panel: :identity
      },
      name: %{
        module: Backpex.Fields.Text,
        label: "Nama Theme",
        placeholder: "Old Web Classic",
        help_text: "Nama human-readable untuk admin.",
        searchable: true,
        panel: :identity
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Deskripsi",
        rows: 4,
        placeholder:
          "Theme klasik yang meniru personal website sederhana dengan typography editorial.",
        help_text: "Catatan tujuan visual theme.",
        except: [:index],
        panel: :identity
      },
      is_active: %{
        module: Backpex.Fields.Boolean,
        label: "Aktif di registry",
        help_text:
          "Menandai theme tersedia. Theme publik tetap dipilih dari Site Settings > Active Theme.",
        render: &render_active_badge/1,
        render_form: &render_active_toggle/1,
        panel: :identity
      },
      config: %{
        module: Backpex.Fields.Textarea,
        label: "Config JSON",
        rows: 8,
        placeholder: ~s({"accent_color":"#111827","font":"serif"}),
        help_text: "Opsional. Isi JSON object valid atau kosongkan.",
        render: &render_config/1,
        render_form: &render_config_textarea/1,
        except: [:index],
        panel: :config
      },
      updated_at: %{
        module: Backpex.Fields.DateTime,
        label: "Terakhir Diubah",
        except: [:new, :edit],
        orderable: true
      }
    ]
  end

  defp render_admin_actions(assigns) do
    ~H"""
    <div class="flex min-w-48 items-center gap-2">
      <.link
        navigate={"/admin/themes/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Ubah
      </.link>
      <.link
        navigate="/"
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
        Hapus
      </button>
    </div>
    """
  end

  def create_changeset(theme, attrs, _metadata), do: Theme.changeset(theme, attrs)

  def update_changeset(theme, attrs, _metadata), do: Theme.changeset(theme, attrs)

  defp render_active_badge(assigns) do
    ~H"""
    <span>
      <span :if={@value} class="badge badge-success badge-sm">Aktif</span>
      <span :if={!@value} class="text-slate-400">-</span>
    </span>
    """
  end

  defp render_active_toggle(assigns) do
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
          /> Nonaktif
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
          /> Aktif
        </label>
      </div>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_config(assigns) do
    assigns = assign(assigns, :display_value, config_value(assigns[:value]))

    ~H"""
    <code class="text-xs">{@display_value}</code>
    """
  end

  defp render_config_textarea(assigns) do
    assigns = assign(assigns, :textarea_value, config_textarea_value(assigns[:value]))

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>
      <textarea
        id={@form[@name].id}
        name={@form[@name].name}
        rows={@field_options[:rows] || 6}
        placeholder={@field_options[:placeholder]}
        class="textarea w-full font-mono text-sm"
      >{@textarea_value}</textarea>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp config_value(value) when is_map(value), do: Jason.encode!(value)
  defp config_value(value) when is_binary(value), do: value
  defp config_value(_value), do: "-"

  defp config_textarea_value(value) when is_map(value), do: Jason.encode!(value, pretty: true)
  defp config_textarea_value(value) when is_binary(value), do: value
  defp config_textarea_value(_value), do: ""
end
