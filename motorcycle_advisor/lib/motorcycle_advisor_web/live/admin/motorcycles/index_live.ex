defmodule MotorcycleAdvisorWeb.Admin.Motorcycles.IndexLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Catalog

  @categories ["", "naked", "sport", "cruiser", "adventure", "scooter", "touring", "offroad"]

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       bikes: Catalog.list_for_admin(),
       search: "",
       category_filter: "",
       categories: @categories,
       confirm_delete_id: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:motorcycles}>
      <.page_header title="Motorcycles">
        <:actions>
          <.button navigate={~p"/admin/motorcycles/import"} variant="secondary">
            Import CSV
          </.button>
          <.button navigate={~p"/admin/motorcycles/new"} variant="primary">
            + Add Motorcycle
          </.button>
        </:actions>
      </.page_header>

      <div class="flex gap-3 mb-4">
        <input
          type="text"
          placeholder="Search brand or model..."
          value={@search}
          phx-change="search"
          name="search"
          class="block w-64 rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        />
        <select
          phx-change="filter_category"
          name="category"
          class="block rounded-md border border-gray-300 bg-white px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        >
          <option :for={cat <- @categories} value={cat} selected={cat == @category_filter}>
            {if cat == "", do: "All categories", else: String.capitalize(cat)}
          </option>
        </select>
      </div>

      <.table id="motorcycles" rows={filtered_bikes(@bikes, @search, @category_filter)} row_id={fn m -> "moto-#{m.id}" end}>
        <:col :let={m} label="Image">
          <img
            :if={m.image_url && m.image_url != ""}
            src={m.image_url}
            class="h-10 w-14 object-cover rounded"
            loading="lazy"
          />
        </:col>
        <:col :let={m} label="Brand / Model">
          <div class="font-medium">{m.brand} {m.model}</div>
          <div class="text-xs text-gray-400">{m.year}</div>
        </:col>
        <:col :let={m} label="Category">
          <.badge color={category_color(m.category)}>{m.category}</.badge>
        </:col>
        <:col :let={m} label="Experience">
          <.badge color={experience_color(m.experience_level)}>{m.experience_level}</.badge>
        </:col>
        <:col :let={m} label="Use case">
          {m.use_case}
        </:col>
        <:col :let={m} label="Status">
          <.badge color={if m.active, do: "green", else: "gray"}>
            {if m.active, do: "active", else: "inactive"}
          </.badge>
        </:col>
        <:action :let={m}>
          <.button
            variant="ghost"
            phx-click="toggle_active"
            phx-value-id={m.id}
            title={if m.active, do: "Deactivate", else: "Activate"}
          >
            {if m.active, do: "⏸", else: "▶"}
          </.button>
          <.button variant="ghost" navigate={~p"/admin/motorcycles/#{m.id}/edit"}>Edit</.button>
          <.button
            variant="danger"
            phx-click="confirm_delete"
            phx-value-id={m.id}
          >
            Delete
          </.button>
        </:action>
      </.table>

      <.modal
        :if={@confirm_delete_id}
        id="delete-modal"
        on_confirm={JS.push("delete", value: %{id: @confirm_delete_id})}
      >
        <:title>Delete Motorcycle</:title>
        Are you sure you want to permanently delete this motorcycle?
        <:confirm>Delete</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
    </Layouts.app>
    """
  end

  def handle_event("search", %{"search" => term}, socket) do
    {:noreply, assign(socket, search: term)}
  end

  def handle_event("filter_category", %{"category" => cat}, socket) do
    {:noreply, assign(socket, category_filter: cat)}
  end

  def handle_event("toggle_active", %{"id" => id}, socket) do
    bike = Catalog.get_motorcycle!(id)
    {:ok, updated} = Catalog.toggle_active(bike)

    bikes =
      Enum.map(socket.assigns.bikes, fn m -> if m.id == updated.id, do: updated, else: m end)

    {:noreply, assign(socket, bikes: bikes)}
  end

  def handle_event("confirm_delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, confirm_delete_id: String.to_integer(id))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    bike = Catalog.get_motorcycle!(id)
    {:ok, _} = Catalog.delete_motorcycle(bike)

    bikes = Enum.reject(socket.assigns.bikes, &(&1.id == bike.id))
    {:noreply, assign(socket, bikes: bikes, confirm_delete_id: nil)}
  end

  defp filtered_bikes(bikes, search, category) do
    bikes
    |> filter_by_search(search)
    |> filter_by_category(category)
  end

  defp filter_by_search(bikes, ""), do: bikes

  defp filter_by_search(bikes, term) do
    term = String.downcase(term)

    Enum.filter(bikes, fn m ->
      String.contains?(String.downcase(m.brand), term) or
        String.contains?(String.downcase(m.model), term)
    end)
  end

  defp filter_by_category(bikes, ""), do: bikes
  defp filter_by_category(bikes, cat), do: Enum.filter(bikes, &(&1.category == cat))

  defp category_color("naked"), do: "blue"
  defp category_color("sport"), do: "red"
  defp category_color("cruiser"), do: "purple"
  defp category_color("adventure"), do: "orange"
  defp category_color("scooter"), do: "green"
  defp category_color("touring"), do: "yellow"
  defp category_color("offroad"), do: "gray"
  defp category_color(_), do: "gray"

  defp experience_color("beginner"), do: "green"
  defp experience_color("intermediate"), do: "yellow"
  defp experience_color("advanced"), do: "red"
  defp experience_color(_), do: "gray"
end
