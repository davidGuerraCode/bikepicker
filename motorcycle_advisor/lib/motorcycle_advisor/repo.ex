defmodule MotorcycleAdvisor.Repo do
  use Ecto.Repo,
    otp_app: :motorcycle_advisor,
    adapter: Ecto.Adapters.Postgres
end
