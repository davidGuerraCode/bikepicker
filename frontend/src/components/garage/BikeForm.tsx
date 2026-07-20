import { useState } from 'react'
import type { GarageBike } from '../../types'

interface BikeFormProps {
  initial?: GarageBike
  onSubmit: (attrs: { nickname?: string; brand: string; model: string; year?: number }) => void
  onCancel?: () => void
  isSubmitting?: boolean
}

const inputClass =
  'cut-corner-sm bg-panel border border-line text-paper px-4 py-3 focus:outline-none focus:border-signal'

export function BikeForm({ initial, onSubmit, onCancel, isSubmitting }: BikeFormProps) {
  const [nickname, setNickname] = useState(initial?.nickname ?? '')
  const [brand, setBrand] = useState(initial?.brand ?? '')
  const [model, setModel] = useState(initial?.model ?? '')
  const [year, setYear] = useState(initial?.year ? String(initial.year) : '')

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    onSubmit({
      nickname: nickname || undefined,
      brand,
      model,
      year: year ? Number(year) : undefined,
    })
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-3">
      <input
        placeholder="Apodo (opcional)"
        value={nickname}
        onChange={e => setNickname(e.target.value)}
        className={inputClass}
      />
      <div className="grid grid-cols-2 gap-3">
        <input
          placeholder="Marca"
          value={brand}
          onChange={e => setBrand(e.target.value)}
          required
          className={inputClass}
        />
        <input
          placeholder="Modelo"
          value={model}
          onChange={e => setModel(e.target.value)}
          required
          className={inputClass}
        />
      </div>
      <input
        type="number"
        placeholder="Año (opcional)"
        value={year}
        onChange={e => setYear(e.target.value)}
        className={inputClass}
      />

      <div className="flex gap-3">
        <button
          type="submit"
          disabled={isSubmitting}
          className="cut-corner-sm flex-1 py-3 bg-signal hover:bg-paper disabled:opacity-30 disabled:cursor-not-allowed text-asphalt font-display font-semibold uppercase tracking-wide transition-colors cursor-pointer"
        >
          {isSubmitting ? 'Guardando…' : 'Guardar'}
        </button>
        {onCancel && (
          <button
            type="button"
            onClick={onCancel}
            className="cut-corner-sm px-6 py-3 border border-line text-dim hover:text-paper hover:border-dim font-display uppercase tracking-wide transition-colors cursor-pointer"
          >
            Cancelar
          </button>
        )}
      </div>
    </form>
  )
}
