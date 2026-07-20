defmodule MotorcycleAdvisorWeb.AuthController do
  use MotorcycleAdvisorWeb, :controller

  alias MotorcycleAdvisor.Accounts
  alias MotorcycleAdvisorWeb.ChangesetErrors

  def register(conn, params) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        token = Accounts.create_api_token(user)

        conn
        |> put_status(:created)
        |> json(%{data: user, token: token})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.translate(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "invalid email or password"}})

      user ->
        token = Accounts.create_api_token(user)
        json(conn, %{data: user, token: token})
    end
  end

  def logout(conn, _params) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      Accounts.delete_api_token(token)
    end

    send_resp(conn, :no_content, "")
  end

  def me(conn, _params) do
    json(conn, %{data: conn.assigns.current_user})
  end
end
