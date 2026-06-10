import { useState } from 'react'
import { useQuery, useMutation } from '@tanstack/react-query'
import { api, queryKeys } from '../services/api'
import { store } from '../store'
import type { QuizAnswers, Recommendation } from '../types'

interface QuizState {
  currentIndex: number
  answers: QuizAnswers
  isComplete: boolean
  recommendations: Recommendation[] | null
}

export function useQuiz() {
  const [state, setState] = useState<QuizState>({
    currentIndex: 0,
    answers: {},
    isComplete: false,
    recommendations: null,
  })

  const questionsQuery = useQuery({
    queryKey: queryKeys.questions,
    queryFn: () => api.getQuestions().then(r => r.data),
  })

  const matchMutation = useMutation({
    mutationFn: (answers: QuizAnswers) =>
      api.matchQuiz(answers).then(r => r.recommendations),
    onSuccess: recommendations => {
      store.recommendations = recommendations
      setState(s => ({ ...s, recommendations }))
    },
  })

  const questions = questionsQuery.data ?? []
  const currentQuestion = questions[state.currentIndex] ?? null

  function answer(value: string) {
    if (!currentQuestion) return
    setState(s => ({
      ...s,
      answers: { ...s.answers, [currentQuestion.key]: value },
    }))
  }

  function goForward() {
    const nextIndex = state.currentIndex + 1
    if (nextIndex >= questions.length) {
      setState(s => ({ ...s, isComplete: true }))
      matchMutation.mutate(state.answers)
    } else {
      setState(s => ({ ...s, currentIndex: nextIndex }))
    }
  }

  function goBack() {
    setState(s => ({
      ...s,
      currentIndex: Math.max(0, s.currentIndex - 1),
      isComplete: false,
    }))
  }

  function reset() {
    setState({ currentIndex: 0, answers: {}, isComplete: false, recommendations: null })
  }

  const currentAnswer = currentQuestion ? (state.answers[currentQuestion.key] ?? null) : null

  return {
    questions,
    currentQuestion,
    currentIndex: state.currentIndex,
    totalQuestions: questions.length,
    answers: state.answers,
    currentAnswer,
    isComplete: state.isComplete,
    recommendations: state.recommendations,
    isLoading: questionsQuery.isLoading,
    isMatching: matchMutation.isPending,
    answer,
    goForward,
    goBack,
    reset,
  }
}
