defmodule PersonalBrandWeb.Admin.AuthHTML do
  use PersonalBrandWeb, :html

  embed_templates "auth_html/*"

  def render("new.html", assigns) do
    ~H"""
    <div class="admin-login flex items-center justify-center px-4 py-12">
      <div class="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-xl shadow-slate-200/60">
        <div class="mb-8">
          <p class="text-sm font-semibold uppercase tracking-[0.18em] text-blue-600">
            Personal Brand CMS
          </p>
          <h1 class="mt-2 text-3xl font-bold text-slate-950">Nunu Admin</h1>
          <p class="mt-2 text-sm text-slate-500">Sign in to manage content and site settings.</p>
        </div>

        <%= if assigns[:error] do %>
          <div class="mb-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
            {@error}
          </div>
        <% end %>

        <form action="/nunu-ops-7f3c/login" method="post" class="space-y-4">
          <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

          <div>
            <label for="username" class="mb-1 block text-sm font-semibold text-slate-700">
              Username
            </label>
            <input
              type="text"
              name="username"
              id="username"
              placeholder="Username"
              autocomplete="username"
              required
              class="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-950 outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
            />
          </div>

          <div>
            <label for="password" class="mb-1 block text-sm font-semibold text-slate-700">
              Password
            </label>
            <input
              type="password"
              name="password"
              id="password"
              placeholder="Password"
              autocomplete="current-password"
              required
              class="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-950 outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
            />
          </div>

          <button
            type="submit"
            class="w-full rounded-xl border border-blue-600 bg-blue-600 px-4 py-3 font-semibold text-white transition hover:bg-blue-700"
          >
            Sign In
          </button>
        </form>
      </div>
    </div>
    """
  end
end
