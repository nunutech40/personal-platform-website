defmodule PersonalBrandWeb.Admin.AuthHTML do
  use PersonalBrandWeb, :html

  embed_templates "auth_html/*"

  def render("new.html", assigns) do
    ~H"""
    <div class="mx-auto max-w-md mt-20 px-4">
      <h1 class="text-2xl font-bold mb-6 text-center">Admin Login</h1>

      <%= if assigns[:error] do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {@error}
        </div>
      <% end %>

      <form action="/admin/login" method="post" class="space-y-4">
        <input type="hidden" name="_csrf_token" value={get_csrf_token()} />

        <div>
          <label for="username" class="block text-sm font-medium mb-1">Username</label>
          <input
            type="text"
            name="username"
            id="username"
            required
            class="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        <div>
          <label for="password" class="block text-sm font-medium mb-1">Password</label>
          <input
            type="password"
            name="password"
            id="password"
            required
            class="w-full border border-gray-300 rounded px-3 py-2"
          />
        </div>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white rounded px-4 py-2 hover:bg-blue-700"
        >
          Sign In
        </button>
      </form>
    </div>
    """
  end
end
