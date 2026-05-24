defmodule PersonalBrandWeb.Admin.DashboardLive do
  use PersonalBrandWeb, :live_view

  alias PersonalBrand.Content

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin Dashboard")
      |> assign(:current_url, "/nunu-ops-7f3c")
      |> assign(:summary, Content.admin_dashboard_summary())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_url={@current_url}>
      <div class="space-y-8">
        <section class="flex flex-col justify-between gap-4 lg:flex-row lg:items-end">
          <div>
            <p class="text-sm font-semibold uppercase tracking-[0.18em] text-blue-600">
              Back Office
            </p>
            <h1 class="mt-2 text-4xl font-bold tracking-normal text-slate-950">Dashboard</h1>
            <p class="mt-2 max-w-2xl text-base text-slate-500">
              Manage portfolio work, writing, products, media, and public site settings from one CMS.
            </p>
          </div>

          <div class="flex flex-wrap gap-2">
            <.link
              navigate={~p"/nunu-ops-7f3c/posts/new"}
              class="btn btn-primary bg-blue-600 text-white hover:bg-blue-700"
            >
              New Post
            </.link>
            <.link
              navigate={~p"/nunu-ops-7f3c/projects/new"}
              class="btn btn-outline border-slate-300 text-slate-700"
            >
              New Project
            </.link>
          </div>
        </section>

        <section class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
          <.metric_card
            label="Projects"
            value={@summary.counts.projects}
            detail={"#{@summary.drafts.projects} drafts"}
            href={~p"/nunu-ops-7f3c/projects"}
          />
          <.metric_card
            label="Posts"
            value={@summary.counts.posts}
            detail={"#{@summary.drafts.posts} drafts"}
            href={~p"/nunu-ops-7f3c/posts"}
          />
          <.metric_card
            label="Products"
            value={@summary.counts.products}
            detail="Catalog entries"
            href={~p"/nunu-ops-7f3c/products"}
          />
          <.metric_card
            label="Media"
            value={@summary.counts.media}
            detail="Library assets"
            href={~p"/nunu-ops-7f3c/media"}
          />
        </section>

        <section class="grid grid-cols-1 gap-6 xl:grid-cols-[minmax(0,1fr)_360px]">
          <div class="admin-panel">
            <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-6 py-5">
              <div>
                <h2 class="text-xl font-bold tracking-normal text-slate-950">Recent Content</h2>
                <p class="text-sm text-slate-500">
                  Latest updates across posts, projects, and products.
                </p>
              </div>
              <.link navigate={~p"/nunu-ops-7f3c/posts"} class="btn btn-sm btn-ghost text-blue-700">
                Open Posts
              </.link>
            </div>

            <div class="divide-y divide-slate-100">
              <%= for item <- recent_items(@summary) do %>
                <div class="grid gap-3 px-6 py-4 sm:grid-cols-[120px_minmax(0,1fr)_120px] sm:items-center">
                  <span class="admin-badge">{item.type}</span>
                  <div class="min-w-0">
                    <p class="truncate font-semibold text-slate-900">{item.title}</p>
                    <p class="truncate text-sm text-slate-500">/{item.slug}</p>
                  </div>
                  <span class="text-sm text-slate-500 sm:text-right">
                    {format_date(item.inserted_at)}
                  </span>
                </div>
              <% end %>
            </div>
          </div>

          <aside class="space-y-6">
            <div class="admin-panel p-6">
              <h2 class="text-xl font-bold tracking-normal text-slate-950">Publish Settings</h2>
              <dl class="mt-5 space-y-3 text-sm">
                <div class="flex justify-between gap-4">
                  <dt class="font-medium text-slate-500">Active theme</dt>
                  <dd class="font-semibold text-slate-900">{@summary.active_theme}</dd>
                </div>
                <div class="flex justify-between gap-4">
                  <dt class="font-medium text-slate-500">Post drafts</dt>
                  <dd class="font-semibold text-slate-900">{@summary.drafts.posts}</dd>
                </div>
                <div class="flex justify-between gap-4">
                  <dt class="font-medium text-slate-500">Project drafts</dt>
                  <dd class="font-semibold text-slate-900">{@summary.drafts.projects}</dd>
                </div>
              </dl>
            </div>

            <div class="admin-panel p-6">
              <h2 class="text-xl font-bold tracking-normal text-slate-950">Quick Actions</h2>
              <div class="mt-5 grid gap-2">
                <.link
                  navigate={~p"/nunu-ops-7f3c/site-settings"}
                  class="btn btn-outline justify-start border-slate-300 text-slate-700"
                >
                  Site Settings
                </.link>
                <.link
                  navigate={~p"/nunu-ops-7f3c/themes"}
                  class="btn btn-outline justify-start border-slate-300 text-slate-700"
                >
                  Theme Settings
                </.link>
                <.link
                  navigate={~p"/nunu-ops-7f3c/products/new"}
                  class="btn btn-outline justify-start border-slate-300 text-slate-700"
                >
                  Add Product
                </.link>
              </div>
            </div>
          </aside>
        </section>
      </div>
    </Layouts.admin>
    """
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :detail, :string, required: true
  attr :href, :string, required: true

  def metric_card(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class="admin-panel block p-6 no-underline transition hover:-translate-y-0.5 hover:border-blue-200 hover:shadow-md"
    >
      <span class="text-sm font-semibold uppercase tracking-[0.14em] text-slate-500">{@label}</span>
      <span class="mt-3 block text-4xl font-bold tracking-normal text-slate-950">{@value}</span>
      <span class="mt-2 block text-sm text-slate-500">{@detail}</span>
    </.link>
    """
  end

  defp recent_items(summary) do
    summary.latest_posts
    |> Enum.map(&recent_item("Post", &1))
    |> Kernel.++(Enum.map(summary.latest_projects, &recent_item("Project", &1)))
    |> Kernel.++(Enum.map(summary.latest_products, &recent_item("Product", &1)))
    |> Enum.sort_by(&sort_timestamp/1, :desc)
    |> Enum.take(8)
  end

  defp recent_item(type, item) do
    %{
      type: type,
      title: item.title || "Untitled",
      slug: item.slug || "",
      inserted_at: item.inserted_at
    }
  end

  defp format_date(nil), do: "No date"

  defp format_date(%NaiveDateTime{} = datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%b %d, %Y")
  end

  defp format_date(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> Calendar.strftime("%b %d, %Y")
  end

  defp sort_timestamp(%{inserted_at: nil}), do: 0
  defp sort_timestamp(%{inserted_at: %DateTime{} = datetime}), do: DateTime.to_unix(datetime)

  defp sort_timestamp(%{inserted_at: %NaiveDateTime{} = datetime}) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
