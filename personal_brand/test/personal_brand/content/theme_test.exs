defmodule PersonalBrand.Content.ThemeTest do
  use PersonalBrand.DataCase, async: true

  alias PersonalBrand.Content.Theme

  @valid_attrs %{
    key: "my_theme",
    name: "My Theme",
    description: "A custom theme",
    is_active: false
  }

  describe "changeset/2" do
    test "accepts valid attrs" do
      changeset = Theme.changeset(%Theme{}, @valid_attrs)
      assert changeset.valid?
    end

    test "rejects missing key" do
      attrs = Map.delete(@valid_attrs, :key)
      changeset = Theme.changeset(%Theme{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:key] == ["can't be blank"]
    end

    test "rejects missing name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = Theme.changeset(%Theme{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:name] == ["can't be blank"]
    end

    test "enforces unique key constraint" do
      %Theme{}
      |> Theme.changeset(@valid_attrs)
      |> Repo.insert!()

      changeset =
        %Theme{}
        |> Theme.changeset(%{@valid_attrs | name: "Another Theme"})
        |> Repo.insert()

      assert {:error, changeset} = changeset
    end

    test "sets default is_active to false" do
      changeset = Theme.changeset(%Theme{}, @valid_attrs)
      assert get_field(changeset, :is_active) == false
    end

    test "accepts is_active true" do
      attrs = %{@valid_attrs | is_active: true}
      changeset = Theme.changeset(%Theme{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :is_active) == true
    end

    test "accepts config as map" do
      attrs = Map.merge(@valid_attrs, %{config: %{"primary_color" => "#333", "font" => "serif"}})
      changeset = Theme.changeset(%Theme{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :config) == %{"primary_color" => "#333", "font" => "serif"}
    end
  end
end
