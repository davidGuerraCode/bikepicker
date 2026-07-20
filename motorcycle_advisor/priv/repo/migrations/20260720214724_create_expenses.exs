defmodule MotorcycleAdvisor.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :garage_bike_id, references(:garage_bikes, on_delete: :delete_all), null: false
      add :category, :string, null: false
      add :amount_cop, :integer, null: false
      add :spent_on, :date, null: false
      add :description, :string

      timestamps()
    end

    create index(:expenses, [:garage_bike_id])
    create index(:expenses, [:category])
    create index(:expenses, [:spent_on])
  end
end
