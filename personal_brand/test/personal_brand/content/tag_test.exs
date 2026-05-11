defmodule PersonalBrand.Content.TagTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Tag

  @valid_attrs %{
    name: "Elixir",
    slug: "elixir"
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Tag.changeset(%Tag{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:name] == ["can't be blank"]
    end

    test "rejects missing slug" do
      attrs = Map.delete(@valid_attrs, :slug)
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:slug] == ["can't be blank"]
    end

    test "enforces unique name constraint" do
      %Tag{}
      |> Tag.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Tag{}
               |> Tag.changeset(%{@valid_attrs | slug: "elixir-lang"})
               |> Repo.insert()
    end

    test "enforces unique slug constraint" do
      %Tag{}
      |> Tag.changeset(@valid_attrs)
      |> Repo.insert!()

      assert {:error, _changeset} =
               %Tag{}
               |> Tag.changeset(%{@valid_attrs | name: "Elixir Lang"})
               |> Repo.insert()
    end

    test "rejects slug with uppercase letters" do
      attrs = %{@valid_attrs | slug: "Elixir"}
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset)[:slug] ==
               ["must be lowercase alphanumeric with hyphens only"]
    end

    test "rejects slug with spaces" do
      attrs = %{@valid_attrs | slug: "elixir lang"}
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset)[:slug] ==
               ["must be lowercase alphanumeric with hyphens only"]
    end

    test "accepts slug with hyphens" do
      attrs = %{@valid_attrs | slug: "elixir-lang"}
      changeset = Tag.changeset(%Tag{}, attrs)
      assert changeset.valid?
    end

    test "rejects name exceeding max length" do
      attrs = %{@valid_attrs | name: String.duplicate("a", 101)}
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset)[:name] ==
               ["should be at most 100 character(s)"]
    end

    test "rejects slug exceeding max length" do
      attrs = %{@valid_attrs | slug: String.duplicate("a", 101)}
      changeset = Tag.changeset(%Tag{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset)[:slug] ==
               ["should be at most 100 character(s)"]
    end
  end
end
