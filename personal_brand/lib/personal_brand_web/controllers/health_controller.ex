defmodule PersonalBrandWeb.HealthController do
  use PersonalBrandWeb, :controller

  def show(conn, _params) do
    text(conn, "ok")
  end
end
