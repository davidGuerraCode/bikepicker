defmodule MotorcycleAdvisor.Repo.Migrations.CreateGarageBikes do
  use Ecto.Migration

  def change do
    create table(:garage_bikes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :nickname, :string
      add :brand, :string, null: false
      add :model, :string, null: false
      add :year, :integer

      timestamps()
    end

    create index(:garage_bikes, [:user_id])
  end
end
