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
    status: "active",
    stock_status: "in_stock",
    delivery_type: "digital_download",
    checkout_url: "https://example.com/checkout",
    fulfillment_type: "instant_download",
    requires_shipping: false,
    payment_provider: "midtrans",
    checkout_mode: "manual_link",
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

    test "generates slug from title when slug is missing" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-product"
    end

    test "generates slug from title when slug is blank" do
      attrs = %{@valid_attrs | slug: ""}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-product"
    end

    test "enforces unique slug constraint" do
      %Product{}
      |> Product.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Product{}
               |> Product.changeset(%{@valid_attrs | title: "Another Product"})
               |> Repo.insert()
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
      attrs = %{@valid_attrs | stock_status: "pre_order"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :stock_status) == "pre_order"
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

    test "accepts included items as newline separated admin input" do
      attrs = %{@valid_attrs | included: "Feature A\nFeature B\nFeature C"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :included) == ["Feature A", "Feature B", "Feature C"]
    end

    test "allows blank optional checkout_url from admin forms" do
      attrs = %{@valid_attrs | checkout_url: ""}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :checkout_url) == nil
    end

    test "rejects missing price" do
      attrs = Map.delete(@valid_attrs, :price)
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:price] == ["can't be blank"]
    end

    test "rejects invalid status" do
      attrs = %{@valid_attrs | status: "deleted"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects invalid product_type" do
      attrs = %{@valid_attrs | product_type: "subscription"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects invalid stock_status" do
      attrs = %{@valid_attrs | stock_status: "backordered"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects invalid delivery_type" do
      attrs = %{@valid_attrs | delivery_type: "carrier_pigeon"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects slug with uppercase letters" do
      attrs = %{@valid_attrs | slug: "Test-Product"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects checkout_url without http scheme" do
      attrs = %{@valid_attrs | checkout_url: "example.com/checkout"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects negative price" do
      attrs = %{@valid_attrs | price: Decimal.new("-10.00")}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "rejects currency with wrong length" do
      attrs = %{@valid_attrs | currency: "US"}
      changeset = Product.changeset(%Product{}, attrs)
      refute changeset.valid?
    end

    test "accepts coming_soon status" do
      attrs = %{@valid_attrs | status: "coming_soon"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
    end

    test "accepts out_of_stock status" do
      attrs = %{@valid_attrs | stock_status: "out_of_stock"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
    end

    test "accepts physical delivery type" do
      attrs = %{@valid_attrs | delivery_type: "physical_delivery"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
    end

    test "accepts email delivery type" do
      attrs = %{@valid_attrs | delivery_type: "email_delivery"}
      changeset = Product.changeset(%Product{}, attrs)
      assert changeset.valid?
    end

    test "accepts fulfillment and payment configuration fields" do
      attrs = %{
        @valid_attrs
        | fulfillment_type: "physical_shipping",
          requires_shipping: true,
          payment_provider: "manual_link",
          checkout_mode: "midtrans_snap"
      }

      changeset = Product.changeset(%Product{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :fulfillment_type) == "physical_shipping"
      assert get_field(changeset, :requires_shipping) == true
      assert get_field(changeset, :payment_provider) == "manual_link"
      assert get_field(changeset, :checkout_mode) == "midtrans_snap"
    end

    test "rejects invalid fulfillment and payment configuration fields" do
      attrs = %{
        @valid_attrs
        | fulfillment_type: "unsupported",
          payment_provider: "stripe",
          checkout_mode: "cart"
      }

      changeset = Product.changeset(%Product{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset)[:fulfillment_type]
      assert "is invalid" in errors_on(changeset)[:payment_provider]
      assert "is invalid" in errors_on(changeset)[:checkout_mode]
    end
  end
end
