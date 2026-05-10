defmodule PersonalBrand.Content.MediaTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Media

  @valid_attrs %{
    filename: "photo.jpg",
    content_type: "image/jpeg",
    size: 1024,
    url: "/uploads/photo.jpg",
    alt_text: "A photo"
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Media.changeset(%Media{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing filename" do
      attrs = Map.delete(@valid_attrs, :filename)
      changeset = Media.changeset(%Media{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:filename] == ["can't be blank"]
    end

    test "rejects missing url" do
      attrs = Map.delete(@valid_attrs, :url)
      changeset = Media.changeset(%Media{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:url] == ["can't be blank"]
    end

    test "accepts all optional fields" do
      changeset = Media.changeset(%Media{}, @valid_attrs)
      assert changeset.valid?
      assert get_field(changeset, :content_type) == "image/jpeg"
      assert get_field(changeset, :size) == 1024
      assert get_field(changeset, :alt_text) == "A photo"
    end

    test "accepts attachable fields" do
      attrs =
        Map.merge(@valid_attrs, %{
          attachable_type: "Project",
          attachable_id: Ecto.UUID.generate()
        })

      changeset = Media.changeset(%Media{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :attachable_type) == "Project"
    end

    test "accepts different content types" do
      types = ["image/png", "application/pdf", "video/mp4", "text/plain"]

      for content_type <- types do
        attrs = %{@valid_attrs | content_type: content_type}
        changeset = Media.changeset(%Media{}, attrs)
        assert changeset.valid?, "Expected #{content_type} to be valid"
      end
    end
  end
end
