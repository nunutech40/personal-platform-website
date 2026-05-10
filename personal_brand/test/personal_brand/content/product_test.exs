defmodule PersonalBrand.Content.ProductTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Product

  @valid_attrs %{
    title: "Test Product",
    slug: "test-product",
    summary: "A test product",
    description: "Full description",
    product_type: "digital",
    price: Decimal.new("29.00"),
    currency: "USD",
    stock_status: "in_stock",
    delivery_type: "digital_download",
    checkout_url: "https://example.com/checkout",
    featured: false,
    included: ["Item 1", "Item 2"]
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing title" do
      attrs = Map.delete(@valid_attrs, :title)
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:title] == ["can't be blank"]
    end

    test "rejects missing slug" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:slug] == ["can't be blank"]
    end

    test "enforces unique slug constraint" do
      %Product{}
      |> Product.changeset(@valid_attrs)
      |> Repo.insert!()

      changeset =
        %Product{}
        |> Product.changeset(%{@valid_attrs | title: "Another Product"})
        |> Repo.insert()

      assert {:error, changeset} = changeset
    end

    test "sets default product_type to digital" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert get_field(changeset, :product_type) == "digital"
    end

    test "sets default currency to USD" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert get_field(changeset, :currency) == "USD"
    end

    test "sets default stock_status to in_stock" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert get_field(changeset, :stock_status) == "in_stock"
    end

    test "sets default delivery_type to digital_download" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert get_field(changeset, :delivery_type) == "digital_download"
    end

    test "accepts physical product type" do
      attrs = %{@valid_attrs | product_type: "physical"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :product_type) == "physical"
    end

    test "accepts service product type" do
      attrs = %{@valid_attrs | product_type: "service"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :product_type) == "service"
    end

    test "accepts preorder stock status" do
      attrs = %{@valid_attrs | stock_status: "preorder"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :stock_status) == "preorder"
    end

    test "accepts decimal price" do
      changeset = Product.changeset(%Product{}, @valid_attrs)
      assert changeset.valid?
      assert get_field(changeset, :price) == Decimal.new("29.00")
    end

    test "accepts included items as array" do
      attrs = %{@valid_attrs | included: ["Feature A", "Feature B", "Feature C"]}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :included) == ["Feature A", "Feature B", "Feature C"]
    end
  end
end
