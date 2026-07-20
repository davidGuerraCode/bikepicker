defmodule MotorcycleAdvisorWeb.Plugs.RequireAuthenticatedApiUser do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias MotorcycleAdvisor.Accounts
  alias MotorcycleAdvisor.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %User{} = user <- Accounts.get_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "unauthorized"}})
        |> halt()
    end
  end
end
