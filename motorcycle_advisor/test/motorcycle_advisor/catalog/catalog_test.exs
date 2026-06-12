defmodule MotorcycleAdvisor.CatalogTest do
  use MotorcycleAdvisor.DataCase, async: true

  alias MotorcycleAdvisor.Catalog

  @valid_attrs %{
    "brand" => "Honda",
    "model" => "Test125",
    "year" => 2024,
    "category" => "naked",
    "price_cop" => 9_000_000,
    "engine_cc" => 125,
    "experience_level" => "beginner",
    "use_case" => "urban",
    "image_url" => "https://placehold.co/600x400?text=Honda+Test125"
  }

  describe "create_motorcycle/1" do
    test "inserts with valid attrs" do
      assert {:ok, moto} = Catalog.create_motorcycle(@valid_attrs)
      assert moto.brand == "Honda"
      assert moto.category == "naked"
    end

    test "rejects invalid category" do
      attrs = Map.put(@valid_attrs, "category", "spaceship")
      assert {:error, changeset} = Catalog.create_motorcycle(attrs)
      assert "is invalid" in errors_on(changeset).category
    end

    test "rejects missing required fields" do
      assert {:error, changeset} = Catalog.create_motorcycle(%{})
      assert errors_on(changeset).brand
    end
  end

  describe "motorcycle_exists?/3" do
    test "true when brand+model+year match" do
      {:ok, _moto} = Catalog.create_motorcycle(@valid_attrs)
      assert Catalog.motorcycle_exists?("Honda", "Test125", 2024)
    end

    test "false when no match" do
      refute Catalog.motorcycle_exists?("Nonexistent", "Model", 1999)
    end
  end
end
