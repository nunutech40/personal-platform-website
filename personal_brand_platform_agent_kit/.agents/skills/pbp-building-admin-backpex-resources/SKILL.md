---
name: pbp-building-admin-backpex-resources
description: Builds admin CRUD using Backpex LiveResource with daisyUI template. Use when creating admin index, form, or resource for any content type. Backpex handles table, form, validation, and actions automatically.
---

# Building Admin Backpex Resources

## Principle

Admin CRUD should use Backpex LiveResource, not manual LiveViews, unless the workflow needs a custom editor that Backpex cannot provide cleanly. Backpex provides table listing, form rendering, validation display, and action buttons out of the box.

The admin shell lives in `lib/personal_brand_web/components/layouts/admin.html.heex`. It is intentionally separate from the public `old_web_classic` theme. Do not reuse public old-web CSS for admin CRUD.

Use `pbp-coding-elixir-functionally` with this skill when implementing context functions, changesets, or custom form fields.

Use `docs/standards/CODING_AND_TESTING_STANDARDS.md` for minimum admin tests.

## When To Use

Use this when:

- creating a new admin resource (index + form)
- adding fields to an existing resource
- customizing form fields or table columns
- adding search/filter to admin index
- adding custom actions (publish, archive, etc.)

## Template Stack

The admin panel uses:

- **Backpex** for CRUD (table, form, validation, actions)
- **daisyUI** for UI components (navbar, sidebar, cards, buttons)
- **Tailwind CSS v4** for utility classes
- **Heroicons** for icons

CSS is already configured in `assets/css/app.css`:

```css
@import "tailwindcss";
@plugin "daisyui";
```

Important admin UI rules:

- Do not edit files under `deps/backpex/`; customize the app layout/resources instead.
- Keep `data-theme="light"` on the admin shell unless dark mode is implemented deliberately.
- Keep admin colors scoped under `.admin-shell` so public old-web CSS does not override Backpex/daisyUI.
- Backpex tables and forms must be readable: light surface, dark text, visible borders, clear hover state.
- After admin UI changes, verify `/admin`, one index resource such as `/admin/projects`, and one form route such as `/admin/projects/new`.
- If a table becomes dark with dark text, fix the app CSS variables/overrides under `.admin-shell`; do not patch generated Backpex HTML.

## Workflow

1. Create Ecto schema + migration + context (if not exists).
2. Create Backpex LiveResource module in `lib/personal_brand_web/live/admin/`.
3. Define resource fields, table columns, and form fields.
4. Add route in router using `live_resources` inside admin scope.
5. Test the resource at `/admin/<resource-path>`.

## Backpex LiveResource Structure

```elixir
defmodule PersonalBrandWeb.Admin.MyResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.MySchema,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "My Resource"

  @impl true
  def plural_name, do: "My Resources"

  @impl true
  def layout(_assigns), do: {PersonalBrandWeb.Layouts, :admin}

  @impl true
  def fields do
    [
      title: %{
        module: Backpex.Fields.Text,
        label: "Title"
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug"
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [{"Draft", "draft"}, {"Published", "published"}, {"Archived", "archived"}]
      }
    ]
  end
end
```

## Route Pattern

```elixir
# In router.ex, inside admin scope with :require_admin pipeline:
live_resources "/my-resources", MyResource,
  only: [:index, :show, :new, :edit, :delete]
```

## Field Type Reference

Use Backpex field modules in this project:

| Module | Usage | Common options |
|------|-------|---------|
| `Backpex.Fields.Text` | Short text input/value | `label`, `searchable`, `orderable` |
| `Backpex.Fields.Textarea` | Long text except post body markdown | `label`, `rows` |
| `PersonalBrandWeb.Admin.Fields.MarkdownEditor` | Post `content_markdown` authoring with toolbar/preview | `label`, `rows`, `help_text` |
| `Backpex.Fields.Select` | Dropdown/status fields | `label`, `options: [{display, value}]` |
| `Backpex.Fields.Date` | Date picker/value | `label` |
| `Backpex.Fields.DateTime` | DateTime picker/value | `label` |
| `Backpex.Fields.Boolean` | Checkbox/toggle | `label` |
| `Backpex.Fields.Number` | Number input/value | `label` |
| `Backpex.Fields.Upload` | File upload | use only after media storage rules are clear |

Prefer the field configuration style already used in `lib/personal_brand_web/live/admin/*_resource.ex`.

## Custom Actions

```elixir
@impl true
def actions(_assigns) do
  [
    publish: %{
      type: :action,
      label: "Publish",
      icon: "hero-check-circle",
      action: fn socket, resource ->
        # Call context function
        case PersonalBrand.Content.publish(resource) do
          {:ok, _} -> {:noreply, put_flash(socket, :info, "Published!")}
          {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to publish")}
        end
      end
    }
  ]
end
```

## Done Checklist

- [ ] Ecto schema + migration exists
- [ ] Context functions exist (list, get, create, update, delete)
- [ ] Backpex LiveResource created with fields
- [ ] Route added with `live_resources`
- [ ] Resource accessible at `/admin/<path>`
- [ ] Form creates and updates records
- [ ] Table lists records with search/filter if needed
- [ ] Custom actions work (publish, archive, etc.)
- [ ] Admin index table is readable in the browser with sufficient contrast
- [ ] Admin resource uses `PersonalBrandWeb.Layouts.admin`
- [ ] Public old-web theme is not affected by admin CSS changes
