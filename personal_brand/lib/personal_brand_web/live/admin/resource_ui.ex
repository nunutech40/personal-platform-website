defmodule PersonalBrandWeb.Admin.ResourceUI do
  use PersonalBrandWeb, :html

  alias Backpex.Router
  require Backpex

  def item_actions_without_bulk_delete(default_actions) do
    case Keyword.fetch(default_actions, :delete) do
      {:ok, delete_action} ->
        Keyword.put(default_actions, :delete, Map.put(delete_action, :only, [:show]))

      :error ->
        default_actions
    end
  end

  attr :item_count, :integer, required: true
  attr :live_resource, :atom, required: true
  attr :socket, :any, required: true
  attr :params, :map, required: true
  attr :query_options, :map, required: true
  attr :active_fields, :list, required: true
  attr :filters_changed, :boolean, required: true
  attr :total_pages, :integer, required: true
  attr :per_page_options, :list, required: true

  def index_main(assigns) do
    ~H"""
    <div class="admin-resource-main">
      <div class="admin-resource-card">
        <div :if={@item_count > 0} class="relative overflow-x-auto">
          <Backpex.HTML.Resource.toggle_columns
            socket={@socket}
            active_fields={@active_fields}
            live_resource={@live_resource}
            current_url={Map.get(assigns, :current_url, @return_to)}
            class="absolute top-2 right-6 z-20 flex justify-end pt-1 font-medium normal-case"
          />
          <Backpex.HTML.Resource.resource_index_table {assigns} />
        </div>

        <.empty_state :if={@item_count == 0} {assigns} />
      </div>

      <div
        :if={@item_count > 0}
        class="mt-4 flex flex-wrap items-center justify-between gap-y-4"
      >
        <Backpex.HTML.Resource.pagination
          path={
            URI.decode(
              Router.get_path(
                @socket,
                @live_resource,
                @params,
                :index,
                Map.merge(@query_options, %{
                  filters_changed: @filters_changed,
                  page: ":page"
                })
              )
            )
          }
          current_page={@query_options.page}
          total_pages={@total_pages}
          next_page_label={Backpex.__("Next Page", @live_resource)}
          previous_page_label={Backpex.__("Previous Page", @live_resource)}
        />
        <div class="flex items-center">
          <Backpex.HTML.Resource.pagination_info
            total={@item_count}
            query_options={@query_options}
            live_resource={@live_resource}
          />
          <Backpex.HTML.Resource.select_per_page
            options={@per_page_options}
            query_options={@query_options}
            live_resource={@live_resource}
          />
        </div>
      </div>
    </div>
    """
  end

  defp empty_state(assigns) do
    assigns =
      assigns
      |> assign(:search_active?, get_in(assigns, [:query_options, :search]) not in [nil, ""])
      |> assign(:filter_active?, get_in(assigns, [:query_options, :filters]) != %{})
      |> assign(:resource_name, assigns.live_resource.plural_name())

    ~H"""
    <section class="admin-empty-state">
      <div class="admin-empty-state-icon">
        <Backpex.HTML.CoreComponents.icon name="hero-folder-plus" class="size-7" />
      </div>

      <p class="admin-empty-eyebrow">{@resource_name}</p>
      <h2>
        <%= cond do %>
          <% @search_active? -> %>
            Tidak ada hasil yang cocok.
          <% @filter_active? -> %>
            Filter belum menemukan data.
          <% true -> %>
            Belum ada data yang dibuat.
        <% end %>
      </h2>

      <p>
        <%= cond do %>
          <% @search_active? -> %>
            Coba pakai kata kunci lain atau kosongkan pencarian.
          <% @filter_active? -> %>
            Ubah filter atau reset supaya semua data terlihat lagi.
          <% true -> %>
            Mulai dengan satu item yang rapi. Nanti list ini akan jadi pusat kontrol konten publik.
        <% end %>
      </p>
    </section>
    """
  end
end
