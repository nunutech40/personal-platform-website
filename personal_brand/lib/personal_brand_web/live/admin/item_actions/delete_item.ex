defmodule PersonalBrandWeb.Admin.ItemActions.DeleteItem do
  @moduledoc """
  Custom delete item action with Indonesian confirmation message
  and clearer UX than the default Backpex delete action.
  """

  use BackpexWeb, :item_action

  alias Backpex.Resource

  require Logger

  @impl Backpex.ItemAction
  def icon(assigns, _item) do
    ~H"""
    <Backpex.HTML.CoreComponents.icon
      name="hero-trash"
      class="h-5 w-5 cursor-pointer transition duration-75 hover:scale-110 hover:text-red-600"
    />
    """
  end

  @impl Backpex.ItemAction
  def label(_assigns, _item), do: "Hapus"

  @impl Backpex.ItemAction
  def confirm(assigns) do
    item = List.first(assigns.selected_items)
    title = if item, do: item.title, else: "item ini"

    "Yakin hapus \"#{title}\"? Data yang dihapus tidak bisa dikembalikan."
  end

  @impl Backpex.ItemAction
  def confirm_label(_assigns), do: "Ya, Hapus"

  @impl Backpex.ItemAction
  def cancel_label(_assigns), do: "Batal"

  @impl Backpex.ItemAction
  def handle(socket, items, _data) do
    {:ok, deleted_items} = Resource.delete_all(items, socket.assigns.live_resource)

    Enum.each(deleted_items, fn deleted_item ->
      socket.assigns.live_resource.on_item_deleted(socket, deleted_item)
    end)

    socket
    |> clear_flash()
    |> put_flash(:info, success_message(deleted_items, socket.assigns))
    |> ok()
  rescue
    error ->
      Logger.error("An error occurred while deleting the resource: #{inspect(error)}")

      socket
      |> clear_flash()
      |> put_flash(:error, error_message(error, items))
      |> ok()
  end

  defp success_message([item], _assigns) do
    "\"#{item.title}\" berhasil dihapus."
  end

  defp success_message(items, _assigns) do
    "#{Enum.count(items)} item berhasil dihapus."
  end

  defp error_message(%Postgrex.Error{postgres: %{code: :foreign_key_violation}}, [_item]) do
    "Gagal menghapus. Item ini masih digunakan di tempat lain."
  end

  defp error_message(%Ecto.ConstraintError{type: :foreign_key}, [_item]) do
    "Gagal menghapus. Item ini masih digunakan di tempat lain."
  end

  defp error_message(_error, _items) do
    "Terjadi kesalahan saat menghapus. Coba lagi."
  end
end
