defmodule MotorcycleAdvisor.Repo.Migrations.CreateQuizQuestions do
  use Ecto.Migration

  def change do
    create table(:quiz_questions) do
      add :key, :string, null: false
      add :label, :string, null: false
      add :type, :string, null: false, default: "single_choice"
      add :options, :map, null: false
      add :order, :integer, null: false

      timestamps()
    end

    create unique_index(:quiz_questions, [:key])
    create index(:quiz_questions, [:order])
  end
end
