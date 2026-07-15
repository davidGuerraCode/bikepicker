defmodule MotorcycleAdvisorWeb.Admin.SimulatorLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Quiz

  def mount(_params, _session, socket) do
    questions = Quiz.list_questions()

    {:ok,
     assign(socket,
       questions: questions,
       answers: %{},
       results: []
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:simulator}>
      <.page_header title="Recommendation Simulator" />
      <p class="text-sm text-gray-500 mb-6">
        Pick answers below to see which motorcycles the matcher would recommend in real time.
      </p>

      <div class="grid grid-cols-2 gap-6">
        <div class="space-y-4">
          <div :for={q <- @questions} class="bg-white rounded-lg border border-gray-200 p-4">
            <p class="text-sm font-medium text-gray-900 mb-3">{q.label}</p>
            <div class="space-y-1.5">
              <label
                :for={opt <- question_options(q.options)}
                class={[
                  "flex items-center gap-2 px-3 py-2 rounded-md cursor-pointer text-sm transition-colors",
                  Map.get(@answers, q.key) == opt["value"] &&
                    "bg-blue-50 border border-blue-200 text-blue-800",
                  Map.get(@answers, q.key) != opt["value"] &&
                    "border border-gray-200 hover:bg-gray-50"
                ]}
              >
                <input
                  type="radio"
                  name={q.key}
                  value={opt["value"]}
                  checked={Map.get(@answers, q.key) == opt["value"]}
                  phx-click="answer"
                  phx-value-key={q.key}
                  phx-value-value={opt["value"]}
                  class="hidden"
                />
                <span>{opt["icon"]}</span>
                <div>
                  <span class="font-medium">{opt["label"]}</span>
                  <span :if={opt["description"]} class="text-xs text-gray-500 ml-1">
                    — {opt["description"]}
                  </span>
                </div>
              </label>
            </div>
          </div>

          <.button
            phx-click="reset"
            variant="secondary"
            class="w-full"
          >
            Reset Answers
          </.button>
        </div>

        <div>
          <div :if={@results == [] && map_size(@answers) == 0} class="bg-gray-50 rounded-lg border border-dashed border-gray-300 p-8 text-center">
            <p class="text-sm text-gray-400">Answer the questions to see recommendations.</p>
          </div>

          <div :if={@results == [] && map_size(@answers) > 0} class="bg-gray-50 rounded-lg border border-gray-200 p-8 text-center">
            <p class="text-sm text-gray-500">
              Answer all {length(@questions)} questions to see results.
              ({map_size(@answers)}/{length(@questions)} answered)
            </p>
          </div>

          <div :if={@results != []} class="space-y-4">
            <div
              :for={{result, rank} <- Enum.with_index(@results, 1)}
              class="bg-white rounded-lg border border-gray-200 overflow-hidden"
            >
              <div class="flex items-center gap-3 p-4 border-b border-gray-100">
                <span class={[
                  "flex items-center justify-center w-7 h-7 rounded-full text-sm font-bold",
                  rank == 1 && "bg-yellow-100 text-yellow-700",
                  rank == 2 && "bg-gray-100 text-gray-600",
                  rank == 3 && "bg-orange-100 text-orange-700"
                ]}>
                  {rank}
                </span>
                <div class="flex-1">
                  <p class="font-semibold text-gray-900">
                    {result.motorcycle.brand} {result.motorcycle.model}
                  </p>
                  <p class="text-xs text-gray-400">{result.motorcycle.year}</p>
                </div>
                <div class="text-right">
                  <p class="text-lg font-bold text-blue-600">
                    {Float.round(result.score * 100, 1)}%
                  </p>
                  <p class="text-xs text-gray-400">match score</p>
                </div>
              </div>
              <div class="px-4 py-3 flex flex-wrap gap-1.5">
                <.badge color={category_color(result.motorcycle.category)}>
                  {result.motorcycle.category}
                </.badge>
                <.badge color="gray">{result.motorcycle.experience_level}</.badge>
                <.badge color="gray">{result.motorcycle.use_case}</.badge>
              </div>
              <ul :if={result.reasons != []} class="px-4 pb-3 space-y-1">
                <li :for={reason <- result.reasons} class="text-xs text-gray-600 flex gap-1.5">
                  <span class="text-green-500 mt-0.5">✓</span>
                  {reason}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("answer", %{"key" => key, "value" => value}, socket) do
    answers = Map.put(socket.assigns.answers, key, value)

    results =
      if map_size(answers) == length(socket.assigns.questions) do
        Quiz.match(answers)
      else
        []
      end

    {:noreply, assign(socket, answers: answers, results: results)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, answers: %{}, results: [])}
  end

  defp question_options(%{"items" => items}) when is_list(items) do
    Enum.map(items, fn item ->
      %{
        "value" => to_string(Map.get(item, "value") || Map.get(item, :value, "")),
        "label" => to_string(Map.get(item, "label") || Map.get(item, :label, "")),
        "description" =>
          to_string(Map.get(item, "description") || Map.get(item, :description, "")),
        "icon" => to_string(Map.get(item, "icon") || Map.get(item, :icon, ""))
      }
    end)
  end

  defp question_options(_), do: []

  defp category_color("naked"), do: "blue"
  defp category_color("sport"), do: "red"
  defp category_color("cruiser"), do: "purple"
  defp category_color("adventure"), do: "orange"
  defp category_color("scooter"), do: "green"
  defp category_color("touring"), do: "yellow"
  defp category_color("offroad"), do: "gray"
  defp category_color(_), do: "gray"
end
