defmodule MotorcycleAdvisor.Garage.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :garage_bike]}

  @categories ~w(oil_change brake_pads chain tires insurance registration mod other)

  schema "expenses" do
    field :category, :string
    field :amount_cop, :integer
    field :spent_on, :date
    field :description, :string

    belongs_to :garage_bike, MotorcycleAdvisor.Garage.GarageBike

    timestamps()
  end

  @required [:category, :amount_cop, :spent_on]
  @optional [:description]

  def categories, do: @categories

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:category, @categories)
    |> validate_number(:amount_cop, greater_than: 0)
  end
end
