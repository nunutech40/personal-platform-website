defmodule PersonalBrandWeb.PageController do
  use PersonalBrandWeb, :controller

  def index(conn, _params) do
    # Public homepage is now handled by PublicLive LiveView
    # This controller is kept for backward compatibility
    # and will redirect to the LiveView route
    redirect(conn, to: "/")
  end
end
