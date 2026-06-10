import type { Recommendation } from '../../types'

interface Props {
  recommendation: Recommendation
  rank: number
}

const RANK_STYLES: Record<number, string> = {
  1: 'border-orange-500 shadow-orange-500/20',
  2: 'border-gray-500 shadow-gray-500/10',
  3: 'border-gray-600 shadow-gray-600/10',
}

const RANK_BADGE: Record<number, string> = {
  1: '🥇',
  2: '🥈',
  3: '🥉',
}

export function ResultCard({ recommendation, rank }: Props) {
  const { motorcycle: m, score, reasons } = recommendation

  return (
    <div className={`rounded-2xl border-2 shadow-xl overflow-hidden ${RANK_STYLES[rank] ?? 'border-gray-700'}`}>
      <div className="relative">
        <img
          src={m.image_url}
          alt={`${m.brand} ${m.model}`}
          className="w-full h-44 object-cover bg-gray-800"
        />
        <span className="absolute top-3 left-3 text-3xl">{RANK_BADGE[rank]}</span>
        <span className="absolute top-3 right-3 bg-gray-900/80 text-white text-sm font-bold px-3 py-1 rounded-full">
          {score}% match
        </span>
      </div>

      <div className="bg-gray-800 p-5">
        <h3 className="text-white text-xl font-bold mb-1">
          {m.brand} {m.model}
        </h3>
        <p className="text-gray-400 text-sm mb-3">{m.year} · {m.category} · {m.engine_cc}cc</p>

        <p className="text-gray-300 text-sm mb-4 leading-relaxed">{m.description}</p>

        {reasons.length > 0 && (
          <ul className="space-y-1 mb-4">
            {reasons.map(r => (
              <li key={r} className="text-sm text-orange-400 flex items-center gap-2">
                <span>✓</span> {r}
              </li>
            ))}
          </ul>
        )}

        <div className="flex items-center justify-between">
          <span className="text-white font-semibold text-lg">
            ${m.price_cop.toLocaleString('es-CO')}
          </span>
          <div className="flex gap-2">
            {m.tags.slice(0, 2).map(tag => (
              <span key={tag} className="text-xs bg-gray-700 text-gray-300 px-2 py-1 rounded-full">
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
