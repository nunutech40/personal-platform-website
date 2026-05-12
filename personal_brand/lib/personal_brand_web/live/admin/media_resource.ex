defmodule PersonalBrandWeb.Admin.MediaResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content.Media
  alias PersonalBrand.MediaStorage

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Media,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &__MODULE__.update_changeset/3
    ]

  @impl true
  def singular_name, do: "Media"

  @impl true
  def plural_name, do: "Media Library"

  @impl true
  def panels do
    [
      upload: "Upload",
      metadata: "Metadata",
      usage: "Usage"
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
        index_column_class: "min-w-56"
      },
      preview: %{
        module: Backpex.Fields.Text,
        label: "Preview",
        only: [:index, :show],
        render: &render_preview/1,
        index_column_class: "w-32"
      },
      file: %{
        module: Backpex.Fields.Upload,
        label: "Upload File",
        upload_key: :file,
        accept: :any,
        max_entries: 1,
        max_file_size: 20_000_000,
        help_text:
          "Upload maksimal 20MB. Link publik, filename, content type, size, dan storage path akan diisi otomatis. Untuk media dari GitHub/raw URL, kosongkan upload dan isi URL manual di Metadata.",
        put_upload_change: &put_upload_change/6,
        consume_upload: &consume_upload/4,
        remove_uploads: &remove_uploads/3,
        list_existing_files: &list_existing_files/1,
        render: &render_file_link/1,
        except: [:index],
        panel: :upload
      },
      filename: %{
        module: Backpex.Fields.Text,
        label: "Filename",
        placeholder: "portfolio-cover.png",
        help_text: "Nama file human-readable untuk admin picker.",
        searchable: true,
        panel: :metadata
      },
      alt_text: %{
        module: Backpex.Fields.Text,
        label: "Alt Text",
        placeholder: "Screenshot halaman work Personal Platform Website",
        help_text: "Deskripsi gambar untuk aksesibilitas dan konteks content.",
        index_column_class: "min-w-80",
        panel: :metadata
      },
      content_type: %{
        module: Backpex.Fields.Text,
        label: "Content Type",
        placeholder: "image/png",
        help_text: "Contoh: image/png, image/jpeg, application/pdf.",
        render: &render_content_type/1,
        panel: :metadata
      },
      size: %{
        module: Backpex.Fields.Number,
        label: "Size",
        placeholder: "102400",
        help_text: "Ukuran file dalam bytes.",
        render: &render_size/1,
        panel: :metadata
      },
      url: %{
        module: Backpex.Fields.Text,
        label: "URL",
        placeholder:
          "https://raw.githubusercontent.com/nunutech40/repo/main/docs/assets/cover.png",
        help_text:
          "URL publik yang dipakai frontend. Upload lokal memakai /uploads/media/...; external image/video boleh pakai https:// dari GitHub raw, release asset, CDN, atau storage publik.",
        render: &render_file_link/1,
        index_column_class: "min-w-80",
        panel: :metadata
      },
      file_path: %{
        module: Backpex.Fields.Text,
        label: "Storage Path",
        placeholder: "uploads/media/example.png",
        help_text: "Path relatif di storage lokal. Biasanya terisi otomatis dari upload.",
        except: [:index],
        panel: :metadata
      },
      attachable_type: %{
        module: Backpex.Fields.Text,
        label: "Attachable Type",
        placeholder: "Project / Post / Product",
        help_text: "Opsional untuk catatan penggunaan media.",
        except: [:index],
        panel: :usage
      },
      attachable_id: %{
        module: Backpex.Fields.Text,
        label: "Attachable ID",
        placeholder: "UUID content terkait",
        help_text: "Opsional. Cover utama biasanya dipilih dari resource Project/Post/Product.",
        except: [:index],
        panel: :usage
      },
      updated_at: %{
        module: Backpex.Fields.DateTime,
        label: "Terakhir Diubah",
        except: [:new, :edit],
        orderable: true
      }
    ]
  end

  @impl true
  def on_item_deleted(_socket, item) do
    MediaStorage.delete(item.file_path)
  end

  def create_changeset(media, attrs, _metadata), do: Media.changeset(media, attrs)

  def update_changeset(media, attrs, _metadata), do: Media.changeset(media, attrs)

  defp render_admin_actions(assigns) do
    assigns = assign(assigns, :public_url, assigns.item.url)

    ~H"""
    <div class="flex min-w-56 items-center gap-2">
      <.link
        navigate={"/admin/media/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Ubah
      </.link>
      <a
        :if={@public_url}
        href={@public_url}
        target="_blank"
        rel="noopener noreferrer"
        class="rounded border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 no-underline transition hover:border-slate-300 hover:bg-slate-50"
      >
        Buka
      </a>
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

  defp render_preview(assigns) do
    assigns =
      assigns
      |> assign(:url, assigns.item.url)
      |> assign(:content_type, assigns.item.content_type || "")
      |> assign(:alt_text, assigns.item.alt_text || assigns.item.filename || "Media preview")
      |> assign(:image_media, image_media?(assigns.item))

    ~H"""
    <div class="h-16 w-24 overflow-hidden rounded border border-slate-200 bg-slate-50">
      <img
        :if={@image_media and @url}
        src={@url}
        alt={@alt_text}
        class="h-full w-full object-cover"
      />
      <div
        :if={!@image_media or !@url}
        class="flex h-full items-center justify-center px-2 text-center text-xs text-slate-500"
      >
        File
      </div>
    </div>
    """
  end

  defp render_file_link(%{value: value} = assigns) when is_binary(value) and value != "" do
    ~H"""
    <a href={@value} target="_blank" rel="noopener noreferrer" class="link link-primary">
      {@value}
    </a>
    """
  end

  defp render_file_link(assigns) do
    ~H"""
    <span>{Backpex.HTML.pretty_value(@value)}</span>
    """
  end

  defp render_content_type(assigns) do
    assigns = assign(assigns, :value, assigns[:value])

    ~H"""
    <span>
      <span :if={@value} class="badge badge-outline badge-sm">{@value}</span>
      <span :if={!@value}>-</span>
    </span>
    """
  end

  defp render_size(assigns) do
    assigns = assign(assigns, :display_value, format_size(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp format_size(value) when is_integer(value) and value >= 1_000_000,
    do: "#{Float.round(value / 1_000_000, 1)} MB"

  defp format_size(value) when is_integer(value) and value >= 1_000,
    do: "#{Float.round(value / 1_000, 1)} KB"

  defp format_size(value) when is_integer(value), do: "#{value} B"
  defp format_size(_value), do: "-"

  defp image_media?(%{content_type: content_type, url: url}) do
    (is_binary(content_type) and String.starts_with?(content_type, "image/")) or image_url?(url)
  end

  defp image_media?(_media), do: false

  defp image_url?(url) when is_binary(url) do
    path =
      url
      |> URI.parse()
      |> Map.get(:path)
      |> to_string()
      |> String.downcase()

    String.ends_with?(path, [".png", ".jpg", ".jpeg", ".gif", ".webp", ".avif"])
  end

  defp image_url?(_url), do: false

  # ── Upload Callbacks ─────────────────────────────────────

  defp list_existing_files(%{file_path: file_path}) when is_binary(file_path) and file_path != "",
    do: [file_path]

  defp list_existing_files(_item), do: []

  defp put_upload_change(_socket, params, item, uploaded_entries, removed_entries, action) do
    existing_files = list_existing_files(item) -- removed_entries

    new_entries =
      case action do
        :validate -> elem(uploaded_entries, 1)
        :insert -> elem(uploaded_entries, 0)
      end

    files = existing_files ++ Enum.map(new_entries, &stored_file_path/1)

    params =
      case files do
        [file] -> Map.put(params, "file_path", file)
        [_file | _other_files] -> Map.put(params, "file_path", "too_many_files")
        [] -> Map.put(params, "file_path", "")
      end

    case new_entries do
      [entry | _entries] -> put_upload_metadata(params, entry)
      [] -> params
    end
  end

  defp consume_upload(_socket, _item, %{path: path}, entry) do
    case MediaStorage.store(entry, path) do
      {:ok, %{url: url}} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  end

  defp remove_uploads(_socket, _item, removed_entries) do
    for file_path <- removed_entries do
      MediaStorage.delete(file_path)
    end
  end

  defp put_upload_metadata(params, entry) do
    filename = stored_filename(entry)
    file_path = stored_file_path(entry)

    params
    |> Map.put_new("filename", entry.client_name)
    |> put_blank("filename", entry.client_name)
    |> Map.put("url", MediaStorage.public_url(filename))
    |> Map.put("file_path", file_path)
    |> Map.put("content_type", entry.client_type)
    |> Map.put("size", entry.client_size)
  end

  defp put_blank(params, key, value) do
    if Map.get(params, key) in [nil, ""] do
      Map.put(params, key, value)
    else
      params
    end
  end

  defp stored_filename(entry), do: MediaStorage.generate_filename(entry)
  defp stored_file_path(entry), do: Path.join("uploads/media", stored_filename(entry))
end
