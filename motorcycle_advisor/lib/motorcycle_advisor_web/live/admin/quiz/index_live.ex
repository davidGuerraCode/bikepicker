defmodule MotorcycleAdvisorWeb.Admin.Quiz.IndexLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Quiz

  def mount(_params, _session, socket) do
    {:ok, assign(socket, questions: Quiz.list_questions(), confirm_delete_id: nil)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:quiz}>
      <.page_header title="Quiz Questions">
        <:actions>
          <.button navigate={~p"/admin/quiz/new"} variant="primary">+ Add Question</.button>
        </:actions>
      </.page_header>

      <.table id="questions" rows={@questions} row_id={fn q -> "question-#{q.id}" end}>
        <:col :let={q} label="Order">{q.order}</:col>
        <:col :let={q} label="Key">
          <code class="text-xs bg-gray-100 px-1 rounded">{q.key}</code>
        </:col>
        <:col :let={q} label="Label">{q.label}</:col>
        <:col :let={q} label="Type">
          <.badge color="blue">{q.type}</.badge>
        </:col>
        <:col :let={q} label="Options">
          {option_count(q.options)} options
        </:col>
        <:action :let={q}>
          <.button variant="ghost" navigate={~p"/admin/quiz/#{q.id}/edit"}>Edit</.button>
          <.button variant="danger" phx-click="confirm_delete" phx-value-id={q.id}>Delete</.button>
        </:action>
      </.table>

      <.modal
        :if={@confirm_delete_id}
        id="delete-question-modal"
        on_confirm={JS.push("delete", value: %{id: @confirm_delete_id})}
      >
        <:title>Delete Question</:title>
        This will permanently delete the question and cannot be undone.
        <:confirm>Delete</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
    </Layouts.app>
    """
  end

  def handle_event("confirm_delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, confirm_delete_id: String.to_integer(id))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    question = Quiz.get_question!(id)
    {:ok, _} = Quiz.delete_question(question)

    questions = Enum.reject(socket.assigns.questions, &(&1.id == question.id))
    {:noreply, assign(socket, questions: questions, confirm_delete_id: nil)}
  end

  defp option_count(%{"items" => items}) when is_list(items), do: length(items)
  defp option_count(_), do: 0
end
