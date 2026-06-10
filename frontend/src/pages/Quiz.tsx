import { useNavigate } from '@tanstack/react-router'
import { useEffect } from 'react'
import { useQuiz } from '../hooks/useQuiz'
import { OptionButton } from '../components/quiz/OptionButton'

export function Quiz() {
  const navigate = useNavigate()
  const {
    currentQuestion,
    currentIndex,
    totalQuestions,
    currentAnswer,
    isComplete,
    isLoading,
    isMatching,
    recommendations,
    answer,
    goForward,
    goBack,
  } = useQuiz()

  useEffect(() => {
    if (isComplete && recommendations) {
      navigate({ to: '/results' })
    }
  }, [isComplete, recommendations, navigate])

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <p className="text-gray-400 text-lg">Cargando preguntas…</p>
      </div>
    )
  }

  if (isMatching) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="text-5xl mb-4 animate-bounce">🏍️</div>
          <p className="text-gray-300 text-lg">Buscando tu moto ideal…</p>
        </div>
      </div>
    )
  }

  if (!currentQuestion) return null

  const progress = ((currentIndex) / totalQuestions) * 100

  return (
    <div className="min-h-screen bg-gray-900 flex items-center justify-center px-4">
      <div className="w-full max-w-lg">
        {/* Progress */}
        <div className="mb-8">
          <div className="flex justify-between text-sm text-gray-400 mb-2">
            <span>Pregunta {currentIndex + 1} de {totalQuestions}</span>
            <span>{Math.round(progress)}%</span>
          </div>
          <div className="h-1.5 bg-gray-700 rounded-full">
            <div
              className="h-full bg-orange-500 rounded-full transition-all duration-300"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Question */}
        <h2 className="text-2xl font-bold text-white mb-6">
          {currentQuestion.label}
        </h2>

        {/* Options */}
        <div className="flex flex-col gap-3 mb-8">
          {currentQuestion.options.items.map(opt => (
            <OptionButton
              key={opt.value}
              icon={opt.icon}
              label={opt.label}
              description={opt.description}
              selected={currentAnswer === opt.value}
              onClick={() => answer(opt.value)}
            />
          ))}
        </div>

        {/* Navigation */}
        <div className="flex gap-3">
          {currentIndex > 0 && (
            <button
              onClick={goBack}
              className="flex-1 py-3 rounded-xl border border-gray-700 text-gray-300 hover:border-gray-500 transition-colors"
            >
              ← Atrás
            </button>
          )}
          <button
            onClick={goForward}
            disabled={!currentAnswer}
            className="flex-1 py-3 rounded-xl bg-orange-500 hover:bg-orange-400 disabled:opacity-40 disabled:cursor-not-allowed text-white font-semibold transition-colors"
          >
            {currentIndex === totalQuestions - 1 ? 'Ver resultados' : 'Siguiente →'}
          </button>
        </div>
      </div>
    </div>
  )
}
