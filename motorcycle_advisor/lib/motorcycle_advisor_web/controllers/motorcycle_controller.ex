defmodule MotorcycleAdvisorWeb.MotorcycleController do
  use MotorcycleAdvisorWeb, :controller
  alias MotorcycleAdvisor.Catalog

  def index(conn, params) do
    motorcycles = Catalog.list_motorcycles(params)
    json(conn, %{data: motorcycles})
  end

  def show(conn, %{"id" => id}) do
    motorcycle = Catalog.get_motorcycle!(id)
    json(conn, %{data: motorcycle})
  end
end
