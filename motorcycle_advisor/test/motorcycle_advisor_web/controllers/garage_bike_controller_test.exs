defmodule MotorcycleAdvisorWeb.GarageBikeControllerTest do
  use MotorcycleAdvisorWeb.ConnCase, async: true

  setup [:register_and_authenticate_user]

  describe "POST /api/garage/bikes" do
    test "creates a bike scoped to the current user", %{conn: conn} do
      conn = post(conn, ~p"/api/garage/bikes", %{"brand" => "Honda", "model" => "CB500X"})
      assert %{"data" => %{"brand" => "Honda", "model" => "CB500X"}} = json_response(conn, 201)
    end

    test "returns 422 for missing required fields", %{conn: conn} do
      conn = post(conn, ~p"/api/garage/bikes", %{})
      assert %{"errors" => %{"brand" => _}} = json_response(conn, 422)
    end
  end

  describe "GET /api/garage/bikes" do
    test "only lists the current user's bikes", %{conn: conn} do
      post(conn, ~p"/api/garage/bikes", %{"brand" => "Honda", "model" => "CB500X"})

      conn = get(conn, ~p"/api/garage/bikes")
      assert %{"data" => [%{"brand" => "Honda"}]} = json_response(conn, 200)
    end
  end

  describe "ownership scoping" do
    test "a user cannot read, update, or delete another user's bike", %{conn: conn} do
      %{conn: other_conn} = register_and_authenticate_user(%{conn: build_conn()})

      create_resp =
        post(other_conn, ~p"/api/garage/bikes", %{"brand" => "Yamaha", "model" => "MT-07"})

      %{"data" => %{"id" => other_bike_id}} = json_response(create_resp, 201)

      assert_error_sent 404, fn -> get(conn, ~p"/api/garage/bikes/#{other_bike_id}") end
      assert_error_sent 404, fn -> delete(conn, ~p"/api/garage/bikes/#{other_bike_id}") end
    end
  end

  describe "GET /api/garage/bikes/:garage_bike_id/summary" do
    test "returns totals for the bike's expenses", %{conn: conn} do
      create_resp = post(conn, ~p"/api/garage/bikes", %{"brand" => "Honda", "model" => "CB500X"})
      %{"data" => %{"id" => bike_id}} = json_response(create_resp, 201)

      post(conn, ~p"/api/garage/bikes/#{bike_id}/expenses", %{
        "category" => "oil_change",
        "amount_cop" => 100_000,
        "spent_on" => "2026-01-15"
      })

      conn = get(conn, ~p"/api/garage/bikes/#{bike_id}/summary")
      assert %{"data" => %{"total_cop" => 100_000}} = json_response(conn, 200)
    end
  end
end
