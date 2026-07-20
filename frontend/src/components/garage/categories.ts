import type { ExpenseCategory } from '../../types'

export const CATEGORIES: ExpenseCategory[] = [
  'oil_change',
  'brake_pads',
  'chain',
  'tires',
  'insurance',
  'registration',
  'mod',
  'other',
]

export const CATEGORY_LABELS: Record<ExpenseCategory, string> = {
  oil_change: 'Aceite',
  brake_pads: 'Pastillas de freno',
  chain: 'Cadena',
  tires: 'Llantas',
  insurance: 'Seguro',
  registration: 'Matrícula',
  mod: 'Modificación',
  other: 'Otro',
}

export function formatCop(amount: number): string {
  return new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(amount)
}
