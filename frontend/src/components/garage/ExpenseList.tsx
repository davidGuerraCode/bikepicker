import type { Expense } from '../../types'
import { CATEGORY_LABELS, formatCop } from './categories'

export function ExpenseList({
  expenses,
  onEdit,
  onDelete,
}: {
  expenses: Expense[]
  onEdit: (expense: Expense) => void
  onDelete: (expense: Expense) => void
}) {
  if (!expenses.length) {
    return <p className="text-dim text-sm">Aún no hay gastos para esta moto.</p>
  }

  const total = expenses.reduce((sum, e) => sum + e.amount_cop, 0)

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-left font-stat text-sm">
        <thead>
          <tr className="text-dim text-xs uppercase tracking-widest border-b border-line">
            <th className="py-2 pr-4">Fecha</th>
            <th className="py-2 pr-4">Categoría</th>
            <th className="py-2 pr-4">Nota</th>
            <th className="py-2 pr-4 text-right">Costo</th>
            <th className="py-2" />
          </tr>
        </thead>
        <tbody>
          {expenses.map(e => (
            <tr key={e.id} className="border-b border-line/50">
              <td className="py-2 pr-4 text-dim">{e.spent_on}</td>
              <td className="py-2 pr-4 text-paper">{CATEGORY_LABELS[e.category]}</td>
              <td className="py-2 pr-4 text-dim">{e.description ?? '—'}</td>
              <td className="py-2 pr-4 text-right text-paper">{formatCop(e.amount_cop)}</td>
              <td className="py-2 text-right whitespace-nowrap">
                <button
                  onClick={() => onEdit(e)}
                  className="cursor-pointer text-dim hover:text-paper transition-colors text-xs uppercase tracking-wide mr-4"
                >
                  Editar
                </button>
                <button
                  onClick={() => onDelete(e)}
                  className="cursor-pointer text-dim hover:text-accent transition-colors text-xs uppercase tracking-wide"
                >
                  Eliminar
                </button>
              </td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr>
            <td colSpan={3} className="py-3 text-dim uppercase tracking-widest text-xs">
              Total
            </td>
            <td className="py-3 text-right text-signal font-semibold">{formatCop(total)}</td>
            <td />
          </tr>
        </tfoot>
      </table>
    </div>
  )
}
