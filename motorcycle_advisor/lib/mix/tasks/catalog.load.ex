defmodule Mix.Tasks.Catalog.Load do
  @moduledoc """
  Loads rows with status=approved from data/candidates.csv into the DB.

  - Skips rows where brand+model+year already exists in the catalog.
  - Valid rows are inserted and marked status=loaded.
  - Invalid rows print the changeset errors and are left as status=approved
    so they can be fixed and retried.
  """
  use Mix.Task

  alias MotorcycleAdvisor.Catalog
  alias MotorcycleAdvisor.Catalog.CsvRow
  alias NimbleCSV.RFC4180, as: CSV

  @csv_path "data/candidates.csv"

  @shortdoc "Loads approved candidates.csv rows into the catalog"
  def run(_args) do
    Mix.Task.run("app.start")

    case File.read(@csv_path) do
      {:ok, contents} -> process(contents)
      {:error, reason} -> Mix.shell().error("Could not read #{@csv_path}: #{inspect(reason)}")
    end
  end

  defp process(contents) do
    [header | rows] = CSV.parse_string(contents, skip_headers: false)

    {updated_rows, loaded, skipped, errors} =
      Enum.reduce(rows, {[], 0, 0, 0}, fn row, {acc, loaded, skipped, errors} ->
        record = Enum.zip(header, row) |> Map.new()

        case record["status"] do
          "approved" ->
            case load_row(record) do
              :loaded -> {[put_status(row, header, "loaded") | acc], loaded + 1, skipped, errors}
              :skipped -> {[row | acc], loaded, skipped + 1, errors}
              :error -> {[row | acc], loaded, skipped, errors + 1}
            end

          _ ->
            {[row | acc], loaded, skipped, errors}
        end
      end)

    File.write!(@csv_path, CSV.dump_to_iodata([header | Enum.reverse(updated_rows)]))

    Mix.shell().info(
      "Loaded #{loaded}, skipped (duplicate) #{skipped}, errors #{errors}."
    )
  end

  defp load_row(record) do
    if Catalog.motorcycle_exists?(record["brand"], record["model"], to_int(record["year"])) do
      Mix.shell().info("SKIP (duplicate): #{record["brand"]} #{record["model"]} #{record["year"]}")
      :skipped
    else
      insert_row(record)
    end
  end

  defp insert_row(record) do
    with {:ok, attrs} <- CsvRow.parse_row(record),
         {:ok, _moto} <- Catalog.create_motorcycle(attrs) do
      Mix.shell().info("LOADED: #{record["brand"]} #{record["model"]} #{record["year"]}")
      :loaded
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Mix.shell().error(
          "INVALID: #{record["brand"]} #{record["model"]} #{record["year"]} -> #{inspect(changeset.errors)}"
        )

        :error
    end
  rescue
    e ->
      Mix.shell().error("INVALID: #{record["brand"]} #{record["model"]} #{record["year"]} -> #{Exception.message(e)}")
      :error
  end

  defp to_int(nil), do: nil
  defp to_int(value), do: String.to_integer(value)

  defp put_status(row, header, new_status) do
    status_index = Enum.find_index(header, &(&1 == "status"))
    List.replace_at(row, status_index, new_status)
  end
end
