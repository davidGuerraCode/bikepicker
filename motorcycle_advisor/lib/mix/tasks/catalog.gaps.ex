defmodule Mix.Tasks.Catalog.Gaps do
  @moduledoc """
  Prints category x experience_level x use_case combos that have fewer
  than `gap_threshold` (from data/sources.json) motorcycles in the catalog.
  """
  use Mix.Task

  alias MotorcycleAdvisor.Catalog

  @categories ~w(naked sport cruiser adventure scooter touring offroad)
  @experience_levels ~w(beginner intermediate advanced)
  @use_cases ~w(urban highway mixed offroad track)

  @shortdoc "Lists catalog gaps by category x experience_level x use_case"
  def run(_args) do
    Mix.Task.run("app.start")

    threshold = gap_threshold()

    counts =
      Catalog.list_all_motorcycles()
      |> Enum.frequencies_by(fn m -> {m.category, m.experience_level, m.use_case} end)

    gaps =
      for category <- @categories,
          experience_level <- @experience_levels,
          use_case <- @use_cases do
        count = Map.get(counts, {category, experience_level, use_case}, 0)
        {category, experience_level, use_case, count}
      end
      |> Enum.filter(fn {_, _, _, count} -> count < threshold end)
      |> Enum.sort_by(fn {_, _, _, count} -> count end)

    if gaps == [] do
      Mix.shell().info("No gaps found (threshold: #{threshold}).")
    else
      Mix.shell().info("Gaps (count < #{threshold}):\n")

      Enum.each(gaps, fn {category, experience_level, use_case, count} ->
        Mix.shell().info(
          "  #{pad(category)} #{pad(experience_level)} #{pad(use_case)} count=#{count}"
        )
      end)
    end
  end

  defp gap_threshold do
    case File.read("data/sources.json") do
      {:ok, contents} ->
        contents |> Jason.decode!() |> Map.get("gap_threshold", 2)

      {:error, _} ->
        2
    end
  end

  defp pad(value), do: String.pad_trailing(value, 14)
end
