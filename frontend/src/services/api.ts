import type {
  Motorcycle,
  QuizQuestion,
  QuizAnswers,
  Recommendation,
  AuthResponse,
  User,
  GarageBike,
  Expense,
  GarageSummary,
} from '../types'

const BASE = 'http://localhost:4000/api'

let authToken: string | null = null

export function setAuthToken(token: string | null) {
  authToken = token
}

function describeErrors(errors: unknown): string | null {
  if (!errors || typeof errors !== 'object') return null

  const parts = Object.entries(errors as Record<string, unknown>).map(([field, value]) => {
    const message = Array.isArray(value) ? value.join(', ') : String(value)
    return field === 'detail' ? message : `${field}: ${message}`
  })

  return parts.length ? parts.join(' · ') : null
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (authToken) headers['Authorization'] = `Bearer ${authToken}`

  const res = await fetch(`${BASE}${path}`, {
    ...init,
    headers: { ...headers, ...init?.headers },
  })

  if (!res.ok) {
    const body = await res.json().catch(() => null)
    const message = describeErrors(body?.errors) ?? `API error ${res.status}`
    throw new Error(message)
  }

  if (res.status === 204) return undefined as T
  return res.json()
}

export const queryKeys = {
  questions: ['quiz', 'questions'] as const,
  motorcycles: (params?: Record<string, string>) => ['motorcycles', params] as const,
  motorcycle: (id: number) => ['motorcycles', id] as const,
  me: ['auth', 'me'] as const,
  bikes: ['garage', 'bikes'] as const,
  bike: (id: number) => ['garage', 'bikes', id] as const,
  expenses: (bikeId: number) => ['garage', 'bikes', bikeId, 'expenses'] as const,
  bikeSummary: (bikeId: number) => ['garage', 'bikes', bikeId, 'summary'] as const,
  garageSummary: ['garage', 'summary'] as const,
}

export const api = {
  getQuestions: (): Promise<{ data: QuizQuestion[] }> =>
    request('/quiz/questions'),

  matchQuiz: (answers: QuizAnswers): Promise<{ recommendations: Recommendation[] }> =>
    request('/quiz/match', {
      method: 'POST',
      body: JSON.stringify({ answers }),
    }),

  getMotorcycles: (params?: Record<string, string>): Promise<{ data: Motorcycle[] }> => {
    const qs = params ? '?' + new URLSearchParams(params).toString() : ''
    return request(`/motorcycles${qs}`)
  },

  getMotorcycle: (id: number): Promise<{ data: Motorcycle }> =>
    request(`/motorcycles/${id}`),

  register: (email: string, password: string): Promise<AuthResponse> =>
    request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),

  login: (email: string, password: string): Promise<AuthResponse> =>
    request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),

  logout: (): Promise<void> => request('/auth/logout', { method: 'DELETE' }),

  me: (): Promise<{ data: User }> => request('/auth/me'),

  getBikes: (): Promise<{ data: GarageBike[] }> => request('/garage/bikes'),

  getBike: (id: number): Promise<{ data: GarageBike }> => request(`/garage/bikes/${id}`),

  createBike: (attrs: {
    nickname?: string
    brand: string
    model: string
    year?: number
  }): Promise<{ data: GarageBike }> =>
    request('/garage/bikes', { method: 'POST', body: JSON.stringify(attrs) }),

  updateBike: (
    id: number,
    attrs: Partial<{ nickname: string; brand: string; model: string; year: number }>,
  ): Promise<{ data: GarageBike }> =>
    request(`/garage/bikes/${id}`, { method: 'PATCH', body: JSON.stringify(attrs) }),

  deleteBike: (id: number): Promise<void> =>
    request(`/garage/bikes/${id}`, { method: 'DELETE' }),

  getExpenses: (bikeId: number): Promise<{ data: Expense[] }> =>
    request(`/garage/bikes/${bikeId}/expenses`),

  createExpense: (
    bikeId: number,
    attrs: { category: string; amount_cop: number; spent_on: string; description?: string },
  ): Promise<{ data: Expense }> =>
    request(`/garage/bikes/${bikeId}/expenses`, {
      method: 'POST',
      body: JSON.stringify(attrs),
    }),

  updateExpense: (
    id: number,
    attrs: Partial<{ category: string; amount_cop: number; spent_on: string; description: string }>,
  ): Promise<{ data: Expense }> =>
    request(`/garage/expenses/${id}`, { method: 'PATCH', body: JSON.stringify(attrs) }),

  deleteExpense: (id: number): Promise<void> =>
    request(`/garage/expenses/${id}`, { method: 'DELETE' }),

  getBikeSummary: (bikeId: number): Promise<{ data: GarageSummary }> =>
    request(`/garage/bikes/${bikeId}/summary`),

  getGarageSummary: (): Promise<{ data: GarageSummary }> => request('/garage/summary'),
}
