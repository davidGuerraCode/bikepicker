defmodule MotorcycleAdvisorWeb.Plugs.BasicAuth do
  import Plug.BasicAuth

  def init(opts), do: opts

  def call(conn, _opts) do
    basic_auth(conn, Application.fetch_env!(:motorcycle_advisor, :admin_basic_auth))
  end
end
