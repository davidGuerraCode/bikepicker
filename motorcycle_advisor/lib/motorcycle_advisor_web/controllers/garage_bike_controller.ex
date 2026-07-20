defmodule MotorcycleAdvisorWeb.GarageBikeController do
  use MotorcycleAdvisorWeb, :controller

  alias MotorcycleAdvisor.Garage
  alias MotorcycleAdvisorWeb.ChangesetErrors

  def index(conn, _params) do
    bikes = Garage.list_bikes(conn.assigns.current_user)
    json(conn, %{data: bikes})
  end

  def show(conn, %{"id" => id}) do
    bike = Garage.get_bike!(conn.assigns.current_user, id)
    json(conn, %{data: bike})
  end

  def create(conn, params) do
    case Garage.create_bike(conn.assigns.current_user, params) do
      {:ok, bike} ->
        conn |> put_status(:created) |> json(%{data: bike})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.translate(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    bike = Garage.get_bike!(conn.assigns.current_user, id)

    case Garage.update_bike(bike, params) do
      {:ok, bike} ->
        json(conn, %{data: bike})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.translate(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    bike = Garage.get_bike!(conn.assigns.current_user, id)
    {:ok, _bike} = Garage.delete_bike(bike)
    send_resp(conn, :no_content, "")
  end

  def summary(conn, %{"garage_bike_id" => id}) do
    bike = Garage.get_bike!(conn.assigns.current_user, id)
    json(conn, %{data: Garage.bike_summary(bike)})
  end
end
