import type { Recommendation } from '../../types'

interface Props {
  recommendation: Recommendation
  rank: number
}

const RANK_ACCENT: Record<number, string> = {
  1: 'border-signal text-signal',
  2: 'border-dim text-paper',
  3: 'border-line text-dim',
}

export function ResultCard({ recommendation, rank }: Props) {
  const { motorcycle: m, score, reasons } = recommendation
  const accent = RANK_ACCENT[rank] ?? 'border-line text-dim'

  return (
    <div className={`cut-corner bg-panel border overflow-hidden ${rank === 1 ? 'border-signal' : 'border-line'}`}>
      <div className="relative">
        <img
          src={m.image_url}
          alt={`${m.brand} ${m.model}`}
          className="w-full h-48 object-cover bg-panel-2"
        />

        <span className={`absolute top-0 left-0 font-stat font-bold text-sm px-3 py-1 bg-asphalt border-r border-b ${accent}`}>
          P{rank}
        </span>

        {/* Score gauge */}
        <div
          className="absolute top-3 right-3 w-16 h-16 rounded-full flex items-center justify-center"
          style={{ background: `conic-gradient(var(--color-signal) ${score * 3.6}deg, rgba(12,12,14,0.7) 0deg)` }}
        >
          <div className="w-12 h-12 rounded-full bg-asphalt flex items-center justify-center">
            <span className="font-stat font-bold text-sm text-paper">{score}%</span>
          </div>
        </div>
      </div>

      <div className="p-5">
        <h3 className="font-display uppercase text-xl font-semibold mb-1">
          {m.brand} {m.model}
        </h3>
        <p className="font-stat text-dim text-xs tracking-wide mb-3">
          {m.year} · {m.category.toUpperCase()} · {m.engine_cc}CC
        </p>

        <p className="text-paper/80 text-sm mb-4 leading-relaxed">{m.description}</p>

        {reasons.length > 0 && (
          <ul className="space-y-1 mb-4">
            {reasons.map(r => (
              <li key={r} className="text-sm text-signal flex items-center gap-2">
                <span className="font-stat">▸</span> {r}
              </li>
            ))}
          </ul>
        )}

        <div className="flex items-center justify-between pt-3 border-t border-line">
          <span className="font-stat font-bold text-lg">
            ${m.price_cop.toLocaleString('es-CO')}
          </span>
          <div className="flex gap-2">
            {m.tags.slice(0, 2).map(tag => (
              <span key={tag} className="text-xs font-stat text-dim border border-line px-2 py-1">
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
