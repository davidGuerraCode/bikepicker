import { useState } from 'react'
import { Link } from '@tanstack/react-router'
import { garageBikeRoute } from '../../routeTree'
import { RequireAuth } from '../../components/auth/RequireAuth'
import { BikeForm } from '../../components/garage/BikeForm'
import { ExpenseForm } from '../../components/garage/ExpenseForm'
import { ExpenseList } from '../../components/garage/ExpenseList'
import { SpendChart } from '../../components/garage/SpendChart'
import { ToastStack } from '../../components/ui/ToastStack'
import { Modal } from '../../components/ui/Modal'
import { CATEGORY_LABELS, formatCop } from '../../components/garage/categories'
import { useToastQueue } from '../../hooks/useToastQueue'
import type { Expense } from '../../types'
import {
  useBike,
  useUpdateBike,
  useExpenses,
  useCreateExpense,
  useUpdateExpense,
  useDeleteExpense,
  useBikeSummary,
} from '../../hooks/useGarage'

const UNDO_DELETE_MS = 5000

function errorMessage(err: unknown, fallback: string) {
  return err instanceof Error ? err.message : fallback
}

function BikeDetailContent({ bikeId }: { bikeId: number }) {
  const { data: bike, isLoading } = useBike(bikeId)
  const { data: expenses } = useExpenses(bikeId)
  const { data: summary } = useBikeSummary(bikeId)
  const updateBike = useUpdateBike(bikeId)
  const createExpense = useCreateExpense(bikeId)
  const updateExpense = useUpdateExpense(bikeId)
  const { mutate: deleteExpense } = useDeleteExpense(bikeId)
  const { toasts, pushToast, dismissToast } = useToastQueue()

  const [editing, setEditing] = useState(false)
  const [editingExpense, setEditingExpense] = useState<Expense | null>(null)

  const [createFormDirty, setCreateFormDirty] = useState(false)
  const [editFormDirty, setEditFormDirty] = useState(false)
  const [bikeFormDirty, setBikeFormDirty] = useState(false)

  const [createExpenseError, setCreateExpenseError] = useState<string | null>(null)
  const [editExpenseError, setEditExpenseError] = useState<string | null>(null)
  const [bikeError, setBikeError] = useState<string | null>(null)

  function openEditModal(expense: Expense) {
    setEditFormDirty(false)
    setEditExpenseError(null)
    setEditingExpense(expense)
  }

  function requestDelete(expense: Expense) {
    pushToast(
      {
        id: expense.id,
        message: `Gasto eliminado: ${CATEGORY_LABELS[expense.category]} · ${formatCop(expense.amount_cop)}`,
        durationMs: UNDO_DELETE_MS,
        action: { label: 'Deshacer', onClick: () => dismissToast(expense.id) },
      },
      () => deleteExpense(expense.id),
    )
  }

  function handleCreateExpense(attrs: {
    category: string
    amount_cop: number
    spent_on: string
    description?: string
  }) {
    setCreateExpenseError(null)
    createExpense.mutate(attrs, {
      onSuccess: () => {
        setCreateFormDirty(false)
        pushToast({ id: `expense-added-${Date.now()}`, message: 'Gasto agregado', durationMs: 3000 })
      },
      onError: err => setCreateExpenseError(errorMessage(err, 'No se pudo agregar el gasto.')),
    })
  }

  function handleUpdateExpense(attrs: {
    category: string
    amount_cop: number
    spent_on: string
    description?: string
  }) {
    if (!editingExpense) return
    setEditExpenseError(null)
    updateExpense.mutate(
      { id: editingExpense.id, attrs },
      {
        onSuccess: () => setEditingExpense(null),
        onError: err => setEditExpenseError(errorMessage(err, 'No se pudo guardar el gasto.')),
      },
    )
  }

  function handleUpdateBike(attrs: { nickname?: string; brand: string; model: string; year?: number }) {
    setBikeError(null)
    updateBike.mutate(attrs, {
      onSuccess: () => {
        setEditing(false)
        setBikeFormDirty(false)
        pushToast({ id: `bike-updated-${Date.now()}`, message: 'Cambios guardados', durationMs: 3000 })
      },
      onError: err => setBikeError(errorMessage(err, 'No se pudo guardar la moto.')),
    })
  }

  function handleLeaveClick(e: React.MouseEvent) {
    if (!createFormDirty && !bikeFormDirty) return
    if (!window.confirm('¿Descartar los cambios sin guardar?')) {
      e.preventDefault()
    }
  }

  if (isLoading || !bike) {
    return (
      <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center">
        <p className="font-stat text-dim text-sm tracking-widest animate-pulse">CARGANDO…</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-asphalt text-paper px-4 py-12">
      <div className="max-w-3xl mx-auto">
        <Link
          to="/garage"
          onClick={handleLeaveClick}
          className="font-stat text-dim hover:text-paper text-sm tracking-widest mb-6 inline-block"
        >
          ← Volver al garage
        </Link>

        <div className="mb-8">
          {editing ? (
            <div className="bg-panel border border-line p-6 cut-corner">
              <BikeForm
                initial={bike}
                isSubmitting={updateBike.isPending}
                error={bikeError}
                onDirty={() => setBikeFormDirty(true)}
                onSubmit={handleUpdateBike}
                onCancel={() => {
                  setEditing(false)
                  setBikeFormDirty(false)
                  setBikeError(null)
                }}
              />
            </div>
          ) : (
            <div className="flex items-center justify-between">
              <div>
                <h1 className="font-display uppercase text-4xl font-bold">
                  {bike.nickname || `${bike.brand} ${bike.model}`}
                </h1>
                <p className="text-dim">
                  {bike.brand} {bike.model} {bike.year ? `· ${bike.year}` : ''}
                </p>
              </div>
              <button
                onClick={() => setEditing(true)}
                aria-label="Editar información de la moto"
                className="cut-corner-sm px-5 py-2 border border-line text-dim hover:text-paper hover:border-dim font-display uppercase text-sm tracking-wide transition-colors cursor-pointer"
              >
                Editar
              </button>
            </div>
          )}
        </div>

        {!editing && (
          <>
            <div className="bg-panel border border-line p-6 mb-8 cut-corner">
              <h2 className="font-stat text-dim text-xs tracking-widest uppercase mb-4">
                Registrar gasto
              </h2>
              <ExpenseForm
                isSubmitting={createExpense.isPending}
                error={createExpenseError}
                onDirty={() => setCreateFormDirty(true)}
                onSubmit={handleCreateExpense}
              />
            </div>

            <div className="bg-panel border border-line p-6 mb-8 cut-corner">
              <h2 className="font-stat text-dim text-xs tracking-widest uppercase mb-4">Historial</h2>
              <ExpenseList
                expenses={(expenses ?? []).filter(e => !toasts.some(t => t.id === e.id))}
                onEdit={openEditModal}
                onDelete={requestDelete}
              />
            </div>
          </>
        )}

        {summary && !editing && (
          <div className="bg-panel border border-line p-6 cut-corner">
            <h2 className="font-stat text-dim text-xs tracking-widest uppercase mb-4">Resumen</h2>
            <SpendChart summary={summary} />
          </div>
        )}
      </div>

      <ToastStack toasts={toasts} />

      {editingExpense && (
        <Modal
          title="Editar gasto"
          confirmClose={editFormDirty}
          onClose={() => setEditingExpense(null)}
        >
          <ExpenseForm
            initial={editingExpense}
            isSubmitting={updateExpense.isPending}
            error={editExpenseError}
            onDirty={() => setEditFormDirty(true)}
            onSubmit={handleUpdateExpense}
            onCancel={() => setEditingExpense(null)}
          />
        </Modal>
      )}
    </div>
  )
}

export function BikeDetail() {
  const { bikeId } = garageBikeRoute.useParams()

  return (
    <RequireAuth>
      <BikeDetailContent bikeId={Number(bikeId)} />
    </RequireAuth>
  )
}
