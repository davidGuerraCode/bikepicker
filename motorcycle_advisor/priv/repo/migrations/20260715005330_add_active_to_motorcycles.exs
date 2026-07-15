defmodule MotorcycleAdvisor.Repo.Migrations.AddActiveToMotorcycles do
  use Ecto.Migration

  def change do
    alter table(:motorcycles) do
      add :active, :boolean, default: true, null: false
    end
  end
end
