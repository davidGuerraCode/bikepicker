defmodule MotorcycleAdvisor.Garage.GarageBike do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :user, :expenses]}

  schema "garage_bikes" do
    field :nickname, :string
    field :brand, :string
    field :model, :string
    field :year, :integer

    belongs_to :user, MotorcycleAdvisor.Accounts.User
    has_many :expenses, MotorcycleAdvisor.Garage.Expense

    timestamps()
  end

  @required [:brand, :model]
  @optional [:nickname, :year]

  def changeset(garage_bike, attrs) do
    garage_bike
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
