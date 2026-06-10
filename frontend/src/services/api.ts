import type { Motorcycle, QuizQuestion, QuizAnswers, Recommendation } from '../types'

const BASE = 'http://localhost:4000/api'

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...init,
  })
  if (!res.ok) throw new Error(`API error ${res.status}`)
  return res.json()
}

export const queryKeys = {
  questions: ['quiz', 'questions'] as const,
  motorcycles: (params?: Record<string, string>) => ['motorcycles', params] as const,
  motorcycle: (id: number) => ['motorcycles', id] as const,
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
}
