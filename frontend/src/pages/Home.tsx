import { Link } from '@tanstack/react-router'

export function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center px-4">
      <div className="text-center max-w-xl">
        <div className="text-6xl mb-6">🏍️</div>
        <h1 className="text-5xl font-bold text-white mb-4 tracking-tight">
          BikePicker
        </h1>
        <p className="text-gray-400 text-lg mb-10 leading-relaxed">
          Encuentra tu moto ideal en 5 preguntas.
          <br />
          Te recomendamos las 3 mejores opciones para ti.
        </p>
        <Link
          to="/quiz"
          className="inline-block bg-orange-500 hover:bg-orange-400 text-white font-semibold text-lg px-10 py-4 rounded-2xl transition-colors"
        >
          Empezar quiz →
        </Link>
      </div>
    </div>
  )
}
