defmodule MotorcycleAdvisorWeb.QuizController do
  use MotorcycleAdvisorWeb, :controller
  alias MotorcycleAdvisor.Quiz

  def match(conn, %{"answers" => answers}) do
    recommendations = Quiz.match(answers)
    json(conn, %{recommendations: recommendations})
  end

  def questions(conn, _params) do
    questions = Quiz.list_questions()
    json(conn, %{data: questions})
  end
end
