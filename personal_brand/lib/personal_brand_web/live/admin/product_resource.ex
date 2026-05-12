defmodule PersonalBrandWeb.Admin.ProductResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Product

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Product,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &__MODULE__.update_changeset/3
    ]

  @impl true
  def singular_name, do: "Product"

  @impl true
  def plural_name, do: "Products"

  @impl true
  def panels do
    [
      identity: "Info Dasar",
      commerce: "Commerce",
      delivery: "Delivery",
      content: "Konten",
      media_links: "Media & Link"
    ]
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
        index_column_class: "min-w-64"
      },
      title: %{
        module: Backpex.Fields.Text,
        label: "Nama Produk",
        placeholder: "Contoh: Flux Icons",
        help_text: "Nama produk yang tampil di halaman Products.",
        searchable: true,
        panel: :identity
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "URL Produk (slug)",
        placeholder: "flux-icons",
        help_text:
          "Kosongkan saat membuat produk baru, sistem akan buat otomatis dari nama produk.",
        panel: :identity
      },
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Ringkasan",
        rows: 3,
        placeholder: "Satu-dua kalimat yang menjelaskan manfaat utama produk.",
        help_text: "Dipakai di list Products dan homepage.",
        index_column_class: "min-w-80",
        panel: :identity
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Deskripsi",
        rows: 8,
        placeholder:
          "Jelaskan masalah yang dibantu produk ini, target user, dan cara memakainya.",
        help_text: "Konten utama halaman detail produk.",
        except: [:index],
        panel: :content
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [
          {"Active", "active"},
          {"Draft", "draft"},
          {"Archived", "archived"},
          {"Coming Soon", "coming_soon"}
        ],
        render: &render_status_badge/1,
        panel: :commerce
      },
      product_type: %{
        module: Backpex.Fields.Select,
        label: "Tipe Produk",
        options: [{"Digital", "digital"}, {"Physical", "physical"}, {"Service", "service"}],
        panel: :commerce
      },
      price: %{
        module: Backpex.Fields.Number,
        label: "Harga",
        placeholder: "29.00",
        help_text: "Gunakan 0 untuk produk gratis atau coming soon.",
        panel: :commerce
      },
      currency: %{
        module: Backpex.Fields.Text,
        label: "Currency",
        placeholder: "USD",
        help_text: "Kode mata uang 3 huruf, contoh: USD atau IDR.",
        render_form: &render_suggested_text_input/1,
        panel: :commerce
      },
      stock_status: %{
        module: Backpex.Fields.Select,
        label: "Status Stock",
        options: [
          {"In Stock", "in_stock"},
          {"Out of Stock", "out_of_stock"},
          {"Pre-order", "pre_order"}
        ],
        panel: :delivery
      },
      delivery_type: %{
        module: Backpex.Fields.Select,
        label: "Tipe Delivery",
        options: [
          {"Digital Download", "digital_download"},
          {"Email Delivery", "email_delivery"},
          {"Physical", "physical_delivery"}
        ],
        panel: :delivery
      },
      checkout_url: %{
        module: Backpex.Fields.Text,
        label: "Checkout URL",
        placeholder: "https://app.midtrans.com/payment-links/example",
        help_text: "Opsional. Harus diawali http:// atau https:// jika diisi.",
        except: [:index],
        panel: :media_links
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Unggulan di homepage/products",
        help_text: "Aktifkan untuk produk yang ingin ditonjolkan.",
        render: &render_featured_badge/1,
        render_form: &render_featured_toggle/1,
        panel: :commerce
      },
      included: %{
        module: Backpex.Fields.Textarea,
        label: "Yang Termasuk",
        rows: 5,
        placeholder: "Icon set SVG\nFlutter package\nUsage examples",
        help_text:
          "Satu item per baris. Saran dari produk existing ditampilkan di bawah field jika ada.",
        render: &render_list/1,
        render_form: &render_included_textarea/1,
        except: [:index],
        panel: :content
      },
      seo_url: %{
        module: Backpex.Fields.Text,
        label: "SEO / Share URL",
        render: &render_seo_url/1,
        help_text:
          "Copy URL ini untuk submit ke Google Search Console atau bagikan di media sosial.",
        except: [:new, :edit, :index],
        panel: :media_links
      }
    ]
  end

  def create_changeset(product, attrs, _metadata) do
    product
    |> Product.changeset(Content.put_unique_product_slug(attrs))
  end

  def update_changeset(product, attrs, _metadata), do: Product.changeset(product, attrs)

  defp render_admin_actions(assigns) do
    assigns = assign(assigns, :public_path, "/products/#{assigns.item.slug}")

    ~H"""
    <div class="flex min-w-64 items-center gap-2">
      <.link
        navigate={"/admin/products/#{@primary_key}/edit"}
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

  defp render_suggested_text_input(assigns) do
    suggestions =
      assigns.name
      |> suggested_values_for()
      |> Enum.uniq()

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

  defp render_included_textarea(assigns) do
    assigns =
      assigns
      |> assign(:textarea_value, textarea_value(assigns[:value]))
      |> assign(:suggestions, included_suggestions())

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
        <span :for={item <- @suggestions} class="rounded bg-slate-100 px-2 py-1 text-slate-700">
          {item}
        </span>
      </div>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_status_badge(assigns) do
    status_class =
      case assigns[:value] do
        "active" -> "badge badge-success badge-sm"
        "coming_soon" -> "badge badge-info badge-sm"
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

  defp render_list(assigns) do
    assigns = assign(assigns, :display_value, display_value(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp suggested_values_for(:currency),
    do: Content.list_product_field_values(:currency) ++ ["USD", "IDR"]

  defp suggested_values_for(_field), do: []

  defp included_suggestions do
    (Content.list_product_array_values(:included) ++
       ["Download files", "Usage examples", "Documentation", "Source files"])
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp display_value(value) when is_list(value) and value != [], do: Enum.join(value, ", ")
  defp display_value(value) when is_binary(value), do: value
  defp display_value(_value), do: "-"

  defp render_seo_url(assigns) do
    slug = assigns.item.slug
    url = "https://nunutech40.dev/products/#{slug}"

    assigns = assign(assigns, :seo_url, url)

    ~H"""
    <div>
      <code style="display:block; padding:0.5em; background:#f5f5f5; border:1px solid #ddd; border-radius:4px; word-break:break-all; font-size:0.9em;">
        {@seo_url}
      </code>
      <p class="mt-2 text-sm opacity-70">
        Copy URL ini untuk submit ke
        <a href="https://search.google.com/search-console" target="_blank" rel="noopener" class="link">
          Google Search Console
        </a>
        atau bagikan di media sosial.
      </p>
    </div>
    """
  end
end
