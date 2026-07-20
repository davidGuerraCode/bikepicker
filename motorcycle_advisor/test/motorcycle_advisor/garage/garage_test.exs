defmodule MotorcycleAdvisor.GarageTest do
  use MotorcycleAdvisor.DataCase, async: true

  alias MotorcycleAdvisor.{Accounts, Garage}

  setup do
    {:ok, user} =
      Accounts.register_user(%{"email" => "rider@example.com", "password" => "supersecret123"})

    {:ok, other_user} =
      Accounts.register_user(%{"email" => "other@example.com", "password" => "supersecret123"})

    %{user: user, other_user: other_user}
  end

  describe "bikes" do
    test "create_bike/2 inserts scoped to the user", %{user: user} do
      assert {:ok, bike} = Garage.create_bike(user, %{"brand" => "Honda", "model" => "CB500X"})
      assert bike.user_id == user.id
    end

    test "list_bikes/1 only returns the given user's bikes", %{user: user, other_user: other} do
      {:ok, _mine} = Garage.create_bike(user, %{"brand" => "Honda", "model" => "CB500X"})
      {:ok, _theirs} = Garage.create_bike(other, %{"brand" => "Yamaha", "model" => "MT-07"})

      assert [bike] = Garage.list_bikes(user)
      assert bike.brand == "Honda"
    end

    test "get_bike!/2 raises when the bike belongs to another user", %{
      user: user,
      other_user: other
    } do
      {:ok, bike} = Garage.create_bike(other, %{"brand" => "Yamaha", "model" => "MT-07"})

      assert_raise Ecto.NoResultsError, fn ->
        Garage.get_bike!(user, bike.id)
      end
    end
  end

  describe "expenses and summaries" do
    test "bike_summary/1 aggregates totals by category and month", %{user: user} do
      {:ok, bike} = Garage.create_bike(user, %{"brand" => "Honda", "model" => "CB500X"})

      {:ok, _} =
        Garage.create_expense(bike, %{
          "category" => "oil_change",
          "amount_cop" => 100_000,
          "spent_on" => ~D[2026-01-15]
        })

      {:ok, _} =
        Garage.create_expense(bike, %{
          "category" => "chain",
          "amount_cop" => 200_000,
          "spent_on" => ~D[2026-01-20]
        })

      summary = Garage.bike_summary(bike)

      assert summary.total_cop == 300_000
      assert summary.by_category["oil_change"] == 100_000
      assert summary.by_category["chain"] == 200_000
      assert [%{month: ~D[2026-01-01], total_cop: 300_000}] = summary.by_month
    end

    test "user_summary/1 aggregates across all of a user's bikes", %{user: user} do
      {:ok, bike_a} = Garage.create_bike(user, %{"brand" => "Honda", "model" => "CB500X"})
      {:ok, bike_b} = Garage.create_bike(user, %{"brand" => "Kawasaki", "model" => "Versys"})

      {:ok, _} =
        Garage.create_expense(bike_a, %{
          "category" => "oil_change",
          "amount_cop" => 100_000,
          "spent_on" => ~D[2026-01-15]
        })

      {:ok, _} =
        Garage.create_expense(bike_b, %{
          "category" => "tires",
          "amount_cop" => 500_000,
          "spent_on" => ~D[2026-02-01]
        })

      summary = Garage.user_summary(user)
      assert summary.total_cop == 600_000
    end

    test "get_expense!/2 raises when the expense's bike belongs to another user", %{
      user: user,
      other_user: other
    } do
      {:ok, bike} = Garage.create_bike(other, %{"brand" => "Yamaha", "model" => "MT-07"})

      {:ok, expense} =
        Garage.create_expense(bike, %{
          "category" => "chain",
          "amount_cop" => 50_000,
          "spent_on" => ~D[2026-01-01]
        })

      assert_raise Ecto.NoResultsError, fn ->
        Garage.get_expense!(user, expense.id)
      end
    end

    test "create_expense/2 rejects invalid category", %{user: user} do
      {:ok, bike} = Garage.create_bike(user, %{"brand" => "Honda", "model" => "CB500X"})

      assert {:error, changeset} =
               Garage.create_expense(bike, %{
                 "category" => "nitrous",
                 "amount_cop" => 50_000,
                 "spent_on" => ~D[2026-01-01]
               })

      assert "is invalid" in errors_on(changeset).category
    end
  end
end
