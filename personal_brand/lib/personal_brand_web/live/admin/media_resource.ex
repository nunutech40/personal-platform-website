defmodule PersonalBrandWeb.Admin.MediaResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Media,
      repo: PersonalBrand.Repo
    ]

  alias PersonalBrand.MediaStorage

  @impl true
  def singular_name, do: "Media"

  @impl true
  def plural_name, do: "Media"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      file: %{
        module: Backpex.Fields.Upload,
        label: "File",
        upload_key: :file,
        accept: :any,
        max_entries: 1,
        max_file_size: 20_000_000,
        put_upload_change: &put_upload_change/6,
        consume_upload: &consume_upload/4,
        remove_uploads: &remove_uploads/3,
        list_existing_files: &list_existing_files/1,
        render: fn
          %{value: value} = assigns when is_binary(value) and value != "" ->
            ~H"""
            <a href={@value} target="_blank" rel="noopener noreferrer" class="link link-primary">
              View file
            </a>
            """

          assigns ->
            ~H"<p>{Backpex.HTML.pretty_value(@value)}</p>"
        end,
        except: [:index]
      },
      filename: %{
        module: Backpex.Fields.Text,
        label: "Filename"
      },
      content_type: %{
        module: Backpex.Fields.Text,
        label: "Content Type"
      },
      size: %{
        module: Backpex.Fields.Number,
        label: "Size (bytes)"
      },
      url: %{
        module: Backpex.Fields.Text,
        label: "URL"
      },
      alt_text: %{
        module: Backpex.Fields.Text,
        label: "Alt Text"
      }
    ]
  end

  @impl true
  def on_item_deleted(_socket, item) do
    MediaStorage.delete(item.file_path)
  end

  # ── Upload Callbacks ─────────────────────────────────────

  defp list_existing_files(%{file_path: file_path}) when is_binary(file_path) and file_path != "",
    do: [file_path]

  defp list_existing_files(_item), do: []

  defp put_upload_change(_socket, params, item, uploaded_entries, removed_entries, action) do
    existing_files = list_existing_files(item) -- removed_entries

    new_entries =
      case action do
        :validate ->
          elem(uploaded_entries, 1)

        :insert ->
          elem(uploaded_entries, 0)
      end

    files = existing_files ++ Enum.map(new_entries, fn entry -> entry.client_name end)

    case files do
      [file] ->
        Map.put(params, "file_path", file)

      [_file | _other_files] ->
        Map.put(params, "file_path", "too_many_files")

      [] ->
        Map.put(params, "file_path", "")
    end
  end

  defp consume_upload(_socket, _item, %{path: path} = _meta, entry) do
    case MediaStorage.store(entry, path) do
      {:ok, %{url: url}} ->
        {:ok, url}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp remove_uploads(_socket, _item, removed_entries) do
    for file_path <- removed_entries do
      MediaStorage.delete(file_path)
    end
  end
end
