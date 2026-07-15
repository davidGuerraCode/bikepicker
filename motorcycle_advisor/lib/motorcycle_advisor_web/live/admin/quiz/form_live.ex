defmodule MotorcycleAdvisorWeb.Admin.Quiz.FormLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Quiz
  alias MotorcycleAdvisor.Quiz.QuizQuestion

  def mount(%{"id" => id}, _session, socket) do
    question = Quiz.get_question!(id)
    changeset = QuizQuestion.changeset(question, %{})
    options = extract_options(question.options)

    {:ok,
     assign(socket,
       question: question,
       changeset: changeset,
       action: :edit,
       options: options
     )}
  end

  def mount(_params, _session, socket) do
    changeset = QuizQuestion.changeset(%QuizQuestion{}, %{})

    {:ok,
     assign(socket,
       question: %QuizQuestion{},
       changeset: changeset,
       action: :new,
       options: [empty_option()]
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:quiz}>
      <.page_header title={if @action == :new, do: "Add Question", else: "Edit Question"} />

      <div class="bg-white rounded-lg border border-gray-200 p-6 max-w-2xl dark:bg-[#1a1d27] dark:border-[#2a2e3e]">
        <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" class="space-y-5">
          <div class="grid grid-cols-2 gap-4">
            <.input field={f[:key]} label="Key (unique identifier)" required />
            <.input field={f[:order]} label="Display Order" type="number" required />
          </div>

          <.input field={f[:label]} label="Question Label" required />

          <.input field={f[:type]} label="Type" type="select" required>
            <option value="single_choice">Single Choice</option>
          </.input>

          <div>
            <div class="flex items-center justify-between mb-2">
              <label class="block text-sm font-medium text-gray-700 dark:text-slate-300">Options</label>
              <.button type="button" variant="secondary" phx-click="add_option">
                + Add Option
              </.button>
            </div>

            <div class="space-y-3">
              <div
                :for={{opt, idx} <- Enum.with_index(@options)}
                class="grid grid-cols-4 gap-2 p-3 bg-gray-50 rounded-md dark:bg-[#22263a]"
              >
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1 dark:text-slate-400">Value</label>
                  <input
                    type="text"
                    name={"options[#{idx}][value]"}
                    value={opt["value"]}
                    placeholder="e.g. urban"
                    class="block w-full rounded border border-gray-300 px-2 py-1 text-sm focus:border-blue-500 focus:outline-none dark:bg-[#1a1d27] dark:border-[#2a2e3e] dark:text-slate-100"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1 dark:text-slate-400">Label</label>
                  <input
                    type="text"
                    name={"options[#{idx}][label]"}
                    value={opt["label"]}
                    placeholder="Display text"
                    class="block w-full rounded border border-gray-300 px-2 py-1 text-sm focus:border-blue-500 focus:outline-none dark:bg-[#1a1d27] dark:border-[#2a2e3e] dark:text-slate-100"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1 dark:text-slate-400">Description</label>
                  <input
                    type="text"
                    name={"options[#{idx}][description]"}
                    value={opt["description"]}
                    placeholder="Short description"
                    class="block w-full rounded border border-gray-300 px-2 py-1 text-sm focus:border-blue-500 focus:outline-none dark:bg-[#1a1d27] dark:border-[#2a2e3e] dark:text-slate-100"
                  />
                </div>
                <div class="flex flex-col">
                  <label class="block text-xs font-medium text-gray-500 mb-1 dark:text-slate-400">Icon</label>
                  <div class="flex gap-1">
                    <input
                      type="text"
                      name={"options[#{idx}][icon]"}
                      value={opt["icon"]}
                      placeholder="🏙️"
                      class="block w-full rounded border border-gray-300 px-2 py-1 text-sm focus:border-blue-500 focus:outline-none dark:bg-[#1a1d27] dark:border-[#2a2e3e] dark:text-slate-100"
                    />
                    <button
                      type="button"
                      phx-click="remove_option"
                      phx-value-index={idx}
                      class="text-red-500 hover:text-red-700 px-1"
                    >
                      ✕
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="flex gap-3 pt-2">
            <.button type="submit" variant="primary">
              {if @action == :new, do: "Create Question", else: "Save Changes"}
            </.button>
            <.button navigate={~p"/admin/quiz"} variant="secondary">Cancel</.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("validate", params, socket) do
    options = parse_options(params)

    changeset =
      socket.assigns.question
      |> QuizQuestion.changeset(quiz_params(params, options))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, options: options)}
  end

  def handle_event("add_option", _params, socket) do
    {:noreply, assign(socket, options: socket.assigns.options ++ [empty_option()])}
  end

  def handle_event("remove_option", %{"index" => idx}, socket) do
    idx = String.to_integer(idx)
    options = List.delete_at(socket.assigns.options, idx)
    {:noreply, assign(socket, options: options)}
  end

  def handle_event("save", params, socket) do
    options = parse_options(params)
    attrs = quiz_params(params, options)

    result =
      case socket.assigns.action do
        :new -> Quiz.create_question(attrs)
        :edit -> Quiz.update_question(socket.assigns.question, attrs)
      end

    case result do
      {:ok, _question} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question saved.")
         |> push_navigate(to: ~p"/admin/quiz")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp quiz_params(params, options) do
    question_params = Map.get(params, "quiz_question", %{})
    Map.put(question_params, "options", %{"items" => options})
  end

  defp parse_options(%{"options" => options_map}) when is_map(options_map) do
    options_map
    |> Enum.sort_by(fn {k, _} -> String.to_integer(k) end)
    |> Enum.map(fn {_, opt} -> opt end)
  end

  defp parse_options(_), do: []

  defp extract_options(%{"items" => items}) when is_list(items) do
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

  defp extract_options(_), do: [empty_option()]

  defp empty_option, do: %{"value" => "", "label" => "", "description" => "", "icon" => ""}
end
