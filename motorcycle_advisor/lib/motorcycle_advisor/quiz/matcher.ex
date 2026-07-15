defmodule MotorcycleAdvisor.Quiz.Matcher do
  @budget_ranges %{
    "low" => {0, 8_000_000},
    "medium" => {8_000_001, 20_000_000},
    "high" => {20_000_001, :infinity}
  }

  @style_tags %{"style" => ["estilosa", "icónica"], "tech" => ["tecnológica", "conectada"]}

  @comfort_categories ["touring", "cruiser", "adventure"]

  # Similarity between motorcycle categories, keyed by sorted {a, b} tuples.
  # Diagonal = 1.0 (exact match). Off-diagonal reflects "family" closeness
  # (e.g. touring/adventure/cruiser are comfort-oriented cousins).
  @category_similarity %{
    {"adventure", "adventure"} => 1.0,
    {"cruiser", "cruiser"} => 1.0,
    {"naked", "naked"} => 1.0,
    {"offroad", "offroad"} => 1.0,
    {"scooter", "scooter"} => 1.0,
    {"sport", "sport"} => 1.0,
    {"touring", "touring"} => 1.0,
    {"adventure", "cruiser"} => 0.4,
    {"adventure", "naked"} => 0.4,
    {"adventure", "offroad"} => 0.6,
    {"adventure", "scooter"} => 0.1,
    {"adventure", "sport"} => 0.2,
    {"adventure", "touring"} => 0.6,
    {"cruiser", "naked"} => 0.3,
    {"cruiser", "offroad"} => 0.1,
    {"cruiser", "scooter"} => 0.2,
    {"cruiser", "sport"} => 0.1,
    {"cruiser", "touring"} => 0.6,
    {"naked", "offroad"} => 0.2,
    {"naked", "scooter"} => 0.3,
    {"naked", "sport"} => 0.6,
    {"naked", "touring"} => 0.3,
    {"offroad", "scooter"} => 0.1,
    {"offroad", "sport"} => 0.1,
    {"offroad", "touring"} => 0.3,
    {"scooter", "sport"} => 0.1,
    {"scooter", "touring"} => 0.2,
    {"sport", "touring"} => 0.1
  }

  @reason_templates %{
    use_case: %{
      "urban" => "Ideal para moverse en ciudad",
      "highway" => "Potente en carretera",
      "mixed" => "Versátil para ciudad y carretera",
      "offroad" => "Preparada para todo terreno",
      "track" => "Diseñada para pista"
    },
    experience: %{
      "beginner" => "Perfecta para principiantes",
      "intermediate" => "Ideal para rider con experiencia",
      "advanced" => "Diseñada para riders exigentes"
    },
    budget: %{
      "low" => "Excelente relación calidad-precio",
      "medium" => "Equipamiento sólido a buen precio",
      "high" => "Moto premium sin compromisos"
    },
    priority: %{
      "economy" => "Muy eficiente en combustible",
      "power" => "Alta potencia para los que la exigen",
      "comfort" => "Ligera y fácil de maniobrar",
      "style" => "Diseño que llama la atención",
      "tech" => "Cargada de tecnología"
    },
    category: %{
      "naked" => "Estilo naked que buscabas",
      "sport" => "Pura deportividad",
      "cruiser" => "Cruiser para disfrutar el camino",
      "adventure" => "Lista para cualquier aventura",
      "scooter" => "Práctica para el día a día",
      "touring" => "Cómoda en viajes largos",
      "offroad" => "Domina el terreno difícil"
    }
  }

  def score_all(motorcycles, answers) do
    motorcycles
    |> Enum.map(fn moto ->
      {score, partials} = compute_score(moto, answers)
      {moto, score, partials}
    end)
    |> Enum.sort_by(fn {_, score, _} -> score end, :desc)
  end

  def explain_score(partials, answers) do
    partials
    |> Enum.filter(fn {_criterion, score} -> score > 0 end)
    |> Enum.sort_by(fn {_criterion, score} -> score end, :desc)
    |> Enum.take(3)
    |> Enum.map(fn {criterion, _score} ->
      get_reason(criterion, answers[criterion])
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp compute_score(moto, answers) do
    use_case_score = score_use_case(moto, answers["use_case"]) * 0.25
    budget_score = score_budget(moto, answers["budget"]) * 0.20
    experience_score = score_experience(moto, answers["experience"]) * 0.20
    priority_score = score_priority(moto, answers["priority"]) * 0.10
    category_score = score_category(moto, answers["category"]) * 0.25

    total =
      round(
        (use_case_score + budget_score + experience_score + priority_score + category_score) * 100
      )

    partials = %{
      "use_case" => use_case_score,
      "budget" => budget_score,
      "experience" => experience_score,
      "priority" => priority_score,
      "category" => category_score
    }

    {total, partials}
  end

  defp score_use_case(moto, answer) when is_binary(answer) do
    if moto.use_case == answer, do: 1.0, else: 0.0
  end

  defp score_use_case(_, _), do: 0.0

  defp score_budget(moto, answer) when is_binary(answer) do
    case Map.get(@budget_ranges, answer) do
      {min, :infinity} -> if moto.price_cop >= min, do: 1.0, else: 0.0
      {min, max} -> if moto.price_cop >= min and moto.price_cop <= max, do: 1.0, else: 0.0
      _ -> 0.0
    end
  end

  defp score_budget(_, _), do: 0.0

  defp score_experience(moto, answer) when is_binary(answer) do
    if moto.experience_level == answer, do: 1.0, else: 0.0
  end

  defp score_experience(_, _), do: 0.0

  defp score_priority(moto, "economy") do
    score_numeric(moto.fuel_efficiency && Decimal.to_float(moto.fuel_efficiency), 20.0, 55.0)
  end

  defp score_priority(moto, "power") do
    score_numeric(moto.power_hp, 10, 160)
  end

  defp score_priority(moto, "comfort") do
    weight_score =
      if moto.weight_kg, do: 1.0 - score_numeric(moto.weight_kg, 80, 300), else: 0.0

    category_bonus = if moto.category in @comfort_categories, do: 1.0, else: 0.0

    0.6 * weight_score + 0.4 * category_bonus
  end

  defp score_priority(moto, priority) when priority in ["style", "tech"] do
    target_tags = Map.get(@style_tags, priority, [])
    if Enum.any?(moto.tags, &(&1 in target_tags)), do: 1.0, else: 0.0
  end

  defp score_priority(_, _), do: 0.0

  defp score_category(moto, answer) when is_binary(answer) do
    category_similarity(moto.category, answer)
  end

  defp score_category(_, _), do: 0.0

  defp category_similarity(a, b) do
    key = if a <= b, do: {a, b}, else: {b, a}
    Map.get(@category_similarity, key, 0.0)
  end

  defp score_numeric(nil, _, _), do: 0.0

  defp score_numeric(value, min, max) do
    clamped = max(min, min(max, value))
    (clamped - min) / (max - min)
  end

  defp get_reason(criterion, answer) when is_binary(answer) do
    get_in(@reason_templates, [String.to_existing_atom(criterion), answer])
  end

  defp get_reason(_, _), do: nil
end
