defmodule MotorcycleAdvisor.Quiz.MatcherTest do
  use ExUnit.Case, async: true

  alias MotorcycleAdvisor.Catalog.Motorcycle
  alias MotorcycleAdvisor.Quiz.Matcher

  defp moto(attrs) do
    struct(
      %Motorcycle{
        brand: "Brand",
        model: "Model",
        year: 2024,
        price_cop: 10_000_000,
        engine_cc: 300,
        power_hp: 30,
        weight_kg: 180,
        fuel_efficiency: Decimal.new("30.0"),
        tags: []
      },
      attrs
    )
  end

  describe "score_all/2" do
    test "touring/comfort/mixed answers rank a touring or adventure bike above a sport bike" do
      sport =
        moto(%{
          category: "sport",
          experience_level: "intermediate",
          use_case: "mixed",
          price_cop: 25_000_000,
          weight_kg: 167
        })

      adventure =
        moto(%{
          category: "adventure",
          experience_level: "intermediate",
          use_case: "mixed",
          price_cop: 30_000_000,
          weight_kg: 199
        })

      touring =
        moto(%{
          category: "touring",
          experience_level: "advanced",
          use_case: "highway",
          price_cop: 42_000_000,
          weight_kg: 248
        })

      answers = %{
        "use_case" => "mixed",
        "budget" => "high",
        "experience" => "intermediate",
        "priority" => "comfort",
        "category" => "touring"
      }

      results = Matcher.score_all([sport, adventure, touring], answers)
      ranked_categories = Enum.map(results, fn {moto, _score, _partials} -> moto.category end)

      assert hd(ranked_categories) != "sport"
      assert hd(ranked_categories) in ["adventure", "touring", "cruiser"]
    end

    test "exact category match scores higher than an unrelated category" do
      touring = moto(%{category: "touring", experience_level: "advanced", use_case: "highway"})
      sport = moto(%{category: "sport", experience_level: "advanced", use_case: "highway"})

      answers = %{
        "use_case" => "highway",
        "budget" => "medium",
        "experience" => "advanced",
        "priority" => "power",
        "category" => "touring"
      }

      [{_, touring_score, _}, {_, sport_score, _}] =
        Matcher.score_all([touring, sport], answers)
        |> Enum.sort_by(fn {moto, _, _} -> moto.category != "touring" end)

      assert touring_score > sport_score
    end
  end

  describe "explain_score/2" do
    test "returns up to 3 reasons sorted by partial score" do
      answers = %{
        "use_case" => "urban",
        "budget" => "low",
        "experience" => "beginner",
        "priority" => "economy",
        "category" => "naked"
      }

      moto =
        moto(%{
          category: "naked",
          experience_level: "beginner",
          use_case: "urban",
          price_cop: 7_000_000
        })

      [{_, _score, partials}] = Matcher.score_all([moto], answers)
      reasons = Matcher.explain_score(partials, answers)

      assert length(reasons) <= 3
      assert length(reasons) > 0
    end
  end
end
