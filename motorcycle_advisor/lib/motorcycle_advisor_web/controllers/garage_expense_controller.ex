defmodule MotorcycleAdvisorWeb.GarageExpenseController do
  use MotorcycleAdvisorWeb, :controller

  alias MotorcycleAdvisor.Garage
  alias MotorcycleAdvisorWeb.ChangesetErrors

  def index(conn, %{"garage_bike_id" => bike_id}) do
    bike = Garage.get_bike!(conn.assigns.current_user, bike_id)
    json(conn, %{data: Garage.list_expenses(bike)})
  end

  def create(conn, %{"garage_bike_id" => bike_id} = params) do
    bike = Garage.get_bike!(conn.assigns.current_user, bike_id)

    case Garage.create_expense(bike, params) do
      {:ok, expense} ->
        conn |> put_status(:created) |> json(%{data: expense})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.translate(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    expense = Garage.get_expense!(conn.assigns.current_user, id)

    case Garage.update_expense(expense, params) do
      {:ok, expense} ->
        json(conn, %{data: expense})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.translate(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    expense = Garage.get_expense!(conn.assigns.current_user, id)
    {:ok, _expense} = Garage.delete_expense(expense)
    send_resp(conn, :no_content, "")
  end
end
