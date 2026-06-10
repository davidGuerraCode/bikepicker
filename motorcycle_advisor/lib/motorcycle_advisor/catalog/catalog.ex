defmodule MotorcycleAdvisor.Catalog do
  import Ecto.Query
  alias MotorcycleAdvisor.Repo
  alias MotorcycleAdvisor.Catalog.Motorcycle

  @page_size 20

  def list_motorcycles(params \\ %{}) do
    page = Map.get(params, "page", 1) |> to_integer()
    per_page = Map.get(params, "per_page", @page_size) |> to_integer()
    offset = (page - 1) * per_page

    Motorcycle
    |> filter_by_category(params["category"])
    |> filter_by_experience(params["experience_level"])
    |> filter_by_use_case(params["use_case"])
    |> order_by([m], m.brand)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  def get_motorcycle!(id), do: Repo.get!(Motorcycle, id)

  def list_all_motorcycles do
    Repo.all(Motorcycle)
  end

  defp filter_by_category(query, nil), do: query
  defp filter_by_category(query, cat), do: where(query, [m], m.category == ^cat)

  defp filter_by_experience(query, nil), do: query
  defp filter_by_experience(query, exp), do: where(query, [m], m.experience_level == ^exp)

  defp filter_by_use_case(query, nil), do: query
  defp filter_by_use_case(query, uc), do: where(query, [m], m.use_case == ^uc)

  defp to_integer(val) when is_integer(val), do: val
  defp to_integer(val) when is_binary(val), do: String.to_integer(val)
  defp to_integer(_), do: 1
end
