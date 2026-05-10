defmodule PersonalBrand.MediaStorage do
  @moduledoc """
  Handles local disk storage for uploaded media files.

  Files are stored under `priv/static/uploads/media/` and served
  via Phoenix static file serving at `/uploads/media/...`.
  """

  @upload_dir "uploads/media"

  @doc """
  Returns the absolute path to the upload directory.
  """
  def upload_dir do
    Path.join([:code.priv_dir(:personal_brand), "static", @upload_dir])
  end

  @doc """
  Returns the public URL path for a given filename.
  """
  def public_url(filename) do
    "/" <> Path.join(@upload_dir, filename)
  end

  @doc """
  Copies an uploaded file from a temporary path to the media storage directory.

  Returns `{:ok, %{filename: filename, file_path: relative_path, url: public_url}}`
  or `{:error, reason}`.
  """
  def store(entry, path) do
    filename = generate_filename(entry)
    dest = Path.join(upload_dir(), filename)

    # Ensure the upload directory exists
    File.mkdir_p!(upload_dir())

    case File.cp(path, dest) do
      :ok ->
        {:ok,
         %{
           filename: filename,
           file_path: Path.join(@upload_dir, filename),
           url: public_url(filename)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a file from media storage by its relative file path.
  """
  def delete(file_path) when is_binary(file_path) do
    absolute_path = Path.join([:code.priv_dir(:personal_brand), "static", file_path])
    File.rm(absolute_path)
  end

  def delete(_), do: :ok

  @doc """
  Generates a unique filename for an upload entry.
  """
  def generate_filename(entry) do
    ext = entry.client_name |> Path.extname() |> String.downcase()
    "#{entry.uuid}#{ext}"
  end
end
