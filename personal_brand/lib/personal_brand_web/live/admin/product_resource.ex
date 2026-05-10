defmodule PersonalBrandWeb.Admin.ProductResource do
  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: PersonalBrand.Content.Product,
      repo: PersonalBrand.Repo
    ]

  @impl true
  def singular_name, do: "Product"

  @impl true
  def plural_name, do: "Products"

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
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Summary",
        rows: 3
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Description",
        rows: 8
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [
          {"Active", "active"},
          {"Draft", "draft"},
          {"Archived", "archived"},
          {"Coming Soon", "coming_soon"}
        ]
      },
      product_type: %{
        module: Backpex.Fields.Select,
        label: "Product Type",
        options: [{"Digital", "digital"}, {"Physical", "physical"}, {"Service", "service"}]
      },
      price: %{
        module: Backpex.Fields.Number,
        label: "Price"
      },
      currency: %{
        module: Backpex.Fields.Text,
        label: "Currency"
      },
      stock_status: %{
        module: Backpex.Fields.Select,
        label: "Stock Status",
        options: [
          {"In Stock", "in_stock"},
          {"Out of Stock", "out_of_stock"},
          {"Pre-order", "pre_order"}
        ]
      },
      delivery_type: %{
        module: Backpex.Fields.Select,
        label: "Delivery Type",
        options: [
          {"Digital Download", "digital_download"},
          {"Email Delivery", "email_delivery"},
          {"Physical", "physical_delivery"}
        ]
      },
      checkout_url: %{
        module: Backpex.Fields.Text,
        label: "Checkout URL"
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Featured"
      },
      included: %{
        module: Backpex.Fields.Text,
        label: "What's Included (one per line)"
      }
    ]
  end
end
