---
name: pbp-building-admin-backpex-resources
description: Builds admin CRUD using Backpex LiveResource with daisyUI template. Use when creating admin index, form, or resource for any content type. Backpex handles table, form, validation, and actions automatically.
---

# Building Admin Backpex Resources

## Principle

Admin CRUD should use Backpex LiveResource, not manual LiveViews. Backpex provides table listing, form rendering, validation display, and action buttons out of the box. The daisyUI template is already configured in `admin.html.heex` layout.

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
    layout: {PersonalBrandWeb.Layouts, :admin},
    schema: PersonalBrand.Content.MySchema,
    repo: PersonalBrand.Repo,
    subject: PersonalBrand.Content,
    name: "My Resource",
    description: "Manage my resources"

  @impl true
  def fields do
    [
      title: %{
        type: :text,
        label: "Title",
        form_position: 0,
        table_column: %{order: 0}
      },
      slug: %{
        type: :text,
        label: "Slug",
        form_position: 1,
        table_column: %{order: 1}
      },
      status: %{
        type: :select,
        label: "Status",
        options: [
          {"Draft", "draft"},
          {"Published", "published"},
          {"Archived", "archived"}
        ],
        form_position: 2,
        table_column: %{order: 2}
      },
      inserted_at: %{
        type: :date,
        label: "Created",
        form_position: :none,
        table_column: %{order: 3}
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

| Type | Usage | Options |
|------|-------|---------|
| `:text` | Short text input | `label`, `form_position`, `table_column` |
| `:textarea` | Long text / markdown | `label`, `form_position` |
| `:select` | Dropdown | `label`, `options: [{display, value}]` |
| `:date` | Date picker | `label`, `form_position`, `table_column` |
| `:datetime` | DateTime picker | `label`, `form_position` |
| `:boolean` | Checkbox toggle | `label`, `form_position` |
| `:number` | Number input | `label`, `form_position` |
| `:file` | File upload | `label`, `form_position` |

Set `form_position: :none` to exclude a field from the form (e.g., timestamps).

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
