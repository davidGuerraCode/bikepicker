defmodule MotorcycleAdvisorWeb.Admin.DashboardLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Catalog
  alias MotorcycleAdvisor.Quiz

  @categories ~w(naked sport cruiser adventure scooter touring offroad)
  @experience_levels ~w(beginner intermediate advanced)

  def mount(_params, _session, socket) do
    bikes = Catalog.list_for_admin()
    questions = Quiz.list_questions()

    matrix = build_matrix(bikes)

    {:ok,
     assign(socket,
       matrix: matrix,
       total_bikes: length(bikes),
       active_bikes: Enum.count(bikes, & &1.active),
       total_questions: length(questions),
       categories: @categories,
       experience_levels: @experience_levels
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:dashboard}>
      <.page_header title="Dashboard" />

      <div class="grid grid-cols-3 gap-4 mb-8">
        <div class="bg-white rounded-lg border border-gray-200 p-4">
          <p class="text-sm text-gray-500">Total Motorcycles</p>
          <p class="text-3xl font-bold text-gray-900 mt-1">{@total_bikes}</p>
          <p class="text-xs text-gray-400 mt-1">{@active_bikes} active</p>
        </div>
        <div class="bg-white rounded-lg border border-gray-200 p-4">
          <p class="text-sm text-gray-500">Inactive Bikes</p>
          <p class="text-3xl font-bold text-gray-900 mt-1">{@total_bikes - @active_bikes}</p>
          <p class="text-xs text-gray-400 mt-1">hidden from recommendations</p>
        </div>
        <div class="bg-white rounded-lg border border-gray-200 p-4">
          <p class="text-sm text-gray-500">Quiz Questions</p>
          <p class="text-3xl font-bold text-gray-900 mt-1">{@total_questions}</p>
        </div>
      </div>

      <div class="bg-white rounded-lg border border-gray-200 p-6">
        <h2 class="text-base font-semibold text-gray-900 mb-4">Coverage Matrix</h2>
        <p class="text-sm text-gray-500 mb-4">
          Active bikes by category × experience level. Red cells indicate gaps.
        </p>
        <div class="overflow-x-auto">
          <table class="min-w-full text-sm">
            <thead>
              <tr>
                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                  Category
                </th>
                <th
                  :for={level <- @experience_levels}
                  class="px-3 py-2 text-center text-xs font-medium text-gray-500 uppercase"
                >
                  {level}
                </th>
                <th class="px-3 py-2 text-center text-xs font-medium text-gray-500 uppercase">
                  Total
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
              <tr :for={cat <- @categories} class="hover:bg-gray-50">
                <td class="px-3 py-2 font-medium text-gray-900 capitalize">{cat}</td>
                <td
                  :for={level <- @experience_levels}
                  class={[
                    "px-3 py-2 text-center font-mono",
                    cell_count(@matrix, cat, level) == 0 &&
                      "bg-red-50 text-red-600 font-semibold",
                    cell_count(@matrix, cat, level) > 0 && "text-gray-900"
                  ]}
                >
                  {cell_count(@matrix, cat, level)}
                </td>
                <td class="px-3 py-2 text-center text-gray-500">
                  {row_total(@matrix, cat)}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp build_matrix(bikes) do
    active_bikes = Enum.filter(bikes, & &1.active)

    Enum.reduce(active_bikes, %{}, fn bike, acc ->
      count = get_in(acc, [bike.category, bike.experience_level]) || 0
      put_in(acc, [Access.key(bike.category, %{}), bike.experience_level], count + 1)
    end)
  end

  defp cell_count(matrix, category, level) do
    get_in(matrix, [category, level]) || 0
  end

  defp row_total(matrix, category) do
    matrix
    |> Map.get(category, %{})
    |> Map.values()
    |> Enum.sum()
  end
end
