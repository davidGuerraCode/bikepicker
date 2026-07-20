defmodule MotorcycleAdvisor.Garage do
  import Ecto.Query
  alias MotorcycleAdvisor.Repo
  alias MotorcycleAdvisor.Garage.{GarageBike, Expense}

  def categories, do: Expense.categories()

  def list_bikes(user) do
    GarageBike
    |> where([b], b.user_id == ^user.id)
    |> order_by([b], desc: b.inserted_at)
    |> Repo.all()
  end

  def get_bike!(user, id) do
    GarageBike
    |> where([b], b.user_id == ^user.id)
    |> Repo.get!(id)
  end

  def create_bike(user, attrs) do
    %GarageBike{user_id: user.id}
    |> GarageBike.changeset(attrs)
    |> Repo.insert()
  end

  def update_bike(bike, attrs) do
    bike
    |> GarageBike.changeset(attrs)
    |> Repo.update()
  end

  def delete_bike(bike), do: Repo.delete(bike)

  def list_expenses(bike) do
    Expense
    |> where([e], e.garage_bike_id == ^bike.id)
    |> order_by([e], desc: e.spent_on)
    |> Repo.all()
  end

  def get_expense!(user, id) do
    Expense
    |> join(:inner, [e], b in GarageBike, on: e.garage_bike_id == b.id)
    |> where([e, b], b.user_id == ^user.id)
    |> select([e, b], e)
    |> Repo.get!(id)
  end

  def create_expense(bike, attrs) do
    %Expense{garage_bike_id: bike.id}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  def update_expense(expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  def delete_expense(expense), do: Repo.delete(expense)

  def bike_summary(bike) do
    base = where(Expense, [e], e.garage_bike_id == ^bike.id)
    build_summary(base)
  end

  def user_summary(user) do
    base =
      Expense
      |> join(:inner, [e], b in GarageBike, on: e.garage_bike_id == b.id)
      |> where([e, b], b.user_id == ^user.id)

    build_summary(base)
  end

  defp build_summary(base_query) do
    total_cop = base_query |> select([e], sum(e.amount_cop)) |> Repo.one() || 0

    by_category =
      base_query
      |> group_by([e], e.category)
      |> select([e], {e.category, sum(e.amount_cop)})
      |> Repo.all()
      |> Map.new()

    by_month =
      base_query
      |> group_by([e], fragment("date_trunc('month', ?)", e.spent_on))
      |> order_by([e], fragment("date_trunc('month', ?)", e.spent_on))
      |> select([e], {fragment("date_trunc('month', ?)", e.spent_on), sum(e.amount_cop)})
      |> Repo.all()
      |> Enum.map(fn {month, total} ->
        %{month: NaiveDateTime.to_date(month), total_cop: total}
      end)

    %{total_cop: total_cop, by_category: by_category, by_month: by_month}
  end
end
