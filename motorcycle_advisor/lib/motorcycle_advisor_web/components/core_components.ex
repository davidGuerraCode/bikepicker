defmodule MotorcycleAdvisorWeb.CoreComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc "Flash group — only render in layouts.ex, never elsewhere."
  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  attr :kind, :atom, values: [:info, :error]
  attr :flash, :map, required: true

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      role="alert"
      class={[
        "fixed top-4 right-4 z-50 max-w-sm rounded-lg px-4 py-3 shadow-md text-sm",
        @kind == :info && "bg-blue-50 text-blue-800 border border-blue-200",
        @kind == :error && "bg-red-50 text-red-800 border border-red-200"
      ]}
      phx-click={JS.hide(to: "#flash-#{@kind}")}
      id={"flash-#{@kind}"}
    >
      <p class="font-medium">{msg}</p>
    </div>
    """
  end

  @doc "Page header with title and optional action slot."
  attr :title, :string, required: true
  slot :actions

  def page_header(assigns) do
    ~H"""
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">{@title}</h1>
      <div class="flex gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  @doc "Primary action button."
  attr :type, :string, default: "button"
  attr :variant, :string, default: "primary", values: ["primary", "secondary", "danger", "ghost"]
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled href navigate patch method phx-click phx-target)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-md transition-colors",
        @variant == "primary" && "bg-blue-600 text-white hover:bg-blue-700",
        @variant == "secondary" && "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50",
        @variant == "danger" && "bg-red-600 text-white hover:bg-red-700",
        @variant == "ghost" && "text-gray-600 hover:text-gray-900 hover:bg-gray-100",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc "Colored badge pill."
  attr :color, :string, default: "gray", values: ~w(gray blue green red yellow purple orange)
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium",
      @color == "gray" && "bg-gray-100 text-gray-700",
      @color == "blue" && "bg-blue-100 text-blue-700",
      @color == "green" && "bg-green-100 text-green-700",
      @color == "red" && "bg-red-100 text-red-700",
      @color == "yellow" && "bg-yellow-100 text-yellow-700",
      @color == "purple" && "bg-purple-100 text-purple-700",
      @color == "orange" && "bg-orange-100 text-orange-700"
    ]}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "Data table with named columns."
  attr :rows, :list, required: true
  attr :id, :string, required: true
  attr :row_id, :any, default: nil

  slot :col, required: true do
    attr :label, :string
  end

  slot :action

  def table(assigns) do
    ~H"""
    <div class="overflow-hidden rounded-lg border border-gray-200">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th
              :for={col <- @col}
              class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
            >
              {col.label}
            </th>
            <th :if={@action != []} class="relative px-4 py-3">
              <span class="sr-only">Actions</span>
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200" id={@id}>
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="hover:bg-gray-50 transition-colors"
          >
            <td :for={col <- @col} class="px-4 py-3 text-sm text-gray-900 whitespace-nowrap">
              {render_slot(col, row)}
            </td>
            <td :if={@action != []} class="px-4 py-3 text-sm text-right">
              <div class="flex justify-end gap-2">
                {render_slot(@action, row)}
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Form input with label and inline error."
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(text number textarea select checkbox hidden password url email)

  attr :field, Phoenix.HTML.FormField, doc: "form field struct from use Phoenix.HTML.Form"
  attr :errors, :list, default: []
  attr :required, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(autocomplete min max step rows cols)
  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> if assigns.type == "checkbox", do: field.name, else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@value}
        class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
        {@rest}
      />
      <label :if={@label} for={@id} class="text-sm font-medium text-gray-700">{@label}</label>
    </div>
    <.error :for={msg <- @errors}>{msg}</.error>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="space-y-1">
      <label :if={@label} for={@id} class="block text-sm font-medium text-gray-700">
        {@label}<span :if={@required} class="text-red-500 ml-0.5">*</span>
      </label>
      <select
        id={@id}
        name={@name}
        class={[
          "block w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500",
          @errors != [] && "border-red-500",
          @class
        ]}
        {@rest}
      >
        {render_slot(@inner_block)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="space-y-1">
      <label :if={@label} for={@id} class="block text-sm font-medium text-gray-700">
        {@label}<span :if={@required} class="text-red-500 ml-0.5">*</span>
      </label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500",
          @errors != [] && "border-red-500",
          @class
        ]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class="space-y-1">
      <label :if={@label} for={@id} class="block text-sm font-medium text-gray-700">
        {@label}<span :if={@required} class="text-red-500 ml-0.5">*</span>
      </label>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500",
          @errors != [] && "border-red-500",
          @class
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :on_confirm, JS, required: true
  slot :inner_block, required: true
  slot :title
  slot :confirm
  slot :cancel

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="hidden fixed inset-0 z-50 overflow-y-auto"
    >
      <div class="flex min-h-full items-center justify-center p-4">
        <div class="fixed inset-0 bg-gray-500/75 transition-opacity" phx-click={hide_modal(@id)} />
        <div class="relative z-10 w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
          <h3 :if={@title != []} class="text-base font-semibold text-gray-900 mb-2">
            {render_slot(@title)}
          </h3>
          <div class="text-sm text-gray-600 mb-4">
            {render_slot(@inner_block)}
          </div>
          <div class="flex justify-end gap-2">
            <.button :if={@cancel != []} variant="secondary" phx-click={hide_modal(@id)}>
              {render_slot(@cancel)}
            </.button>
            <.button variant="danger" phx-click={@on_confirm} phx-window-keydown={@on_confirm} phx-key="Enter">
              {render_slot(@confirm)}
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp show_modal(id) do
    JS.show(to: "##{id}")
    |> JS.show(to: "##{id} [data-modal-overlay]")
  end

  defp hide_modal(id) do
    JS.hide(to: "##{id}")
  end

  defp error(assigns) do
    ~H"""
    <p class="text-xs text-red-600 mt-0.5">{render_slot(@inner_block)}</p>
    """
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
