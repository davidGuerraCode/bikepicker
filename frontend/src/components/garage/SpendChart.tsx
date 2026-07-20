import {
  ResponsiveContainer,
  BarChart,
  Bar,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from 'recharts'
import type { GarageSummary } from '../../types'
import { CATEGORY_LABELS, formatCop } from './categories'

const SIGNAL = '#ffc700'
const LINE = '#2e2e32'
const DIM = '#8d8d93'

interface ChartTooltipProps {
  active?: boolean
  payload?: { value: number }[]
  label?: string
}

function ChartTooltip({ active, payload, label }: ChartTooltipProps) {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-panel-2 border border-line px-3 py-2 font-stat text-xs">
      <p className="text-dim mb-1">{label}</p>
      <p className="text-paper">{formatCop(payload[0].value)}</p>
    </div>
  )
}

export function SpendChart({ summary }: { summary: GarageSummary }) {
  const byMonth = summary.by_month.map(m => ({
    month: new Date(m.month).toLocaleDateString('es-CO', { month: 'short', year: '2-digit' }),
    total_cop: m.total_cop,
  }))

  const byCategory = Object.entries(summary.by_category).map(([category, total]) => ({
    category: CATEGORY_LABELS[category as keyof typeof CATEGORY_LABELS] ?? category,
    total_cop: total ?? 0,
  }))

  if (!summary.total_cop) {
    return <p className="text-dim text-sm">Aún no hay gastos registrados.</p>
  }

  return (
    <div className="grid sm:grid-cols-2 gap-8">
      <div>
        <p className="font-stat text-dim text-xs tracking-widest uppercase mb-3">Gasto por mes</p>
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={byMonth} margin={{ left: 0, right: 8, top: 8, bottom: 0 }}>
            <CartesianGrid stroke={LINE} vertical={false} />
            <XAxis dataKey="month" stroke={DIM} fontSize={11} tickLine={false} axisLine={{ stroke: LINE }} />
            <YAxis stroke={DIM} fontSize={11} tickLine={false} axisLine={false} width={0} />
            <Tooltip content={<ChartTooltip />} cursor={{ stroke: LINE }} />
            <Area
              type="monotone"
              dataKey="total_cop"
              stroke={SIGNAL}
              strokeWidth={2}
              fill={SIGNAL}
              fillOpacity={0.15}
              dot={{ r: 3, fill: SIGNAL, strokeWidth: 0 }}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      <div>
        <p className="font-stat text-dim text-xs tracking-widest uppercase mb-3">Gasto por categoría</p>
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={byCategory} margin={{ left: 0, right: 8, top: 8, bottom: 0 }}>
            <CartesianGrid stroke={LINE} vertical={false} />
            <XAxis dataKey="category" stroke={DIM} fontSize={10} tickLine={false} axisLine={{ stroke: LINE }} interval={0} angle={-20} textAnchor="end" height={50} />
            <YAxis stroke={DIM} fontSize={11} tickLine={false} axisLine={false} width={0} />
            <Tooltip content={<ChartTooltip />} cursor={{ fill: LINE, fillOpacity: 0.3 }} />
            <Bar dataKey="total_cop" fill={SIGNAL} radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
