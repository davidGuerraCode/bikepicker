export interface Motorcycle {
  id: number
  brand: string
  model: string
  year: number
  category: string
  price_cop: number
  engine_cc: number
  power_hp: number | null
  weight_kg: number | null
  fuel_efficiency: string | null
  experience_level: 'beginner' | 'intermediate' | 'advanced'
  use_case: 'urban' | 'highway' | 'mixed' | 'offroad' | 'track'
  image_url: string
  description: string
  tags: string[]
  inserted_at: string
  updated_at: string
}

export interface QuizOption {
  value: string
  label: string
  icon: string
  description: string
}

export interface QuizQuestion {
  id: number
  key: string
  label: string
  type: 'single_choice'
  options: { items: QuizOption[] }
  order: number
}

export type QuizAnswers = Record<string, string>

export interface Recommendation {
  motorcycle: Motorcycle
  score: number
  reasons: string[]
}
