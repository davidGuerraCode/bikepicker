import { Link } from '@tanstack/react-router'
import { ResultCard } from '../components/motorcycles/ResultCard'
import { store } from '../store'

export function Results() {
  const recommendations = store.recommendations

  if (!recommendations.length) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center px-4">
        <div className="text-center">
          <p className="text-gray-400 mb-6">No hay resultados. Haz el quiz primero.</p>
          <Link to="/quiz" className="text-orange-400 hover:text-orange-300 underline">
            Ir al quiz
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 px-4 py-12">
      <div className="max-w-2xl mx-auto">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-bold text-white mb-3">Tus motos ideales</h1>
          <p className="text-gray-400">Basado en tus respuestas, estas son las mejores opciones para ti.</p>
        </div>

        <div className="flex flex-col gap-6">
          {recommendations.map((rec, i) => (
            <ResultCard key={rec.motorcycle.id} recommendation={rec} rank={i + 1} />
          ))}
        </div>

        <div className="text-center mt-10">
          <Link
            to="/quiz"
            className="inline-block border border-gray-700 text-gray-300 hover:border-gray-500 px-8 py-3 rounded-xl transition-colors"
          >
            ← Volver a intentar
          </Link>
        </div>
      </div>
    </div>
  )
}
