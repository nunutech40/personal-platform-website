defmodule PersonalBrand.Content.PostTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Post

  @valid_attrs %{
    title: "Test Post",
    slug: "test-post",
    excerpt: "A test excerpt",
    content_markdown: "# Hello",
    content_html: "<h1>Hello</h1>",
    tags: ["Elixir", "Phoenix"],
    status: "draft",
    featured: false,
    published_at: ~U[2026-01-01 00:00:00Z],
    reading_time: 5,
    seo_title: nil,
    seo_description: nil,
    editor_type: nil
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert changeset.valid?
    end

    test "renders markdown to sanitized content_html" do
      attrs = %{
        @valid_attrs
        | content_markdown:
            "## Intro\n\n![Diagram](/uploads/media/diagram.png)\n\n<script>alert('x')</script>"
      }

      changeset = Post.changeset(%Post{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :content_html) =~ "<h2>Intro</h2>"

      assert get_field(changeset, :content_html) =~
               ~s(<img src="/uploads/media/diagram.png" alt="Diagram">)

      refute get_field(changeset, :content_html) =~ "<script>"
    end

    test "supports multiple positional markdown images" do
      attrs = %{
        @valid_attrs
        | content_markdown:
            "Before\n\n![One](/uploads/media/one.png)\n\nMiddle\n\n![Two](https://example.com/two.png)\n\nAfter"
      }

      changeset = Post.changeset(%Post{}, attrs)
      html = get_field(changeset, :content_html)

      assert html =~ "Before"
      assert html =~ ~s(src="/uploads/media/one.png")
      assert html =~ "Middle"
      assert html =~ ~s(src="https://example.com/two.png")
      assert html =~ "After"
    end

    test "rejects missing title" do
      attrs = Map.delete(@valid_attrs, :title)
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:title] == ["can't be blank"]
    end

    test "generates slug from title when slug is missing" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-post"
    end

    test "generates slug from title when slug is blank" do
      attrs = %{@valid_attrs | slug: ""}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :slug) == "test-post"
    end

    test "enforces unique slug constraint" do
      %Post{}
      |> Post.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Post{}
               |> Post.changeset(%{@valid_attrs | title: "Another Post"})
               |> Repo.insert()
    end

    test "sets default status to draft" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert get_field(changeset, :status) == "draft"
    end

    test "sets default featured to false" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert get_field(changeset, :featured) == false
    end

    test "sets default clap_count to zero" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert get_field(changeset, :clap_count) == 0
    end

    test "accepts published status with published_at" do
      attrs = %{@valid_attrs | status: "published"}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :status) == "published"
    end

    test "accepts tags as array" do
      attrs = %{@valid_attrs | tags: ["Elixir", "Phoenix", "Testing"]}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :tags) == ["Elixir", "Phoenix", "Testing"]
    end

    test "accepts tags as comma or newline separated admin input" do
      attrs = %{@valid_attrs | tags: "Elixir, Phoenix\nLiveView"}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :tags) == ["Elixir", "Phoenix", "LiveView"]
    end

    test "accepts seo fields" do
      attrs =
        Map.merge(@valid_attrs, %{seo_title: "SEO Title", seo_description: "SEO Description"})

      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :seo_title) == "SEO Title"
      assert get_field(changeset, :seo_description) == "SEO Description"
    end

    test "rejects invalid status" do
      attrs = %{@valid_attrs | status: "deleted"}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects slug with uppercase letters" do
      attrs = %{@valid_attrs | slug: "Test-Post"}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects slug with spaces" do
      attrs = %{@valid_attrs | slug: "test post"}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects reading_time below minimum" do
      attrs = %{@valid_attrs | reading_time: 0}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects reading_time above maximum" do
      attrs = %{@valid_attrs | reading_time: 121}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects seo_title exceeding max length" do
      attrs = %{@valid_attrs | seo_title: String.duplicate("a", 71)}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects seo_description exceeding max length" do
      attrs = %{@valid_attrs | seo_description: String.duplicate("a", 161)}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "rejects invalid editor_type" do
      attrs = %{@valid_attrs | editor_type: "wysiwyg"}
      changeset = Post.changeset(%Post{}, attrs)
      refute changeset.valid?
    end

    test "accepts rich_text editor_type" do
      attrs = %{@valid_attrs | editor_type: "rich_text"}
      changeset = Post.changeset(%Post{}, attrs)
      assert changeset.valid?
    end

    test "accepts monetization fields and normalizes admin textarea input" do
      attrs =
        Map.merge(@valid_attrs, %{
          access_type: "tips",
          tip_amount_options: "10000\n15000, 20000",
          payment_provider: "",
          checkout_url: "",
          currency: ""
        })

      changeset = Post.changeset(%Post{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :access_type) == "tips"
      assert get_field(changeset, :tip_amount_options) == [10000, 15000, 20000]
      assert get_field(changeset, :payment_provider) == "midtrans"
      assert get_field(changeset, :checkout_url) == nil
      assert get_field(changeset, :currency) == "IDR"
    end

    test "requires tips amount options for tips posts" do
      attrs = Map.merge(@valid_attrs, %{access_type: "tips", tip_amount_options: ""})

      changeset = Post.changeset(%Post{}, attrs)

      refute changeset.valid?

      assert "must contain at least one amount for tips posts" in errors_on(changeset)[
               :tip_amount_options
             ]
    end

    test "requires positive price for paid posts" do
      attrs = Map.merge(@valid_attrs, %{access_type: "paid", price: nil})

      changeset = Post.changeset(%Post{}, attrs)

      refute changeset.valid?
      assert "must be greater than 0 for paid posts" in errors_on(changeset)[:price]
    end

    test "can switch a post from paid to tips" do
      paid_post =
        %Post{}
        |> Post.changeset(
          Map.merge(@valid_attrs, %{access_type: "paid", price: Decimal.new("25000")})
        )
        |> Repo.insert!()

      changeset =
        Post.changeset(paid_post, %{
          access_type: "tips",
          price: nil,
          tip_amount_options: "10000\n20000",
          paywall_cta: "Tips dulu buat lanjut baca"
        })

      assert changeset.valid?
      assert get_field(changeset, :access_type) == "tips"
      assert get_field(changeset, :tip_amount_options) == [10000, 20000]
    end

    test "can switch a post from tips to free or paid" do
      tips_post =
        %Post{}
        |> Post.changeset(
          Map.merge(@valid_attrs, %{access_type: "tips", tip_amount_options: [10000, 15000]})
        )
        |> Repo.insert!()

      free_changeset = Post.changeset(tips_post, %{access_type: "free", price: nil})

      assert free_changeset.valid?
      assert get_field(free_changeset, :access_type) == "free"

      paid_changeset =
        Post.changeset(tips_post, %{access_type: "paid", price: Decimal.new("30000")})

      assert paid_changeset.valid?
      assert get_field(paid_changeset, :access_type) == "paid"
      assert get_field(paid_changeset, :price) == Decimal.new("30000")
    end

    test "does not overwrite existing access type when update attrs omit it" do
      tips_post =
        %Post{}
        |> Post.changeset(
          Map.merge(@valid_attrs, %{access_type: "tips", tip_amount_options: [10000, 15000]})
        )
        |> Repo.insert!()

      changeset = Post.changeset(tips_post, %{title: "Updated title"})

      assert changeset.valid?
      assert get_field(changeset, :access_type) == "tips"
    end

    test "rejects invalid tip amount options" do
      attrs = Map.merge(@valid_attrs, %{access_type: "tips", tip_amount_options: "10000\nnope"})

      changeset = Post.changeset(%Post{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset)[:tip_amount_options]
    end

    test "free posts ignore inactive monetization fields" do
      attrs =
        Map.merge(@valid_attrs, %{
          access_type: "free",
          price: "not-a-number",
          tip_amount_options: "nope",
          checkout_url: "example.com/pay",
          currency: "idr"
        })

      changeset = Post.changeset(%Post{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :access_type) == "free"
      assert get_field(changeset, :price) == nil
      assert get_field(changeset, :tip_amount_options) == []
      assert get_field(changeset, :checkout_url) == nil
      assert get_field(changeset, :currency) == "IDR"
    end

    test "rejects invalid checkout URL and currency for monetized posts" do
      attrs =
        Map.merge(@valid_attrs, %{
          access_type: "paid",
          price: Decimal.new("25000"),
          checkout_url: "example.com/pay",
          currency: "idr"
        })

      changeset = Post.changeset(%Post{}, attrs)

      refute changeset.valid?
      assert "must start with http:// or https://" in errors_on(changeset)[:checkout_url]
      assert "must be a 3-letter currency code" in errors_on(changeset)[:currency]
    end

    test "requires checkout URL when monetized post uses manual link" do
      attrs =
        Map.merge(@valid_attrs, %{
          access_type: "paid",
          price: Decimal.new("25000"),
          payment_provider: "manual_link",
          checkout_url: ""
        })

      changeset = Post.changeset(%Post{}, attrs)

      refute changeset.valid?

      assert "is required when payment provider is Manual Link" in errors_on(changeset)[
               :checkout_url
             ]
    end
  end
end
