defmodule MotorcycleAdvisor.Repo.Migrations.CreateMotorcycles do
  use Ecto.Migration

  def change do
    create table(:motorcycles) do
      add :brand, :string, null: false
      add :model, :string, null: false
      add :year, :integer, null: false
      add :category, :string, null: false
      add :price_cop, :integer, null: false
      add :engine_cc, :integer, null: false
      add :power_hp, :integer
      add :weight_kg, :integer
      add :fuel_efficiency, :decimal, precision: 5, scale: 2
      add :experience_level, :string, null: false
      add :use_case, :string, null: false
      add :image_url, :string, null: false
      add :description, :text
      add :tags, {:array, :string}, default: []

      timestamps()
    end

    create index(:motorcycles, [:category])
    create index(:motorcycles, [:experience_level])
    create index(:motorcycles, [:use_case])
  end
end
