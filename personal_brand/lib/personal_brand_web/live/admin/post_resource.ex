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
    ],
    init_order: %{by: :updated_at, direction: :desc}

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
      monetization: "Monetisasi",
      media: "Media",
      seo: "SEO"
    ]
  end

  @impl true
  def item_actions(default_actions) do
    default_actions
    |> ResourceUI.item_actions_without_bulk_delete()
    |> Keyword.put(:delete, %{
      module: PersonalBrandWeb.Admin.ItemActions.DeleteItem,
      only: [:index, :show]
    })
  end

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
        index_column_class: "w-48 max-w-48",
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
        orderable: true,
        panel: :publishing
      },
      reading_time: %{
        module: Backpex.Fields.Number,
        label: "Waktu Baca (menit)",
        placeholder: "5",
        help_text: "Angka 1-120 menit.",
        panel: :publishing
      },
      access_type: %{
        module: Backpex.Fields.Select,
        label: "Tipe Akses",
        options: [
          {"Gratis (Free)", "free"},
          {"Tips (Locked + Pilihan Nominal)", "tips"},
          {"Berbayar (Locked)", "paid"}
        ],
        help_text:
          "Free = konten terbuka + CTA support. Tips = konten dikunci dan pembaca memilih nominal tips. Paid = konten dikunci dengan satu harga.",
        panel: :monetization
      },
      price: %{
        module: Backpex.Fields.Number,
        label: "Harga",
        placeholder: "25000",
        help_text: "Wajib diisi jika tipe akses Paid. Dalam satuan mata uang (bukan sen).",
        except: [:index],
        panel: :monetization
      },
      currency: %{
        module: Backpex.Fields.Text,
        label: "Mata Uang",
        placeholder: "IDR",
        help_text: "Kode mata uang 3 huruf. Default: IDR.",
        except: [:index],
        panel: :monetization
      },
      tip_amount_options: %{
        module: Backpex.Fields.Textarea,
        label: "Opsi Jumlah Tips",
        rows: 2,
        placeholder: "10000\n15000\n25000",
        help_text:
          "Wajib untuk tipe Tips. Satu angka per baris; pembaca harus memilih salah satu nominal ini.",
        render_form: &render_textarea/1,
        except: [:index],
        panel: :monetization
      },
      paid_excerpt: %{
        module: Backpex.Fields.Textarea,
        label: "Preview untuk Paid Post",
        rows: 4,
        placeholder: "Bagian awal artikel yang bisa dibaca gratis sebelum paywall.",
        help_text: "Teks yang tampil sebelum paywall. Jika kosong, pakai excerpt.",
        except: [:index],
        panel: :monetization
      },
      paywall_cta: %{
        module: Backpex.Fields.Text,
        label: "CTA Paywall",
        placeholder: "Baca selengkapnya — Rp25.000",
        help_text: "Teks tombol/link untuk membayar. Jika kosong, pakai default.",
        except: [:index],
        panel: :monetization
      },
      payment_provider: %{
        module: Backpex.Fields.Select,
        label: "Payment Provider",
        options: [
          {"Belum dipilih", ""},
          {"Manual Link", "manual_link"},
          {"Midtrans", "midtrans"}
        ],
        help_text:
          "Untuk paid/tips. Manual Link = redirect ke URL eksternal. Midtrans = integrasi proper (belum aktif).",
        except: [:index],
        panel: :monetization
      },
      checkout_url: %{
        module: Backpex.Fields.Text,
        label: "Checkout URL",
        placeholder: "https://app.midtrans.com/payment-links/...",
        help_text:
          "URL pembayaran eksternal. Harus http:// atau https://. Untuk manual_link provider.",
        except: [:index],
        panel: :monetization
      },
      cover_image: %{
        module: Backpex.Fields.BelongsTo,
        label: "Cover Image",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Pilih cover image",
        help_text:
          "Gambar utama tulisan untuk list Writing dan fallback social preview. Upload dulu di Admin > Media.",
        except: [:index],
        panel: :media
      },
      og_image: %{
        module: Backpex.Fields.BelongsTo,
        label: "Open Graph Image",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Pilih OG image",
        help_text:
          "Opsional. Pakai gambar khusus social sharing. Jika kosong, sistem memakai Cover Image.",
        except: [:index],
        panel: :media
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
      },
      updated_at: %{
        module: Backpex.Fields.DateTime,
        label: "Terakhir Diubah",
        except: [:new, :edit],
        orderable: true
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

  defp render_textarea(assigns) do
    errors =
      assigns.form[assigns.name].errors
      |> Enum.map(&PersonalBrandWeb.CoreComponents.translate_error/1)

    assigns =
      assigns
      |> assign(:textarea_value, textarea_value(assigns[:value]))
      |> assign(:errors, errors)

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
        class={["textarea w-full", @errors != [] && "textarea-error"]}
      >{@textarea_value}</textarea>
      <p :for={error <- @errors} class="mt-2 text-sm font-medium text-red-600">
        {error}
      </p>
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
    assigns = assign_limited_values(assigns, assigns[:value], 3, & &1)

    ~H"""
    <div class="admin-index-chips" title={@full_value}>
      <span :for={value <- @visible_values} class="badge badge-outline badge-sm">
        {value}
      </span>
      <span :if={@remaining_count > 0} class="badge badge-ghost badge-sm">
        +{@remaining_count}
      </span>
      <span :if={@visible_values == []}>-</span>
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

  defp assign_limited_values(assigns, value, limit, label_fun) do
    values =
      value
      |> list_value()
      |> Enum.reject(&(is_nil(&1) or &1 == ""))

    labels = Enum.map(values, label_fun)

    assigns
    |> assign(:visible_values, Enum.take(labels, limit))
    |> assign(:remaining_count, max(length(labels) - limit, 0))
    |> assign(:full_value, Enum.join(labels, ", "))
  end

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp list_value(value) when is_list(value), do: value
  defp list_value(value) when is_binary(value) and value != "", do: [value]
  defp list_value(_value), do: []
end
