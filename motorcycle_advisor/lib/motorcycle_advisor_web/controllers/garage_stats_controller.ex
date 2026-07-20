defmodule MotorcycleAdvisorWeb.GarageStatsController do
  use MotorcycleAdvisorWeb, :controller

  alias MotorcycleAdvisor.Garage

  def summary(conn, _params) do
    json(conn, %{data: Garage.user_summary(conn.assigns.current_user)})
  end
end
