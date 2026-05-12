defmodule PersonalBrand.Content.SiteSettingTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.SiteSetting

  @valid_attrs %{
    site_name: "My Site",
    headline: "Welcome",
    subheadline: "Subtitle",
    primary_cta_text: "Get Started",
    primary_cta_url: "/start",
    secondary_cta_text: "Learn More",
    secondary_cta_url: "/learn",
    active_theme: "old_web_classic",
    profile_name: "John Doe",
    profile_title: "Developer",
    profile_location: "Jakarta",
    profile_email: "john@example.com",
    profile_bio: "A developer",
    about_intro: "I build useful software.",
    about_focus: "Mobile and web platforms.",
    about_tools: ["Elixir", "Flutter"],
    about_values: ["Readable code", "Useful products"],
    now_building: "Personal platform",
    now_learning: "Payment flows",
    now_focus: "Portfolio polish",
    now_updated_at: ~D[2026-05-12],
    saweria_url: "https://saweria.co/nunu",
    buy_me_coffee_url: "https://www.buymeacoffee.com/nunu",
    tips_cta_title: "Support this writing",
    tips_cta_body: "If this helped, tips are welcome.",
    xendit_checkout_url: "https://checkout.xendit.co/example",
    xendit_webhook_url: "https://example.com/webhooks/xendit"
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = SiteSetting.changeset(%SiteSetting{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing required fields" do
      changeset = SiteSetting.changeset(%SiteSetting{}, %{site_name: "My Site"})
      refute changeset.valid?
      assert errors_on(changeset)[:headline] == ["can't be blank"]
    end

    test "sets default site_name" do
      changeset = SiteSetting.changeset(%SiteSetting{}, %{})
      assert get_field(changeset, :site_name) == "Nunu Nugraha"
    end

    test "sets default active_theme" do
      changeset = SiteSetting.changeset(%SiteSetting{}, %{})
      assert get_field(changeset, :active_theme) == "old_web_classic"
    end

    test "sets default CTA texts" do
      changeset = SiteSetting.changeset(%SiteSetting{}, %{})
      assert get_field(changeset, :primary_cta_text) == "View Work"
      assert get_field(changeset, :secondary_cta_text) == "Read Writing"
    end

    test "accepts social_links as map" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com",
        social_links: %{"GitHub" => "https://github.com/john", "X" => "https://x.com/john"}
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?

      assert get_field(changeset, :social_links) == %{
               "GitHub" => "https://github.com/john",
               "X" => "https://x.com/john"
             }
    end

    test "accepts social links as key value lines from admin forms" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com",
        social_links: "GitHub=https://github.com/john\nLinkedIn=https://linkedin.com/in/john"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?

      assert get_field(changeset, :social_links) == %{
               "GitHub" => "https://github.com/john",
               "LinkedIn" => "https://linkedin.com/in/john"
             }
    end

    test "accepts public page, support, and payment link settings" do
      changeset =
        SiteSetting.changeset(%SiteSetting{}, %{
          @valid_attrs
          | about_tools: "Elixir\nPhoenix LiveView\nFlutter",
            about_values: "Useful products\nReadable code",
            now_updated_at: "2026-05-12",
            saweria_url: "",
            buy_me_coffee_url: "https://www.buymeacoffee.com/nunu",
            xendit_checkout_url: "https://checkout.xendit.co/example",
            xendit_webhook_url: ""
        })

      assert changeset.valid?
      assert get_field(changeset, :about_tools) == ["Elixir", "Phoenix LiveView", "Flutter"]
      assert get_field(changeset, :about_values) == ["Useful products", "Readable code"]
      assert get_field(changeset, :now_updated_at) == ~D[2026-05-12]
      assert get_field(changeset, :saweria_url) == nil
      assert get_field(changeset, :xendit_webhook_url) == nil
    end

    test "rejects invalid support and payment URLs" do
      attrs = %{
        @valid_attrs
        | saweria_url: "saweria.co/nunu",
          buy_me_coffee_url: "buymeacoffee.com/nunu",
          xendit_checkout_url: "checkout.xendit.co/example",
          xendit_webhook_url: "/webhooks/xendit"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
      assert "must start with http:// or https://" in errors_on(changeset)[:saweria_url]
      assert "must start with http:// or https://" in errors_on(changeset)[:buy_me_coffee_url]
      assert "must start with http:// or https://" in errors_on(changeset)[:xendit_checkout_url]
      assert "must start with http:// or https://" in errors_on(changeset)[:xendit_webhook_url]
    end

    test "accepts featured IDs as arrays" do
      id1 = Ecto.UUID.generate()
      id2 = Ecto.UUID.generate()

      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com",
        featured_project_ids: [id1, id2],
        featured_product_ids: [id2]
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :featured_project_ids) == [id1, id2]
      assert get_field(changeset, :featured_product_ids) == [id2]
    end

    test "accepts featured IDs as newline separated admin input" do
      id1 = Ecto.UUID.generate()
      id2 = Ecto.UUID.generate()

      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com",
        featured_project_ids: "#{id1}\n#{id2}",
        featured_product_ids: id2
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :featured_project_ids) == [id1, id2]
      assert get_field(changeset, :featured_product_ids) == [id2]
    end

    test "rejects invalid email format" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "not-an-email"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:profile_email] == ["must be a valid email address"]
    end

    test "rejects missing profile_email" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:profile_email] == ["can't be blank"]
    end

    test "rejects primary_cta_url without leading slash" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "https://example.com",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
    end

    test "rejects secondary_cta_url without leading slash" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        secondary_cta_text: "Learn More",
        secondary_cta_url: "https://example.com",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
    end

    test "rejects missing headline" do
      attrs = %{
        site_name: "My Site",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:headline] == ["can't be blank"]
    end

    test "rejects site_name exceeding max length" do
      attrs = %{
        site_name: String.duplicate("a", 101),
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_name: "John Doe",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
    end

    test "rejects missing profile_name" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "old_web_classic",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:profile_name] == ["can't be blank"]
    end

    test "rejects invalid active_theme key format" do
      attrs = %{
        site_name: "My Site",
        headline: "Welcome",
        primary_cta_text: "Get Started",
        primary_cta_url: "/start",
        active_theme: "Premium Dark",
        profile_name: "John Doe",
        profile_email: "john@example.com"
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset)[:active_theme] == [
               "must be lowercase alphanumeric with underscores only"
             ]
    end
  end
end
