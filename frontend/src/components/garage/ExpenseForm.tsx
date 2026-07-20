import { useState } from 'react'
import type { Expense, ExpenseCategory } from '../../types'
import { CATEGORIES, CATEGORY_LABELS } from './categories'

interface ExpenseFormProps {
  initial?: Expense
  onSubmit: (attrs: {
    category: string
    amount_cop: number
    spent_on: string
    description?: string
  }) => void
  onCancel?: () => void
  isSubmitting?: boolean
}

const inputClass =
  'cut-corner-sm bg-panel border border-line text-paper px-4 py-3 focus:outline-none focus:border-signal'

export function ExpenseForm({ initial, onSubmit, onCancel, isSubmitting }: ExpenseFormProps) {
  const [category, setCategory] = useState<ExpenseCategory>(initial?.category ?? CATEGORIES[0])
  const [amount, setAmount] = useState(initial ? String(initial.amount_cop) : '')
  const [spentOn, setSpentOn] = useState(initial?.spent_on ?? new Date().toISOString().slice(0, 10))
  const [description, setDescription] = useState(initial?.description ?? '')

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    onSubmit({
      category,
      amount_cop: Number(amount),
      spent_on: spentOn,
      description: description || undefined,
    })
    if (!initial) {
      setAmount('')
      setDescription('')
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-3">
      <div className="grid sm:grid-cols-2 gap-3">
        <select
          value={category}
          onChange={e => setCategory(e.target.value as ExpenseCategory)}
          className={inputClass}
        >
          {CATEGORIES.map(c => (
            <option key={c} value={c}>
              {CATEGORY_LABELS[c]}
            </option>
          ))}
        </select>
        <input
          type="number"
          placeholder="Costo (COP)"
          value={amount}
          onChange={e => setAmount(e.target.value)}
          min={1}
          required
          className={inputClass}
        />
      </div>
      <input
        type="date"
        value={spentOn}
        onChange={e => setSpentOn(e.target.value)}
        required
        className={`${inputClass} w-full`}
      />
      <input
        placeholder="Nota (opcional)"
        value={description}
        onChange={e => setDescription(e.target.value)}
        className={inputClass}
      />
      <div className="flex gap-3">
        <button
          type="submit"
          disabled={isSubmitting}
          className="cut-corner-sm flex-1 py-3 bg-signal hover:bg-paper disabled:opacity-30 disabled:cursor-not-allowed text-asphalt font-display font-semibold uppercase tracking-wide transition-colors cursor-pointer"
        >
          {isSubmitting ? 'Guardando…' : initial ? 'Confirmar' : 'Agregar gasto'}
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
