defmodule PersonalBrandWeb.Router do
  use PersonalBrandWeb, :router
  import Backpex.Router

  @ops_base "/nunu-ops-7f3c"

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

  # Public Routes
  scope "/", PersonalBrandWeb do
    pipe_through :browser

    live "/", PublicLive, :index
    live "/work", PublicLive, :work_index
    live "/work/:slug", PublicLive, :work_detail
    live "/writing", PublicLive, :writing_index
    live "/writing/:slug", PublicLive, :writing_detail
    live "/products", PublicLive, :products_index
    live "/products/:slug", PublicLive, :product_detail
    live "/about", PublicLive, :about_page
    live "/now", PublicLive, :now_page
    live "/contact", PublicLive, :contact_page
    live "/search", PublicLive, :search

    post "/checkout/writing/:slug", CommerceController, :create_post_checkout
    post "/checkout/products/:slug", CommerceController, :create_product_checkout
    get "/payment/success", CommerceController, :payment_success
  end

  scope "/", PersonalBrandWeb do
    pipe_through :api

    get "/health", HealthController, :show
    post "/webhooks/midtrans", CommerceController, :midtrans_webhook
  end

  # Backpex routes (for cookies, etc.)
  scope "/", PersonalBrandWeb do
    pipe_through :browser
    backpex_routes()
  end

  # Protected operations routes
  scope @ops_base, PersonalBrandWeb.Admin do
    pipe_through [:browser, :require_admin]

    live_session :admin, on_mount: Backpex.InitAssigns do
      live "/", DashboardLive, :index

      # Backpex LiveResources
      live_resources("/projects", ProjectResource, only: [:index, :show, :new, :edit, :delete])

      live_resources("/posts", PostResource, only: [:index, :show, :new, :edit, :delete])

      live_resources("/products", ProductResource, only: [:index, :show, :new, :edit, :delete])

      live_resources("/orders", OrderResource, only: [:index, :show])

      live_resources("/media", MediaResource, only: [:index, :show, :new, :edit, :delete])

      live "/site-settings", SiteSettingRedirectLive, :index
      live_resources("/site-settings", SiteSettingResource, only: [:show, :edit])

      live_resources("/themes", ThemeResource, only: [:index, :show, :new, :edit, :delete])

      live_resources("/tags", TagResource, only: [:index, :show, :new, :edit, :delete])
    end
  end

  # Operations auth routes (outside require_admin pipeline)
  scope @ops_base, PersonalBrandWeb.Admin do
    pipe_through :browser

    get "/login", AuthController, :new
    post "/login", AuthController, :create
    get "/logout", AuthController, :delete
  end

  # Fallback routes must stay after explicit auth routes so login remains reachable
  # when the user is not authenticated.
  scope @ops_base, PersonalBrandWeb.Admin do
    pipe_through [:browser, :require_admin]

    get "/*path", FallbackController, :not_found
  end

  scope "/", PersonalBrandWeb do
    pipe_through :browser

    live "/*path", PublicLive, :not_found
  end
end
