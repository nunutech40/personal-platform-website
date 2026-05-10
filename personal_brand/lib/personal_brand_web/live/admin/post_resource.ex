defmodule PersonalBrandWeb.Admin.PostResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Post,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Post"

  @impl true
  def plural_name, do: "Posts"

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

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
      excerpt: %{
        module: Backpex.Fields.Textarea,
        label: "Excerpt",
        rows: 3
      },
      content_markdown: %{
        module: PersonalBrandWeb.Admin.Fields.MarkdownEditor,
        label: "Content (Markdown)",
        rows: 18,
        help_text: "Use Markdown for headings, links, lists, images, and code."
      },
      tags: %{
        module: Backpex.Fields.Text,
        label: "Tags (comma separated)"
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [{"Draft", "draft"}, {"Published", "published"}, {"Archived", "archived"}]
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Featured"
      },
      published_at: %{
        module: Backpex.Fields.DateTime,
        label: "Published At"
      },
      reading_time: %{
        module: Backpex.Fields.Number,
        label: "Reading Time (minutes)"
      },
      seo_title: %{
        module: Backpex.Fields.Text,
        label: "SEO Title"
      },
      seo_description: %{
        module: Backpex.Fields.Textarea,
        label: "SEO Description",
        rows: 3
      }
    ]
  end
end
