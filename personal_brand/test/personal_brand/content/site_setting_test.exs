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
    profile_bio: "A developer"
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = SiteSetting.changeset(%SiteSetting{}, @valid_attrs)
      assert changeset.valid?
    end

    test "accepts minimal attrs" do
      changeset = SiteSetting.changeset(%SiteSetting{}, %{site_name: "My Site"})
      assert changeset.valid?
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
        social_links: %{"GitHub" => "https://github.com/john", "X" => "https://x.com/john"}
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?

      assert get_field(changeset, :social_links) == %{
               "GitHub" => "https://github.com/john",
               "X" => "https://x.com/john"
             }
    end

    test "accepts featured IDs as arrays" do
      id1 = Ecto.UUID.generate()
      id2 = Ecto.UUID.generate()

      attrs = %{
        site_name: "My Site",
        featured_project_ids: [id1, id2],
        featured_product_ids: [id2]
      }

      changeset = SiteSetting.changeset(%SiteSetting{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :featured_project_ids) == [id1, id2]
      assert get_field(changeset, :featured_product_ids) == [id2]
    end
  end
end
