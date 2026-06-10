defmodule MotorcycleAdvisor.Quiz.QuizQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "quiz_questions" do
    field :key, :string
    field :label, :string
    field :type, :string, default: "single_choice"
    field :options, :map
    field :order, :integer

    timestamps()
  end

  @required [:key, :label, :type, :options, :order]

  def changeset(question, attrs) do
    question
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> unique_constraint(:key)
  end
end
