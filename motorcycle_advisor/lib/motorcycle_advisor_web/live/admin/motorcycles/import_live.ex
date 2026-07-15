defmodule MotorcycleAdvisorWeb.Admin.Motorcycles.ImportLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Catalog
  alias MotorcycleAdvisor.Catalog.CsvRow
  alias NimbleCSV.RFC4180, as: CSV

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> allow_upload(:csv, accept: ~w(.csv), max_entries: 1, max_file_size: 5_000_000)
     |> assign(parsed_rows: nil, import_result: nil)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:motorcycles}>
      <.page_header title="Import Motorcycles from CSV">
        <:actions>
          <.button navigate={~p"/admin/motorcycles"} variant="secondary">Back</.button>
        </:actions>
      </.page_header>

      <div class="bg-white rounded-lg border border-gray-200 p-6 max-w-4xl space-y-6 dark:bg-[#1a1d27] dark:border-[#2a2e3e]">
        <div :if={is_nil(@import_result)}>
          <p class="text-sm text-gray-600 mb-4 dark:text-slate-400">
            Upload a CSV file. Expected columns:
            <code class="text-xs bg-gray-100 px-1 rounded dark:bg-[#22263a] dark:text-slate-300">
              brand, model, year, category, engine_cc, power_hp, weight_kg, fuel_efficiency,
              experience_level, use_case, price_cop, image_url, description, tags, status
            </code>
            . Only rows with <code class="text-xs bg-gray-100 px-1 rounded dark:bg-[#22263a] dark:text-slate-300">status=approved</code>
            will be imported.
          </p>

          <form phx-change="validate" phx-submit="parse" class="space-y-4">
            <div
              class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center cursor-pointer hover:border-blue-400 transition-colors dark:border-[#2a2e3e] dark:hover:border-amber-400/50"
              phx-drop-target={@uploads.csv.ref}
            >
              <p class="text-gray-500 text-sm mb-2 dark:text-slate-400">Drop a CSV file here, or</p>
              <label class="cursor-pointer text-blue-600 text-sm font-medium hover:underline dark:text-amber-400">
                browse to upload
                <.live_file_input upload={@uploads.csv} class="hidden" />
              </label>
              <div :for={entry <- @uploads.csv.entries} class="mt-3 text-sm text-gray-700 dark:text-slate-300">
                📄 {entry.client_name} ({Float.round(entry.client_size / 1024, 1)} KB)
                <button
                  type="button"
                  phx-click="cancel_upload"
                  phx-value-ref={entry.ref}
                  class="ml-2 text-red-500 hover:text-red-700 cursor-pointer"
                >
                  ✕
                </button>
              </div>
            </div>

            <.button
              type="submit"
              variant="primary"
              disabled={@uploads.csv.entries == []}
            >
              Parse CSV
            </.button>
          </form>
        </div>

        <div :if={@parsed_rows && is_nil(@import_result)}>
          <h3 class="font-medium text-gray-900 mb-3">
            Preview — {length(@parsed_rows)} rows found
          </h3>

          <div class="overflow-x-auto">
            <table class="min-w-full text-xs divide-y divide-gray-200 dark:divide-[#2a2e3e]">
              <thead class="bg-gray-50 dark:bg-[#22263a]">
                <tr>
                  <th class="px-2 py-2 text-left font-medium text-gray-500 dark:text-slate-400">#</th>
                  <th class="px-2 py-2 text-left font-medium text-gray-500 dark:text-slate-400">Brand / Model</th>
                  <th class="px-2 py-2 text-left font-medium text-gray-500 dark:text-slate-400">Category</th>
                  <th class="px-2 py-2 text-left font-medium text-gray-500 dark:text-slate-400">Experience</th>
                  <th class="px-2 py-2 text-left font-medium text-gray-500 dark:text-slate-400">Status</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 dark:divide-[#2a2e3e]">
                <tr
                  :for={{row, idx} <- Enum.with_index(@parsed_rows, 1)}
                  class={if match?({:error, _}, row), do: "bg-red-50 dark:bg-red-950/20", else: "bg-green-50 dark:bg-green-950/20"}
                >
                  <td class="px-2 py-1.5 text-gray-400 dark:text-slate-500">{idx}</td>
                  <td class="px-2 py-1.5">
                    {case row do
                      {:ok, attrs} -> "#{attrs["brand"]} #{attrs["model"]} #{attrs["year"]}"
                      {:error, _} -> "—"
                    end}
                  </td>
                  <td class="px-2 py-1.5">
                    {case row do
                      {:ok, attrs} -> attrs["category"]
                      _ -> ""
                    end}
                  </td>
                  <td class="px-2 py-1.5">
                    {case row do
                      {:ok, attrs} -> attrs["experience_level"]
                      _ -> ""
                    end}
                  </td>
                  <td class="px-2 py-1.5">
                    <span :if={match?({:ok, _}, row)} class="text-green-700 font-medium dark:text-green-400">✓ valid</span>
                    <span :if={match?({:error, _}, row)} class="text-red-600 dark:text-red-400">
                      ✗ {elem(row, 1)}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="flex gap-3 mt-4">
            <.button phx-click="import" variant="primary"
              disabled={Enum.any?(@parsed_rows, &match?({:error, _}, &1))}>
              Import Valid Rows
            </.button>
            <.button phx-click="reset" variant="secondary">Start Over</.button>
          </div>

          <p :if={Enum.any?(@parsed_rows, &match?({:error, _}, &1))} class="text-xs text-red-600 mt-2 dark:text-red-400">
            Fix all errors before importing.
          </p>
        </div>

        <div :if={@import_result} class="space-y-3">
          <div class="p-4 bg-green-50 rounded-md dark:bg-green-950/30">
            <p class="text-sm font-medium text-green-800 dark:text-green-300">
              Import complete: {@import_result.inserted} inserted,
              {@import_result.skipped} skipped (duplicates),
              {@import_result.errors} errors
            </p>
          </div>
          <.button navigate={~p"/admin/motorcycles"} variant="primary">View Motorcycles</.button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv, ref)}
  end

  def handle_event("parse", _params, socket) do
    rows =
      consume_uploaded_entries(socket, :csv, fn %{path: path}, _entry ->
        contents = File.read!(path)
        [header | data_rows] = CSV.parse_string(contents, skip_headers: false)

        parsed =
          Enum.flat_map(data_rows, fn row ->
            record = Enum.zip(header, row) |> Map.new()

            if record["status"] == "approved" do
              case CsvRow.parse_row(record) do
                {:ok, attrs} ->
                  changeset =
                    MotorcycleAdvisor.Catalog.Motorcycle.changeset(
                      %MotorcycleAdvisor.Catalog.Motorcycle{},
                      attrs
                    )

                  if changeset.valid? do
                    [{:ok, attrs}]
                  else
                    errors =
                      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
                        Enum.reduce(opts, msg, fn {k, v}, acc ->
                          String.replace(acc, "%{#{k}}", to_string(v))
                        end)
                      end)

                    [{:error, inspect(errors)}]
                  end
              end
            else
              []
            end
          end)

        {:ok, parsed}
      end)
      |> List.flatten()

    {:noreply, assign(socket, parsed_rows: rows)}
  end

  def handle_event("import", _params, socket) do
    result =
      socket.assigns.parsed_rows
      |> Enum.filter(&match?({:ok, _}, &1))
      |> Enum.reduce(%{inserted: 0, skipped: 0, errors: 0}, fn {:ok, attrs}, acc ->
        if Catalog.motorcycle_exists?(attrs["brand"], attrs["model"], to_year(attrs["year"])) do
          %{acc | skipped: acc.skipped + 1}
        else
          case Catalog.create_motorcycle(attrs) do
            {:ok, _} -> %{acc | inserted: acc.inserted + 1}
            {:error, _} -> %{acc | errors: acc.errors + 1}
          end
        end
      end)

    {:noreply, assign(socket, import_result: result)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, parsed_rows: nil, import_result: nil)}
  end

  defp to_year(val) when is_integer(val), do: val
  defp to_year(val) when is_binary(val), do: String.to_integer(val)
  defp to_year(_), do: 0
end
