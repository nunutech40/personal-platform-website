defmodule PersonalBrandWeb.Admin.SiteSettingResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content
  alias PersonalBrand.Content.SiteSetting

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: SiteSetting,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &__MODULE__.update_changeset/3
    ]

  @impl true
  def singular_name, do: "Site Setting"

  @impl true
  def plural_name, do: "Site Settings"

  @impl true
  def panels do
    [
      identity: "Identitas Website",
      homepage: "Homepage CTA",
      profile: "Profil",
      about: "About Page",
      now: "Now Page",
      support: "Support / Tips",
      payments: "Payment Links",
      theme: "Theme",
      featured: "Featured Content"
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
      site_name: %{
        module: Backpex.Fields.Text,
        label: "Nama Website",
        placeholder: "Nunu Nugraha",
        help_text: "Nama brand yang tampil di title, header, dan metadata.",
        searchable: true,
        panel: :identity
      },
      headline: %{
        module: Backpex.Fields.Textarea,
        label: "Headline",
        rows: 3,
        placeholder:
          "A personal basecamp for work, writing, products, and things currently being built.",
        help_text: "Kalimat utama homepage.",
        index_column_class: "min-w-80",
        panel: :identity
      },
      subheadline: %{
        module: Backpex.Fields.Textarea,
        label: "Subheadline",
        rows: 4,
        placeholder:
          "One Phoenix LiveView app, one PostgreSQL-backed content source, and multiple theme renderers.",
        help_text: "Penjelasan singkat di bawah headline.",
        except: [:index],
        panel: :identity
      },
      primary_cta_text: %{
        module: Backpex.Fields.Text,
        label: "Primary CTA Text",
        placeholder: "View Work",
        help_text: "Label tombol/link utama homepage.",
        except: [:index],
        panel: :homepage
      },
      primary_cta_url: %{
        module: Backpex.Fields.Text,
        label: "Primary CTA URL",
        placeholder: "/work",
        help_text: "Internal URL, harus diawali /.",
        except: [:index],
        panel: :homepage
      },
      secondary_cta_text: %{
        module: Backpex.Fields.Text,
        label: "Secondary CTA Text",
        placeholder: "Read Writing",
        help_text: "Label tombol/link kedua homepage.",
        except: [:index],
        panel: :homepage
      },
      secondary_cta_url: %{
        module: Backpex.Fields.Text,
        label: "Secondary CTA URL",
        placeholder: "/writing",
        help_text: "Internal URL, harus diawali /.",
        except: [:index],
        panel: :homepage
      },
      active_theme: %{
        module: Backpex.Fields.Select,
        label: "Active Theme",
        options: fn _assigns -> theme_options() end,
        help_text: "Theme publik yang aktif. Mengubah theme tidak mengubah data konten.",
        render: &render_theme_badge/1,
        panel: :theme
      },
      profile_name: %{
        module: Backpex.Fields.Text,
        label: "Nama Profil",
        placeholder: "Nunu Nugraha",
        help_text: "Nama yang tampil di public profile.",
        panel: :profile
      },
      profile_title: %{
        module: Backpex.Fields.Text,
        label: "Title Profil",
        placeholder: "Flutter Developer, Builder, and Tech Enthusiast",
        help_text: "Headline profesional singkat.",
        except: [:index],
        panel: :profile
      },
      profile_location: %{
        module: Backpex.Fields.Text,
        label: "Lokasi",
        placeholder: "Jakarta, Indonesia",
        except: [:index],
        panel: :profile
      },
      profile_email: %{
        module: Backpex.Fields.Text,
        label: "Email",
        placeholder: "hello@example.com",
        help_text: "Harus format email valid.",
        panel: :profile
      },
      profile_bio: %{
        module: Backpex.Fields.Textarea,
        label: "Bio",
        rows: 8,
        placeholder: "Tulis ringkasan profil, minat teknis, dan fokus kerja saat ini.",
        except: [:index],
        panel: :profile
      },
      social_links: %{
        module: Backpex.Fields.Textarea,
        label: "Social Links",
        rows: 5,
        placeholder:
          "GitHub=https://github.com/username\nLinkedIn=https://linkedin.com/in/username",
        help_text: "Satu link per baris dengan format Label=URL.",
        render: &render_map/1,
        render_form: &render_map_textarea/1,
        except: [:index],
        panel: :profile
      },
      about_intro: %{
        module: Backpex.Fields.Textarea,
        label: "About Intro",
        rows: 5,
        placeholder:
          "Ringkasan profil untuk halaman About. Jelaskan siapa kamu, positioning, dan konteks profesional.",
        help_text: "Dipakai sebagai paragraf pembuka halaman About.",
        except: [:index],
        panel: :about
      },
      about_focus: %{
        module: Backpex.Fields.Textarea,
        label: "About Focus",
        rows: 5,
        placeholder:
          "Contoh: Saya fokus membangun produk mobile/web yang maintainable, jelas secara UX, dan bisa dikembangkan bertahap.",
        help_text: "Dipakai untuk menjelaskan fokus kerja atau positioning.",
        except: [:index],
        panel: :about
      },
      about_tools: %{
        module: Backpex.Fields.Textarea,
        label: "Tools / Tech",
        rows: 6,
        placeholder: "Elixir + Phoenix LiveView\nPostgreSQL\nFlutter\nSwift\nFigma",
        help_text: "Satu item per baris. Tampil sebagai list di halaman About.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :about
      },
      about_values: %{
        module: Backpex.Fields.Textarea,
        label: "Values / Prinsip",
        rows: 6,
        placeholder:
          "Clean architecture\nUseful product thinking\nReadable code\nShip small, learn fast",
        help_text: "Satu prinsip per baris. Tampil sebagai list di halaman About.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :about
      },
      now_building: %{
        module: Backpex.Fields.Textarea,
        label: "Now - Building",
        rows: 4,
        placeholder: "Personal brand platform, paid writing flow, dan product catalog.",
        help_text: "Apa yang sedang dibangun sekarang.",
        except: [:index],
        panel: :now
      },
      now_learning: %{
        module: Backpex.Fields.Textarea,
        label: "Now - Learning",
        rows: 4,
        placeholder: "Phoenix LiveView, Midtrans payment flow, writing habit.",
        help_text: "Apa yang sedang dipelajari.",
        except: [:index],
        panel: :now
      },
      now_focus: %{
        module: Backpex.Fields.Textarea,
        label: "Now - Focus",
        rows: 4,
        placeholder: "Membuat portfolio dan writing lebih jelas untuk recruiter dan partner.",
        help_text: "Fokus utama saat ini.",
        except: [:index],
        panel: :now
      },
      now_updated_at: %{
        module: Backpex.Fields.Date,
        label: "Now Updated At",
        help_text: "Tanggal terakhir halaman Now diperbarui.",
        except: [:index],
        panel: :now
      },
      saweria_url: %{
        module: Backpex.Fields.Text,
        label: "Saweria URL",
        placeholder: "https://saweria.co/username",
        help_text: "Link support/tips untuk CTA di post gratis.",
        except: [:index],
        panel: :support
      },
      buy_me_coffee_url: %{
        module: Backpex.Fields.Text,
        label: "Buy Me Coffee URL",
        placeholder: "https://www.buymeacoffee.com/username",
        help_text: "Link support/tips untuk CTA di post gratis.",
        except: [:index],
        panel: :support
      },
      tips_cta_title: %{
        module: Backpex.Fields.Text,
        label: "Tips CTA Title",
        placeholder: "Support this writing",
        help_text: "Judul CTA support di akhir post gratis.",
        except: [:index],
        panel: :support
      },
      tips_cta_body: %{
        module: Backpex.Fields.Textarea,
        label: "Tips CTA Body",
        rows: 4,
        placeholder:
          "Kalau tulisan ini membantu, kamu bisa support lewat Saweria atau Buy Me Coffee.",
        help_text: "Body copy CTA support di post gratis.",
        except: [:index],
        panel: :support
      },
      xendit_checkout_url: %{
        module: Backpex.Fields.Text,
        label: "Xendit Checkout URL",
        placeholder: "https://checkout.xendit.co/...",
        help_text:
          "Opsional untuk referensi link Xendit di masa depan. Midtrans tetap payment utama saat ini.",
        except: [:index],
        panel: :payments
      },
      xendit_webhook_url: %{
        module: Backpex.Fields.Text,
        label: "Xendit Webhook URL",
        placeholder: "https://example.com/webhooks/xendit",
        help_text: "Opsional untuk catatan/config masa depan. Jangan isi secret/API key di sini.",
        except: [:index],
        panel: :payments
      },
      featured_project_ids: %{
        module: Backpex.Fields.Textarea,
        label: "Featured Project IDs",
        rows: 4,
        placeholder: "UUID project satu per baris",
        help_text: "Opsional. Saat ini public utama tetap memakai flag Featured di project.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :featured
      },
      featured_product_ids: %{
        module: Backpex.Fields.Textarea,
        label: "Featured Product IDs",
        rows: 4,
        placeholder: "UUID product satu per baris",
        help_text: "Opsional. Saat ini public utama tetap memakai flag Featured di product.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :featured
      }
    ]
  end

  defp theme_options do
    case Content.list_themes() do
      [] -> [{"Old Web Classic", "old_web_classic"}]
      themes -> Enum.map(themes, &{&1.name, &1.key})
    end
  end

  def create_changeset(site_setting, attrs, _metadata),
    do: SiteSetting.changeset(site_setting, attrs)

  def update_changeset(site_setting, attrs, _metadata),
    do: SiteSetting.changeset(site_setting, attrs)

  defp render_admin_actions(assigns) do
    ~H"""
    <div class="flex min-w-48 items-center gap-2">
      <.link
        navigate={"/admin/site-settings/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Ubah
      </.link>
      <.link
        navigate="/"
        class="rounded border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
      >
        Lihat Situs
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

  defp render_theme_badge(assigns) do
    ~H"""
    <span class="badge badge-primary badge-sm">{@value}</span>
    """
  end

  defp render_map(assigns) do
    assigns = assign(assigns, :values, map_value(assigns[:value]))

    ~H"""
    <div class="flex max-w-96 flex-wrap gap-1">
      <span :for={{key, value} <- @values} class="badge badge-outline badge-sm">
        {key}: {value}
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

  defp render_map_textarea(assigns) do
    assigns = assign(assigns, :textarea_value, map_textarea_value(assigns[:value]))

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

  defp render_textarea(assigns) do
    assigns = assign(assigns, :textarea_value, textarea_value(assigns[:value]))

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

  defp map_value(value) when is_map(value), do: Enum.sort(value)
  defp map_value(_value), do: []

  defp map_textarea_value(value) when is_map(value) do
    value
    |> Enum.sort()
    |> Enum.map_join("\n", fn {key, url} -> "#{key}=#{url}" end)
  end

  defp map_textarea_value(_value), do: ""

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp display_value(value) when is_list(value) and value != [], do: Enum.join(value, ", ")
  defp display_value(value) when is_binary(value), do: value
  defp display_value(_value), do: "-"
end
