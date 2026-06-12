defmodule MotorcycleAdvisor.Catalog.CsvRow do
  @moduledoc """
  Converts a candidates.csv row (map of string => string) into a
  Motorcycle changeset attrs map.
  """

  @integer_fields ~w(year price_cop engine_cc power_hp weight_kg)
  @passthrough_fields ~w(brand model category experience_level use_case image_url description)

  def parse_row(row) when is_map(row) do
    attrs =
      @passthrough_fields
      |> Enum.reduce(%{}, fn field, acc -> Map.put(acc, field, blank_to_nil(row[field])) end)
      |> put_integers(row)
      |> put_fuel_efficiency(row)
      |> put_tags(row)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    {:ok, attrs}
  end

  defp put_integers(attrs, row) do
    Enum.reduce(@integer_fields, attrs, fn field, acc ->
      case blank_to_nil(row[field]) do
        nil -> acc
        value -> Map.put(acc, field, String.to_integer(value))
      end
    end)
  end

  defp put_fuel_efficiency(attrs, row) do
    case blank_to_nil(row["fuel_efficiency"]) do
      nil -> attrs
      value -> Map.put(attrs, "fuel_efficiency", Decimal.new(value))
    end
  end

  defp put_tags(attrs, row) do
    case blank_to_nil(row["tags"]) do
      nil -> attrs
      value -> Map.put(attrs, "tags", String.split(value, ";", trim: true))
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: String.trim(value)
end
