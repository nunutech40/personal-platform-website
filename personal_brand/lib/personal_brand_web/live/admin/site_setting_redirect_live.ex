defmodule PersonalBrandWeb.Admin.SiteSettingRedirectLive do
  use PersonalBrandWeb, :live_view

  alias PersonalBrand.Content

  @impl true
  def mount(_params, _session, socket) do
    case Content.get_site_settings() do
      nil ->
        socket =
          socket
          |> put_flash(
            :error,
            "Site Settings belum tersedia. Jalankan seed atau restore data settings dulu."
          )
          |> push_navigate(to: ~p"/admin")

        {:ok, socket}

      settings ->
        {:ok, push_navigate(socket, to: ~p"/admin/site-settings/#{settings.id}/edit")}
    end
  end

  @impl true
  def render(assigns), do: ~H""
end
