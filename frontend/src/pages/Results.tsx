import { Link } from '@tanstack/react-router'
import { ResultCard } from '../components/motorcycles/ResultCard'
import { store } from '../store'

export function Results() {
  const recommendations = store.recommendations

  if (!recommendations.length) {
    return (
      <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center px-4">
        <div className="text-center">
          <p className="text-dim mb-6">No hay resultados. Haz el quiz primero.</p>
          <Link to="/quiz" className="font-stat text-signal underline">
            Ir al quiz
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-asphalt text-paper px-4 py-12">
      <div className="max-w-2xl mx-auto">
        <div className="mb-10">
          <p className="font-stat text-signal text-sm tracking-[0.4em] mb-2">RESULTADOS</p>
          <h1 className="font-display uppercase text-4xl sm:text-5xl font-bold mb-3">
            Tus motos ideales
          </h1>
          <p className="text-dim">Basado en tus respuestas, estas son las mejores opciones para ti.</p>
        </div>

        <div className="flex flex-col gap-6">
          {recommendations.map((rec, i) => (
            <ResultCard key={rec.motorcycle.id} recommendation={rec} rank={i + 1} />
          ))}
        </div>

        <div className="text-center mt-10">
          <Link
            to="/quiz"
            className="cut-corner-sm inline-block border border-line text-dim hover:text-paper hover:border-dim px-8 py-3 font-display uppercase tracking-wide transition-colors"
          >
            ← Volver a intentar
          </Link>
        </div>
      </div>
    </div>
  )
}
