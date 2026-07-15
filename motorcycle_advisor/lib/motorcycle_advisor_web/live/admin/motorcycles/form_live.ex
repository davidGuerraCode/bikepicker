defmodule MotorcycleAdvisorWeb.Admin.Motorcycles.FormLive do
  use MotorcycleAdvisorWeb, :live_view

  alias MotorcycleAdvisor.Catalog
  alias MotorcycleAdvisor.Catalog.Motorcycle

  def mount(%{"id" => id}, _session, socket) do
    motorcycle = Catalog.get_motorcycle!(id)
    changeset = Motorcycle.changeset(motorcycle, %{})

    {:ok,
     assign(socket,
       motorcycle: motorcycle,
       changeset: changeset,
       action: :edit,
       image_preview_url: motorcycle.image_url
     )}
  end

  def mount(_params, _session, socket) do
    changeset = Motorcycle.changeset(%Motorcycle{}, %{})

    {:ok,
     assign(socket,
       motorcycle: %Motorcycle{},
       changeset: changeset,
       action: :new,
       image_preview_url: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:motorcycles}>
      <.page_header title={if @action == :new, do: "Add Motorcycle", else: "Edit Motorcycle"} />

      <div class="bg-white rounded-lg border border-gray-200 p-6 max-w-3xl">
        <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" class="space-y-5">
          <div class="grid grid-cols-2 gap-4">
            <.input field={f[:brand]} label="Brand" required />
            <.input field={f[:model]} label="Model" required />
          </div>

          <div class="grid grid-cols-3 gap-4">
            <.input field={f[:year]} label="Year" type="number" required />
            <.input field={f[:engine_cc]} label="Engine (cc)" type="number" required />
            <.input field={f[:power_hp]} label="Power (hp)" type="number" />
          </div>

          <div class="grid grid-cols-3 gap-4">
            <.input field={f[:weight_kg]} label="Weight (kg)" type="number" />
            <.input field={f[:fuel_efficiency]} label="Fuel efficiency (km/l)" type="number" step="0.1" />
            <.input field={f[:price_cop]} label="Price (COP)" type="number" required />
          </div>

          <div class="grid grid-cols-3 gap-4">
            <.input field={f[:category]} label="Category" type="select" required>
              <option value="">Select...</option>
              <option :for={cat <- ~w(naked sport cruiser adventure scooter touring offroad)} value={cat}>
                {String.capitalize(cat)}
              </option>
            </.input>

            <.input field={f[:experience_level]} label="Experience Level" type="select" required>
              <option value="">Select...</option>
              <option :for={level <- ~w(beginner intermediate advanced)} value={level}>
                {String.capitalize(level)}
              </option>
            </.input>

            <.input field={f[:use_case]} label="Use Case" type="select" required>
              <option value="">Select...</option>
              <option :for={uc <- ~w(urban highway mixed offroad track)} value={uc}>
                {String.capitalize(uc)}
              </option>
            </.input>
          </div>

          <div class="space-y-2">
            <.input field={f[:image_url]} label="Image URL" type="url" />
            <div :if={@image_preview_url && @image_preview_url != ""} class="mt-2">
              <img
                src={@image_preview_url}
                alt="Preview"
                class="h-32 w-48 object-cover rounded-md border border-gray-200"
                onerror="this.style.display='none'"
              />
            </div>
          </div>

          <.input field={f[:description]} label="Description" type="textarea" rows="3" />

          <.input
            field={f[:tags]}
            label="Tags (comma-separated)"
            value={tags_to_string(@changeset)}
            name="motorcycle[tags_input]"
          />

          <.input field={f[:active]} label="Active (visible in recommendations)" type="checkbox" />

          <div class="flex gap-3 pt-2">
            <.button type="submit" variant="primary">
              {if @action == :new, do: "Create Motorcycle", else: "Save Changes"}
            </.button>
            <.button navigate={~p"/admin/motorcycles"} variant="secondary">Cancel</.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"motorcycle" => params}, socket) do
    params = parse_tags(params)

    changeset =
      socket.assigns.motorcycle
      |> Motorcycle.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, image_preview_url: params["image_url"])}
  end

  def handle_event("save", %{"motorcycle" => params}, socket) do
    params = parse_tags(params)

    result =
      case socket.assigns.action do
        :new -> Catalog.create_motorcycle(params)
        :edit -> Catalog.update_motorcycle(socket.assigns.motorcycle, params)
      end

    case result do
      {:ok, _motorcycle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Motorcycle saved.")
         |> push_navigate(to: ~p"/admin/motorcycles")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp parse_tags(%{"tags_input" => raw} = params) do
    tags =
      raw
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(params, "tags", tags)
  end

  defp parse_tags(params), do: params

  defp tags_to_string(changeset) do
    changeset
    |> Ecto.Changeset.get_field(:tags)
    |> List.wrap()
    |> Enum.join(", ")
  end
end
