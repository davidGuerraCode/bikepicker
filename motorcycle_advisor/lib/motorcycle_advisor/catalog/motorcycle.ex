defmodule MotorcycleAdvisor.Catalog.Motorcycle do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "motorcycles" do
    field :brand, :string
    field :model, :string
    field :year, :integer
    field :category, :string
    field :price_cop, :integer
    field :engine_cc, :integer
    field :power_hp, :integer
    field :weight_kg, :integer
    field :fuel_efficiency, :decimal
    field :experience_level, :string
    field :use_case, :string
    field :image_url, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @required [
    :brand,
    :model,
    :year,
    :category,
    :price_cop,
    :engine_cc,
    :image_url,
    :experience_level,
    :use_case
  ]
  @optional [:power_hp, :weight_kg, :fuel_efficiency, :description, :tags, :active]

  def changeset(motorcycle, attrs) do
    motorcycle
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:category, ~w(naked sport cruiser adventure scooter touring offroad))
    |> validate_inclusion(:experience_level, ~w(beginner intermediate advanced))
    |> validate_inclusion(:use_case, ~w(urban highway mixed offroad track))
    |> validate_number(:price_cop, greater_than: 0)
  end
end
