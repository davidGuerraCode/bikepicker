defmodule MotorcycleAdvisorWeb.AuthControllerTest do
  use MotorcycleAdvisorWeb.ConnCase, async: true

  describe "POST /api/auth/register" do
    test "creates a user and returns a token", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/register", %{
          "email" => "rider@example.com",
          "password" => "supersecret123"
        })

      assert %{"data" => %{"email" => "rider@example.com"}, "token" => token} =
               json_response(conn, 201)

      assert is_binary(token)
    end

    test "returns 422 for invalid attrs", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/register", %{"email" => "not-an-email", "password" => "short"})

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["email"]
      assert errors["password"]
    end
  end

  describe "POST /api/auth/login" do
    setup %{conn: conn} do
      post(conn, ~p"/api/auth/register", %{
        "email" => "rider@example.com",
        "password" => "supersecret123"
      })

      :ok
    end

    test "returns a token for valid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{
          "email" => "rider@example.com",
          "password" => "supersecret123"
        })

      assert %{"data" => %{"email" => "rider@example.com"}, "token" => token} =
               json_response(conn, 200)

      assert is_binary(token)
    end

    test "returns 401 for invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{
          "email" => "rider@example.com",
          "password" => "wrongpassword"
        })

      assert json_response(conn, 401)
    end
  end

  describe "authenticated endpoints" do
    setup [:register_and_authenticate_user]

    test "GET /api/auth/me returns the current user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/auth/me")
      assert %{"data" => %{"email" => email}} = json_response(conn, 200)
      assert email == user.email
    end

    test "DELETE /api/auth/logout invalidates the token", %{conn: conn} do
      conn = delete(conn, ~p"/api/auth/logout")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/auth/me")
      assert json_response(conn, 401)
    end

    test "GET /api/auth/me without a token returns 401", %{conn: conn} do
      conn = conn |> Plug.Conn.delete_req_header("authorization") |> get(~p"/api/auth/me")
      assert json_response(conn, 401)
    end
  end
end
