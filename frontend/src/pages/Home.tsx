import { Link } from '@tanstack/react-router'

export function Home() {
  return (
    <div className="min-h-screen bg-asphalt text-paper relative overflow-hidden flex items-center justify-center px-6">
      {/* Diagonal hazard bands */}
      <div className="hazard-stripes absolute -left-1/4 top-[28%] h-3 w-[150%] -rotate-3 opacity-70" />
      <div className="hazard-stripes absolute -left-1/4 bottom-[22%] h-2 w-[150%] rotate-2 opacity-30" />

      <div className="relative z-10 max-w-2xl text-center">
        <p className="font-stat text-signal text-xs sm:text-sm tracking-[0.4em] mb-6">
          ASESOR DE MOTOCICLETAS · COLOMBIA
        </p>

        <h1 className="font-display font-bold uppercase text-7xl sm:text-8xl leading-[0.95] mb-6 tracking-tight">
          Bike
          <br />
          <span className="text-signal">Picker</span>
        </h1>

        <p className="text-dim text-lg mb-12 leading-relaxed max-w-md mx-auto">
          5 preguntas. 3 motos. La que es para ti — con razones, no adivinanzas.
        </p>

        <Link
          to="/quiz"
          className="cut-corner inline-block bg-signal text-asphalt font-display font-semibold uppercase tracking-widest text-lg px-12 py-4 hover:bg-paper transition-colors"
        >
          Empezar →
        </Link>
      </div>

      <p className="absolute bottom-6 left-0 right-0 text-center font-stat text-dim text-xs tracking-widest">
        01 · ENCUESTA — 02 · SCORE — 03 · RECOMENDACIÓN
      </p>
    </div>
  )
}
