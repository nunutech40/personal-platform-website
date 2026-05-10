defmodule PersonalBrandWeb.Admin.DashboardLive do
  use PersonalBrandWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "Admin Dashboard")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-8">Dashboard</h1>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="stat bg-base-100 rounded-box shadow-sm border border-base-200">
          <div class="stat-title">Projects</div>
          <div class="stat-value text-primary">0</div>
          <div class="stat-actions">
            <.link navigate="/admin/projects" class="btn btn-sm btn-outline btn-primary">Manage</.link>
          </div>
        </div>
        <div class="stat bg-base-100 rounded-box shadow-sm border border-base-200">
          <div class="stat-title">Posts</div>
          <div class="stat-value text-secondary">0</div>
          <div class="stat-actions">
            <.link navigate="/admin/posts" class="btn btn-sm btn-outline btn-secondary">Manage</.link>
          </div>
        </div>
        <div class="stat bg-base-100 rounded-box shadow-sm border border-base-200">
          <div class="stat-title">Products</div>
          <div class="stat-value text-accent">0</div>
          <div class="stat-actions">
            <.link navigate="/admin/products" class="btn btn-sm btn-outline btn-accent">Manage</.link>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm border border-base-200">
        <div class="card-body">
          <h2 class="card-title">Quick Links</h2>
          <div class="flex flex-wrap gap-2">
            <.link navigate="/admin/projects" class="btn btn-ghost btn-sm">Projects</.link>
            <.link navigate="/admin/posts" class="btn btn-ghost btn-sm">Posts</.link>
            <.link navigate="/admin/products" class="btn btn-ghost btn-sm">Products</.link>
            <.link navigate="/admin/media" class="btn btn-ghost btn-sm">Media</.link>
            <.link navigate="/admin/site-settings" class="btn btn-ghost btn-sm">Site Settings</.link>
            <.link navigate="/admin/themes" class="btn btn-ghost btn-sm">Themes</.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
