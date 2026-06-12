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
      <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center">
        <p className="font-stat text-dim text-sm tracking-widest animate-pulse">CARGANDO PREGUNTAS…</p>
      </div>
    )
  }

  if (isMatching) {
    return (
      <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center">
        <div className="text-center">
          <p className="font-display uppercase text-3xl font-semibold mb-3 text-signal">
            Calculando
          </p>
          <p className="font-stat text-dim text-sm tracking-widest animate-pulse">
            BUSCANDO TU MOTO IDEAL…
          </p>
        </div>
      </div>
    )
  }

  if (!currentQuestion) return null

  const progress = ((currentIndex) / totalQuestions) * 100

  return (
    <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-lg">
        {/* Progress */}
        <div className="mb-10">
          <div className="flex justify-between items-baseline mb-2">
            <span className="font-stat text-signal text-sm tracking-widest">
              {String(currentIndex + 1).padStart(2, '0')} / {String(totalQuestions).padStart(2, '0')}
            </span>
            <span className="font-stat text-dim text-xs">{Math.round(progress)}%</span>
          </div>
          <div className="h-2 bg-panel flex gap-1">
            {Array.from({ length: totalQuestions }).map((_, i) => (
              <div key={i} className={`flex-1 ${i <= currentIndex ? 'bg-signal' : 'bg-line'}`} />
            ))}
          </div>
        </div>

        {/* Question */}
        <h2 className="font-display uppercase text-3xl font-semibold mb-8 leading-tight">
          {currentQuestion.label}
        </h2>

        {/* Options */}
        <div className="flex flex-col gap-3 mb-10">
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
              className="cut-corner-sm flex-1 py-3 border border-line text-dim hover:text-paper hover:border-dim font-display uppercase tracking-wide transition-colors"
            >
              ← Atrás
            </button>
          )}
          <button
            onClick={goForward}
            disabled={!currentAnswer}
            className="cut-corner-sm flex-1 py-3 bg-signal hover:bg-paper disabled:opacity-30 disabled:cursor-not-allowed text-asphalt font-display font-semibold uppercase tracking-wide transition-colors"
          >
            {currentIndex === totalQuestions - 1 ? 'Ver resultados' : 'Siguiente →'}
          </button>
        </div>
      </div>
    </div>
  )
}
