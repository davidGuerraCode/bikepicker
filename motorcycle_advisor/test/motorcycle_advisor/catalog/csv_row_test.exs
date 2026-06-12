defmodule MotorcycleAdvisor.Catalog.CsvRowTest do
  use ExUnit.Case, async: true

  alias MotorcycleAdvisor.Catalog.CsvRow

  test "parses a full row into changeset attrs" do
    row = %{
      "status" => "approved",
      "brand" => "Honda",
      "model" => "Test125",
      "year" => "2024",
      "category" => "naked",
      "price_cop" => "9000000",
      "engine_cc" => "125",
      "power_hp" => "12",
      "weight_kg" => "135",
      "fuel_efficiency" => "40.0",
      "experience_level" => "beginner",
      "use_case" => "urban",
      "image_url" => "https://placehold.co/600x400?text=Honda+Test125",
      "description" => "Moto de prueba.",
      "tags" => "práctica;económica",
      "source_url" => "https://example.com",
      "notes" => ""
    }

    assert {:ok, attrs} = CsvRow.parse_row(row)

    assert attrs["brand"] == "Honda"
    assert attrs["year"] == 2024
    assert attrs["price_cop"] == 9_000_000
    assert attrs["fuel_efficiency"] == Decimal.new("40.0")
    assert attrs["tags"] == ["práctica", "económica"]
    refute Map.has_key?(attrs, "status")
    refute Map.has_key?(attrs, "source_url")
  end

  test "blank optional fields are omitted, not nil-valued" do
    row = %{
      "brand" => "Honda",
      "model" => "Test125",
      "year" => "2024",
      "category" => "naked",
      "price_cop" => "9000000",
      "engine_cc" => "125",
      "power_hp" => "",
      "weight_kg" => "",
      "fuel_efficiency" => "",
      "experience_level" => "beginner",
      "use_case" => "urban",
      "image_url" => "https://placehold.co/600x400?text=Honda+Test125",
      "description" => "",
      "tags" => ""
    }

    assert {:ok, attrs} = CsvRow.parse_row(row)

    refute Map.has_key?(attrs, "power_hp")
    refute Map.has_key?(attrs, "weight_kg")
    refute Map.has_key?(attrs, "fuel_efficiency")
    refute Map.has_key?(attrs, "tags")
  end
end
