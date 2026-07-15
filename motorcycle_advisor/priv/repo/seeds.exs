alias MotorcycleAdvisor.Repo
alias MotorcycleAdvisor.Catalog.Motorcycle
alias MotorcycleAdvisor.Quiz.QuizQuestion

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

# ── Motorcycles ──────────────────────────────────────────────────────────────

motorcycles = [
  # NAKED — beginner
  %{
    brand: "Honda",
    model: "CB190R",
    year: 2024,
    category: "naked",
    price_cop: 7_500_000,
    engine_cc: 184,
    power_hp: 17,
    weight_kg: 138,
    fuel_efficiency: Decimal.new("45.0"),
    experience_level: "beginner",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=Honda+CB190R",
    description: "Naked urbana ideal para empezar, ligera y económica.",
    tags: ["económica", "ágil", "principiante"]
  },
  %{
    brand: "Yamaha",
    model: "FZ25",
    year: 2024,
    category: "naked",
    price_cop: 11_200_000,
    engine_cc: 249,
    power_hp: 21,
    weight_kg: 153,
    fuel_efficiency: Decimal.new("38.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Yamaha+FZ25",
    description: "Naked versátil con buen rendimiento en ciudad y carretera.",
    tags: ["ágil", "versátil", "tecnológica"]
  },
  %{
    brand: "KTM",
    model: "Duke 390",
    year: 2024,
    category: "naked",
    price_cop: 21_500_000,
    engine_cc: 373,
    power_hp: 44,
    weight_kg: 163,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "advanced",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=KTM+Duke+390",
    description: "Naked agresiva con potencia y tecnología premium.",
    tags: ["potente", "tecnológica", "estilosa", "icónica"]
  },
  %{
    brand: "Bajaj",
    model: "Pulsar NS200",
    year: 2024,
    category: "naked",
    price_cop: 9_800_000,
    engine_cc: 199,
    power_hp: 24,
    weight_kg: 156,
    fuel_efficiency: Decimal.new("35.0"),
    experience_level: "intermediate",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=Bajaj+NS200",
    description: "Naked accesible con buen desempeño urbano.",
    tags: ["económica", "potente", "ágil"]
  },

  # SPORT — intermediate/advanced
  %{
    brand: "Kawasaki",
    model: "Ninja 400",
    year: 2024,
    category: "sport",
    price_cop: 23_000_000,
    engine_cc: 399,
    power_hp: 45,
    weight_kg: 167,
    fuel_efficiency: Decimal.new("28.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Kawasaki+Ninja+400",
    description: "Sport accesible con rendimiento cercano al nivel de competición.",
    tags: ["deportiva", "potente", "estilosa"]
  },
  %{
    brand: "Honda",
    model: "CBR600RR",
    year: 2024,
    category: "sport",
    price_cop: 45_000_000,
    engine_cc: 599,
    power_hp: 117,
    weight_kg: 194,
    fuel_efficiency: Decimal.new("22.0"),
    experience_level: "advanced",
    use_case: "track",
    image_url: "https://placehold.co/600x400?text=Honda+CBR600RR",
    description: "Supersport pura, pensada para pista y riders expertos.",
    tags: ["deportiva", "potente", "icónica", "tecnológica"]
  },
  %{
    brand: "Yamaha",
    model: "R3",
    year: 2024,
    category: "sport",
    price_cop: 16_500_000,
    engine_cc: 321,
    power_hp: 42,
    weight_kg: 169,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Yamaha+R3",
    description: "Deportiva de entrada ideal para riders que quieren estilo.",
    tags: ["deportiva", "estilosa", "principiante"]
  },
  %{
    brand: "Suzuki",
    model: "GSX-R750",
    year: 2024,
    category: "sport",
    price_cop: 38_000_000,
    engine_cc: 750,
    power_hp: 148,
    weight_kg: 203,
    fuel_efficiency: Decimal.new("20.0"),
    experience_level: "advanced",
    use_case: "track",
    image_url: "https://placehold.co/600x400?text=Suzuki+GSX-R750",
    description: "Supersport legendaria para riders de alto nivel.",
    tags: ["deportiva", "potente", "icónica"]
  },

  # ADVENTURE — all levels
  %{
    brand: "Honda",
    model: "CB500X",
    year: 2024,
    category: "adventure",
    price_cop: 20_000_000,
    engine_cc: 471,
    power_hp: 47,
    weight_kg: 197,
    fuel_efficiency: Decimal.new("27.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Honda+CB500X",
    description: "Adventure accesible, cómoda en ciudad y carretera.",
    tags: ["versátil", "cómoda", "principiante"]
  },
  %{
    brand: "BMW",
    model: "F850GS",
    year: 2024,
    category: "adventure",
    price_cop: 55_000_000,
    engine_cc: 853,
    power_hp: 95,
    weight_kg: 220,
    fuel_efficiency: Decimal.new("22.0"),
    experience_level: "advanced",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=BMW+F850GS",
    description: "Adventure premium para viajes largos y cualquier terreno.",
    tags: ["premium", "potente", "tecnológica", "cómoda"]
  },
  %{
    brand: "Royal Enfield",
    model: "Himalayan 450",
    year: 2024,
    category: "adventure",
    price_cop: 18_500_000,
    engine_cc: 452,
    power_hp: 40,
    weight_kg: 196,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "intermediate",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=RE+Himalayan+450",
    description: "Adventure accesible con capacidad off-road real.",
    tags: ["versátil", "offroad", "económica"]
  },
  %{
    brand: "KTM",
    model: "390 Adventure",
    year: 2024,
    category: "adventure",
    price_cop: 26_000_000,
    engine_cc: 373,
    power_hp: 44,
    weight_kg: 177,
    fuel_efficiency: Decimal.new("28.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=KTM+390+Adventure",
    description: "Adventure compacta con tecnología premium de KTM.",
    tags: ["tecnológica", "versátil", "estilosa"]
  },

  # CRUISER
  %{
    brand: "Honda",
    model: "Shadow 750",
    year: 2024,
    category: "cruiser",
    price_cop: 28_000_000,
    engine_cc: 745,
    power_hp: 45,
    weight_kg: 233,
    fuel_efficiency: Decimal.new("25.0"),
    experience_level: "intermediate",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Honda+Shadow+750",
    description: "Cruiser clásica con motor en V de carácter suave.",
    tags: ["cómoda", "icónica", "estilosa"]
  },
  %{
    brand: "Harley-Davidson",
    model: "Iron 883",
    year: 2024,
    category: "cruiser",
    price_cop: 52_000_000,
    engine_cc: 883,
    power_hp: 51,
    weight_kg: 247,
    fuel_efficiency: Decimal.new("20.0"),
    experience_level: "advanced",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Harley+Iron+883",
    description: "Cruiser icónica americana con carácter inconfundible.",
    tags: ["icónica", "estilosa", "premium"]
  },
  %{
    brand: "Kawasaki",
    model: "Vulcan S 650",
    year: 2024,
    category: "cruiser",
    price_cop: 22_000_000,
    engine_cc: 649,
    power_hp: 61,
    weight_kg: 228,
    fuel_efficiency: Decimal.new("24.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Kawasaki+Vulcan+S",
    description: "Cruiser moderna ergonómica, ajustable a diferentes riders.",
    tags: ["cómoda", "versátil", "tecnológica"]
  },

  # SCOOTER — urban/beginner
  %{
    brand: "Honda",
    model: "PCX 150",
    year: 2024,
    category: "scooter",
    price_cop: 8_200_000,
    engine_cc: 153,
    power_hp: 13,
    weight_kg: 130,
    fuel_efficiency: Decimal.new("50.0"),
    experience_level: "beginner",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=Honda+PCX+150",
    description: "Scooter urbana eficiente y práctica para el día a día.",
    tags: ["económica", "práctica", "ágil", "principiante"]
  },
  %{
    brand: "Yamaha",
    model: "NMAX 155",
    year: 2024,
    category: "scooter",
    price_cop: 10_500_000,
    engine_cc: 155,
    power_hp: 15,
    weight_kg: 127,
    fuel_efficiency: Decimal.new("48.0"),
    experience_level: "beginner",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=Yamaha+NMAX+155",
    description: "Scooter premium con tecnología y comodidad.",
    tags: ["económica", "tecnológica", "práctica", "principiante"]
  },
  %{
    brand: "Kymco",
    model: "AK 550",
    year: 2024,
    category: "scooter",
    price_cop: 19_000_000,
    engine_cc: 550,
    power_hp: 53,
    weight_kg: 218,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Kymco+AK+550",
    description: "Maxiscooter potente para ciudad y carretera.",
    tags: ["potente", "cómoda", "tecnológica"]
  },

  # TOURING
  %{
    brand: "BMW",
    model: "R 1250 RT",
    year: 2024,
    category: "touring",
    price_cop: 90_000_000,
    engine_cc: 1254,
    power_hp: 136,
    weight_kg: 279,
    fuel_efficiency: Decimal.new("18.0"),
    experience_level: "advanced",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=BMW+R1250RT",
    description: "Touring premium definitiva para viajes largos en máximo confort.",
    tags: ["premium", "cómoda", "tecnológica", "potente"]
  },
  %{
    brand: "Honda",
    model: "NT1100",
    year: 2024,
    category: "touring",
    price_cop: 42_000_000,
    engine_cc: 1084,
    power_hp: 102,
    weight_kg: 248,
    fuel_efficiency: Decimal.new("20.0"),
    experience_level: "advanced",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Honda+NT1100",
    description: "Touring polivalente con ADN deportivo.",
    tags: ["cómoda", "versátil", "tecnológica"]
  },

  # OFFROAD
  %{
    brand: "KTM",
    model: "300 EXC TPI",
    year: 2024,
    category: "offroad",
    price_cop: 35_000_000,
    engine_cc: 293,
    power_hp: 50,
    weight_kg: 103,
    fuel_efficiency: Decimal.new("20.0"),
    experience_level: "advanced",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=KTM+300+EXC",
    description: "Enduro pura de competición para terrenos extremos.",
    tags: ["potente", "offroad", "deportiva"]
  },
  %{
    brand: "Honda",
    model: "CRF250F",
    year: 2024,
    category: "offroad",
    price_cop: 12_000_000,
    engine_cc: 249,
    power_hp: 21,
    weight_kg: 120,
    fuel_efficiency: Decimal.new("35.0"),
    experience_level: "beginner",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=Honda+CRF250F",
    description: "Enduro ligera para iniciarse en el off-road.",
    tags: ["ligera", "offroad", "principiante"]
  },
  %{
    brand: "Yamaha",
    model: "WR450F",
    year: 2024,
    category: "offroad",
    price_cop: 28_000_000,
    engine_cc: 449,
    power_hp: 57,
    weight_kg: 117,
    fuel_efficiency: Decimal.new("22.0"),
    experience_level: "advanced",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=Yamaha+WR450F",
    description: "Enduro de alto rendimiento con tecnología de pista.",
    tags: ["potente", "offroad", "deportiva", "tecnológica"]
  },

  # More for coverage
  %{
    brand: "Benelli",
    model: "TNT 302R",
    year: 2024,
    category: "sport",
    price_cop: 13_500_000,
    engine_cc: 300,
    power_hp: 38,
    weight_kg: 172,
    fuel_efficiency: Decimal.new("31.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Benelli+TNT+302R",
    description: "Deportiva accesible de buen diseño y equipamiento.",
    tags: ["estilosa", "deportiva", "principiante"]
  },
  %{
    brand: "Suzuki",
    model: "V-Strom 650",
    year: 2024,
    category: "adventure",
    price_cop: 29_000_000,
    engine_cc: 645,
    power_hp: 71,
    weight_kg: 213,
    fuel_efficiency: Decimal.new("24.0"),
    experience_level: "intermediate",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Suzuki+VStrom+650",
    description: "Adventure confiable y versátil para rutas largas.",
    tags: ["versátil", "cómoda", "económica"]
  },
  %{
    brand: "Royal Enfield",
    model: "Meteor 350",
    year: 2024,
    category: "cruiser",
    price_cop: 11_500_000,
    engine_cc: 349,
    power_hp: 20,
    weight_kg: 191,
    fuel_efficiency: Decimal.new("35.0"),
    experience_level: "beginner",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=RE+Meteor+350",
    description: "Cruiser ligera retro, perfecta para el rider urbano.",
    tags: ["económica", "estilosa", "icónica", "principiante"]
  },

  # ── Catalog expansion — fills category × experience × use_case gaps ─────────

  # TOURING — beginner/intermediate/advanced, mixed/highway
  %{
    brand: "Suzuki",
    model: "V-Strom 250SX",
    year: 2024,
    category: "touring",
    price_cop: 14_500_000,
    engine_cc: 249,
    power_hp: 24,
    weight_kg: 166,
    fuel_efficiency: Decimal.new("35.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Suzuki+VStrom+250SX",
    description: "Touring liviana ideal para iniciarse en viajes largos.",
    tags: ["versátil", "cómoda", "principiante"]
  },
  %{
    brand: "Kawasaki",
    model: "Versys-X 300",
    year: 2024,
    category: "touring",
    price_cop: 16_000_000,
    engine_cc: 296,
    power_hp: 39,
    weight_kg: 179,
    fuel_efficiency: Decimal.new("33.0"),
    experience_level: "beginner",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Kawasaki+Versys-X+300",
    description: "Touring compacta y cómoda para rutas de carretera.",
    tags: ["cómoda", "versátil", "principiante"]
  },
  %{
    brand: "Yamaha",
    model: "Tracer 7",
    year: 2024,
    category: "touring",
    price_cop: 32_000_000,
    engine_cc: 689,
    power_hp: 73,
    weight_kg: 196,
    fuel_efficiency: Decimal.new("25.0"),
    experience_level: "intermediate",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Yamaha+Tracer+7",
    description: "Touring versátil con gran equilibrio entre ciudad y carretera.",
    tags: ["cómoda", "versátil", "tecnológica"]
  },
  %{
    brand: "Kawasaki",
    model: "Versys 650",
    year: 2024,
    category: "touring",
    price_cop: 34_000_000,
    engine_cc: 649,
    power_hp: 67,
    weight_kg: 216,
    fuel_efficiency: Decimal.new("23.0"),
    experience_level: "intermediate",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Kawasaki+Versys+650",
    description: "Touring intermedia pensada para devorar carretera con confort.",
    tags: ["cómoda", "versátil", "tecnológica"]
  },
  %{
    brand: "Triumph",
    model: "Tiger Sport 660",
    year: 2024,
    category: "touring",
    price_cop: 38_000_000,
    engine_cc: 660,
    power_hp: 81,
    weight_kg: 206,
    fuel_efficiency: Decimal.new("22.0"),
    experience_level: "advanced",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Triumph+Tiger+Sport+660",
    description: "Touring deportiva con potencia y confort para riders exigentes.",
    tags: ["potente", "cómoda", "tecnológica"]
  },

  # ADVENTURE — fill beginner/highway and advanced/mixed
  %{
    brand: "Royal Enfield",
    model: "Himalayan 411",
    year: 2024,
    category: "adventure",
    price_cop: 17_000_000,
    engine_cc: 411,
    power_hp: 24,
    weight_kg: 199,
    fuel_efficiency: Decimal.new("32.0"),
    experience_level: "beginner",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=RE+Himalayan+411",
    description: "Adventure accesible y confiable para rutas de carretera.",
    tags: ["versátil", "económica", "principiante"]
  },
  %{
    brand: "Ducati",
    model: "Multistrada V2",
    year: 2024,
    category: "adventure",
    price_cop: 65_000_000,
    engine_cc: 937,
    power_hp: 113,
    weight_kg: 215,
    fuel_efficiency: Decimal.new("19.0"),
    experience_level: "advanced",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Ducati+Multistrada+V2",
    description: "Adventure premium italiana para riders exigentes.",
    tags: ["premium", "potente", "tecnológica"]
  },

  # CRUISER — fill beginner/mixed, beginner/highway, advanced/mixed
  %{
    brand: "Honda",
    model: "Rebel 300",
    year: 2024,
    category: "cruiser",
    price_cop: 13_000_000,
    engine_cc: 286,
    power_hp: 27,
    weight_kg: 169,
    fuel_efficiency: Decimal.new("38.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Honda+Rebel+300",
    description: "Cruiser ligera y moderna, perfecta para empezar con estilo.",
    tags: ["ligera", "estilosa", "principiante"]
  },
  %{
    brand: "Kawasaki",
    model: "Eliminator 400",
    year: 2024,
    category: "cruiser",
    price_cop: 15_000_000,
    engine_cc: 451,
    power_hp: 45,
    weight_kg: 176,
    fuel_efficiency: Decimal.new("28.0"),
    experience_level: "beginner",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Kawasaki+Eliminator+400",
    description: "Cruiser moderna y cómoda para carretera.",
    tags: ["cómoda", "estilosa", "principiante"]
  },
  %{
    brand: "Indian",
    model: "Scout Bobber",
    year: 2024,
    category: "cruiser",
    price_cop: 58_000_000,
    engine_cc: 1133,
    power_hp: 78,
    weight_kg: 256,
    fuel_efficiency: Decimal.new("18.0"),
    experience_level: "advanced",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Indian+Scout+Bobber",
    description: "Cruiser icónica con carácter y presencia para riders avanzados.",
    tags: ["icónica", "premium", "potente"]
  },

  # Additional coverage — naked/scooter/offroad/adventure gaps
  %{
    brand: "Triumph",
    model: "Trident 660",
    year: 2024,
    category: "naked",
    price_cop: 35_000_000,
    engine_cc: 660,
    power_hp: 80,
    weight_kg: 188,
    fuel_efficiency: Decimal.new("24.0"),
    experience_level: "advanced",
    use_case: "highway",
    image_url: "https://placehold.co/600x400?text=Triumph+Trident+660",
    description: "Naked premium con motor de tres cilindros y carácter en carretera.",
    tags: ["potente", "tecnológica", "estilosa"]
  },
  %{
    brand: "Honda",
    model: "Forza 350",
    year: 2024,
    category: "scooter",
    price_cop: 17_000_000,
    engine_cc: 330,
    power_hp: 29,
    weight_kg: 181,
    fuel_efficiency: Decimal.new("32.0"),
    experience_level: "intermediate",
    use_case: "urban",
    image_url: "https://placehold.co/600x400?text=Honda+Forza+350",
    description: "Maxiscooter tecnológico y cómodo para el día a día.",
    tags: ["tecnológica", "cómoda", "práctica"]
  },
  %{
    brand: "Husqvarna",
    model: "FE 350",
    year: 2024,
    category: "offroad",
    price_cop: 30_000_000,
    engine_cc: 350,
    power_hp: 43,
    weight_kg: 110,
    fuel_efficiency: Decimal.new("21.0"),
    experience_level: "intermediate",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=Husqvarna+FE+350",
    description: "Enduro de competición con tecnología de punta.",
    tags: ["potente", "offroad", "tecnológica"]
  },
  %{
    brand: "Kawasaki",
    model: "KLX 300",
    year: 2024,
    category: "adventure",
    price_cop: 14_000_000,
    engine_cc: 292,
    power_hp: 27,
    weight_kg: 142,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "beginner",
    use_case: "offroad",
    image_url: "https://placehold.co/600x400?text=Kawasaki+KLX+300",
    description: "Adventure ligera ideal para iniciarse en el off-road.",
    tags: ["ligera", "offroad", "principiante"]
  },
  %{
    brand: "Yamaha",
    model: "MT-03",
    year: 2024,
    category: "naked",
    price_cop: 18_000_000,
    engine_cc: 321,
    power_hp: 42,
    weight_kg: 168,
    fuel_efficiency: Decimal.new("30.0"),
    experience_level: "beginner",
    use_case: "mixed",
    image_url: "https://placehold.co/600x400?text=Yamaha+MT-03",
    description: "Naked ágil y divertida para iniciarse con estilo deportivo.",
    tags: ["deportiva", "ágil", "principiante"]
  }
]

Enum.each(motorcycles, fn attrs ->
  Repo.insert!(%Motorcycle{
    brand: attrs.brand,
    model: attrs.model,
    year: attrs.year,
    category: attrs.category,
    price_cop: attrs.price_cop,
    engine_cc: attrs[:engine_cc],
    power_hp: attrs[:power_hp],
    weight_kg: attrs[:weight_kg],
    fuel_efficiency: attrs[:fuel_efficiency],
    experience_level: attrs.experience_level,
    use_case: attrs.use_case,
    image_url: attrs.image_url,
    description: attrs.description,
    tags: attrs.tags,
    inserted_at: now,
    updated_at: now
  })
end)

IO.puts("Inserted #{length(motorcycles)} motorcycles")

# ── Quiz Questions ────────────────────────────────────────────────────────────

questions = [
  %{
    key: "use_case",
    label: "¿Cómo usas principalmente tu moto?",
    type: "single_choice",
    options: %{
      items: [
        %{value: "urban", label: "Ciudad", icon: "🏙️", description: "Tráfico, calles, comisiones"},
        %{
          value: "highway",
          label: "Carretera",
          icon: "🛣️",
          description: "Rutas, autopistas, viajes largos"
        },
        %{value: "mixed", label: "Ciudad y carretera", icon: "🔄", description: "Un poco de todo"},
        %{value: "offroad", label: "Off-road", icon: "🏔️", description: "Tierra, trochas, montaña"}
      ]
    },
    order: 1
  },
  %{
    key: "budget",
    label: "¿Cuánto puedes invertir?",
    type: "single_choice",
    options: %{
      items: [
        %{
          value: "low",
          label: "Hasta $8 millones",
          icon: "💰",
          description: "Presupuesto ajustado"
        },
        %{value: "medium", label: "$8M – $20 millones", icon: "💵", description: "Rango medio"},
        %{
          value: "high",
          label: "Más de $20 millones",
          icon: "💎",
          description: "Sin límite de calidad"
        }
      ]
    },
    order: 2
  },
  %{
    key: "experience",
    label: "¿Cuánta experiencia tienes en moto?",
    type: "single_choice",
    options: %{
      items: [
        %{
          value: "beginner",
          label: "Principiante",
          icon: "🌱",
          description: "Poco o ningún tiempo en moto"
        },
        %{
          value: "intermediate",
          label: "Intermedio",
          icon: "⚡",
          description: "Algunos años de rodaje"
        },
        %{value: "advanced", label: "Avanzado", icon: "🏆", description: "Rider experimentado"}
      ]
    },
    order: 3
  },
  %{
    key: "priority",
    label: "¿Qué es lo más importante para ti?",
    type: "single_choice",
    options: %{
      items: [
        %{
          value: "economy",
          label: "Economía",
          icon: "⛽",
          description: "Bajo consumo, buen precio"
        },
        %{
          value: "power",
          label: "Potencia",
          icon: "🔥",
          description: "Motor fuerte, buena aceleración"
        },
        %{
          value: "comfort",
          label: "Comodidad",
          icon: "🛋️",
          description: "Ligera, fácil de maniobrar"
        },
        %{value: "tech", label: "Tecnología", icon: "📱", description: "Equipamiento moderno"}
      ]
    },
    order: 4
  },
  %{
    key: "category",
    label: "¿Qué estilo de moto te llama más la atención?",
    type: "single_choice",
    options: %{
      items: [
        %{value: "naked", label: "Naked", icon: "💪", description: "Estilo urbano, sin carenado"},
        %{value: "sport", label: "Sport", icon: "🏎️", description: "Carenada, posición deportiva"},
        %{
          value: "adventure",
          label: "Adventure",
          icon: "🧭",
          description: "Para cualquier terreno"
        },
        %{
          value: "cruiser",
          label: "Cruiser",
          icon: "🤘",
          description: "Estilo americano, relajada"
        },
        %{value: "scooter", label: "Scooter", icon: "🛵", description: "Práctica, automática"},
        %{value: "offroad", label: "Off-road", icon: "🏔️", description: "Enduro, cross"},
        %{
          value: "touring",
          label: "Touring",
          icon: "🗺️",
          description: "Viajes largos, máximo confort"
        }
      ]
    },
    order: 5
  }
]

Enum.each(questions, fn attrs ->
  Repo.insert!(%QuizQuestion{
    key: attrs.key,
    label: attrs.label,
    type: attrs.type,
    options: attrs.options,
    order: attrs.order,
    inserted_at: now,
    updated_at: now
  })
end)

IO.puts("Inserted #{length(questions)} quiz questions")
