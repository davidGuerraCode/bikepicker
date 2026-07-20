defmodule MotorcycleAdvisorWeb.GarageExpenseControllerTest do
  use MotorcycleAdvisorWeb.ConnCase, async: true

  setup [:register_and_authenticate_user]

  setup %{conn: conn} do
    create_resp = post(conn, ~p"/api/garage/bikes", %{"brand" => "Honda", "model" => "CB500X"})
    %{"data" => %{"id" => bike_id}} = json_response(create_resp, 201)
    %{bike_id: bike_id}
  end

  describe "POST /api/garage/bikes/:garage_bike_id/expenses" do
    test "creates an expense for the bike", %{conn: conn, bike_id: bike_id} do
      conn =
        post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
          "category" => "chain",
          "amount_cop" => 150_000,
          "spent_on" => "2026-02-01"
        })

      assert %{"data" => %{"category" => "chain", "amount_cop" => 150_000}} =
               json_response(conn, 201)
    end

    test "returns 422 for an invalid category", %{conn: conn, bike_id: bike_id} do
      conn =
        post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
          "category" => "nitrous",
          "amount_cop" => 150_000,
          "spent_on" => "2026-02-01"
        })

      assert %{"errors" => %{"category" => _}} = json_response(conn, 422)
    end
  end

  describe "PATCH/DELETE /api/garage/expenses/:id" do
    test "updates an expense", %{conn: conn, bike_id: bike_id} do
      create_resp =
        post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
          "category" => "chain",
          "amount_cop" => 150_000,
          "spent_on" => "2026-02-01"
        })

      %{"data" => %{"id" => expense_id}} = json_response(create_resp, 201)

      conn = patch(conn, ~p"/api/garage/expenses/#{expense_id}", %{"amount_cop" => 175_000})
      assert %{"data" => %{"amount_cop" => 175_000}} = json_response(conn, 200)
    end

    test "deletes an expense", %{conn: conn, bike_id: bike_id} do
      create_resp =
        post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
          "category" => "chain",
          "amount_cop" => 150_000,
          "spent_on" => "2026-02-01"
        })

      %{"data" => %{"id" => expense_id}} = json_response(create_resp, 201)

      conn = delete(conn, ~p"/api/garage/expenses/#{expense_id}")
      assert response(conn, 204)
    end

    test "a user cannot update or delete another user's expense", %{conn: conn, bike_id: bike_id} do
      create_resp =
        post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
          "category" => "chain",
          "amount_cop" => 150_000,
          "spent_on" => "2026-02-01"
        })

      %{"data" => %{"id" => expense_id}} = json_response(create_resp, 201)

      %{conn: other_conn} = register_and_authenticate_user(%{conn: build_conn()})

      assert_error_sent 404, fn ->
        patch(other_conn, ~p"/api/garage/expenses/#{expense_id}", %{"amount_cop" => 1})
      end

      assert_error_sent 404, fn ->
        delete(other_conn, ~p"/api/garage/expenses/#{expense_id}")
      end
    end
  end
end
