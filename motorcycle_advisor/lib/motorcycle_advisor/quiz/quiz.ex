defmodule MotorcycleAdvisor.Quiz do
  import Ecto.Query
  alias MotorcycleAdvisor.Repo
  alias MotorcycleAdvisor.Catalog
  alias MotorcycleAdvisor.Quiz.{Matcher, QuizQuestion}

  def match(answers) do
    motorcycles = Catalog.list_all_motorcycles()

    motorcycles
    |> Matcher.score_all(answers)
    |> Enum.take(3)
    |> Enum.map(fn {moto, score, partials} ->
      reasons = Matcher.explain_score(partials, answers)
      %{motorcycle: moto, score: score, reasons: reasons}
    end)
  end

  def list_questions do
    QuizQuestion
    |> order_by([q], q.order)
    |> Repo.all()
  end

  def get_question!(id), do: Repo.get!(QuizQuestion, id)

  def create_question(attrs) do
    %QuizQuestion{}
    |> QuizQuestion.changeset(attrs)
    |> Repo.insert()
  end

  def update_question(question, attrs) do
    question
    |> QuizQuestion.changeset(attrs)
    |> Repo.update()
  end

  def delete_question(question) do
    Repo.delete(question)
  end
end
