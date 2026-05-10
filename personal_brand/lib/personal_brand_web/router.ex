defmodule PersonalBrandWeb.Router do
  use PersonalBrandWeb, :router
  import Backpex.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PersonalBrandWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Admin authentication pipeline
  pipeline :require_admin do
    plug PersonalBrandWeb.Plugs.RequireAdmin
  end

  # Root redirect - cek session, kalo udah login ke /admin, kalo belum ke /admin/login
  scope "/", PersonalBrandWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Admin routes (protected)
  scope "/admin", PersonalBrandWeb.Admin do
    pipe_through [:browser, :require_admin]

    live "/", DashboardLive, :index

    # Backpex LiveResources
    live_resources "/projects", ProjectResource,
      only: [:index, :show, :new, :edit, :delete]

    live_resources "/posts", PostResource,
      only: [:index, :show, :new, :edit, :delete]

    live_resources "/products", ProductResource,
      only: [:index, :show, :new, :edit, :delete]

    live_resources "/media", MediaResource,
      only: [:index, :show, :new, :edit, :delete]

    live_resources "/site-settings", SiteSettingResource,
      only: [:index, :show, :new, :edit, :delete]

    live_resources "/themes", ThemeResource,
      only: [:index, :show, :new, :edit, :delete]
  end

  # Admin auth routes (outside require_admin pipeline)
  scope "/admin", PersonalBrandWeb.Admin do
    pipe_through :browser

    get "/login", AuthController, :new
    post "/login", AuthController, :create
    get "/logout", AuthController, :delete
  end
end
