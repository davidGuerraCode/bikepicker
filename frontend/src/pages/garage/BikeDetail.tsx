import { useEffect, useRef, useState } from 'react'
import { Link } from '@tanstack/react-router'
import { garageBikeRoute } from '../../routeTree'
import { RequireAuth } from '../../components/auth/RequireAuth'
import { BikeForm } from '../../components/garage/BikeForm'
import { ExpenseForm } from '../../components/garage/ExpenseForm'
import { ExpenseList } from '../../components/garage/ExpenseList'
import { SpendChart } from '../../components/garage/SpendChart'
import { UndoToast } from '../../components/ui/UndoToast'
import { Modal } from '../../components/ui/Modal'
import { CATEGORY_LABELS, formatCop } from '../../components/garage/categories'
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

function BikeDetailContent({ bikeId }: { bikeId: number }) {
  const { data: bike, isLoading } = useBike(bikeId)
  const { data: expenses } = useExpenses(bikeId)
  const { data: summary } = useBikeSummary(bikeId)
  const updateBike = useUpdateBike(bikeId)
  const createExpense = useCreateExpense(bikeId)
  const updateExpense = useUpdateExpense(bikeId)
  const { mutate: deleteExpense } = useDeleteExpense(bikeId)
  const [editing, setEditing] = useState(false)
  const [editingExpense, setEditingExpense] = useState<Expense | null>(null)

  const [pendingDelete, setPendingDelete] = useState<Expense | null>(null)
  const pendingRef = useRef<Expense | null>(null)
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  function requestDelete(expense: Expense) {
    // A previous pending delete is still waiting — finalize it right away
    // before starting the new undo window, so only one row is ever "pending".
    if (pendingRef.current && timeoutRef.current) {
      clearTimeout(timeoutRef.current)
      deleteExpense(pendingRef.current.id)
    }

    pendingRef.current = expense
    setPendingDelete(expense)
    timeoutRef.current = setTimeout(() => {
      deleteExpense(expense.id)
      pendingRef.current = null
      setPendingDelete(null)
    }, UNDO_DELETE_MS)
  }

  function undoDelete() {
    if (timeoutRef.current) clearTimeout(timeoutRef.current)
    pendingRef.current = null
    setPendingDelete(null)
  }

  useEffect(() => {
    // If the page unloads mid-undo-window, honor the delete the user already
    // saw happen rather than silently reviving the row on next load.
    return () => {
      if (pendingRef.current) deleteExpense(pendingRef.current.id)
    }
  }, [deleteExpense])

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
        <Link to="/garage" className="font-stat text-dim hover:text-paper text-sm tracking-widest mb-6 inline-block">
          ← Volver al garage
        </Link>

        <div className="mb-8">
          {editing ? (
            <div className="bg-panel border border-line p-6 cut-corner">
              <BikeForm
                initial={bike}
                isSubmitting={updateBike.isPending}
                onSubmit={attrs => updateBike.mutate(attrs, { onSuccess: () => setEditing(false) })}
                onCancel={() => setEditing(false)}
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
                className="cut-corner-sm px-5 py-2 border border-line text-dim hover:text-paper hover:border-dim font-display uppercase text-sm tracking-wide transition-colors cursor-pointer"
              >
                Editar
              </button>
            </div>
          )}
        </div>

        {summary && (
          <div className="bg-panel border border-line p-6 mb-8 cut-corner">
            <SpendChart summary={summary} />
          </div>
        )}

        <div className="bg-panel border border-line p-6 mb-8 cut-corner">
          <p className="font-stat text-dim text-xs tracking-widest uppercase mb-4">
            Registrar gasto
          </p>
          <ExpenseForm isSubmitting={createExpense.isPending} onSubmit={attrs => createExpense.mutate(attrs)} />
        </div>

        <div className="bg-panel border border-line p-6 cut-corner">
          <p className="font-stat text-dim text-xs tracking-widest uppercase mb-4">Historial</p>
          <ExpenseList
            expenses={(expenses ?? []).filter(e => e.id !== pendingDelete?.id)}
            onEdit={setEditingExpense}
            onDelete={requestDelete}
          />
        </div>
      </div>

      {pendingDelete && (
        <UndoToast
          message={`Gasto eliminado: ${CATEGORY_LABELS[pendingDelete.category]} · ${formatCop(pendingDelete.amount_cop)}`}
          durationMs={UNDO_DELETE_MS}
          onUndo={undoDelete}
        />
      )}

      {editingExpense && (
        <Modal title="Editar gasto" onClose={() => setEditingExpense(null)}>
          <ExpenseForm
            initial={editingExpense}
            isSubmitting={updateExpense.isPending}
            onSubmit={attrs =>
              updateExpense.mutate(
                { id: editingExpense.id, attrs },
                { onSuccess: () => setEditingExpense(null) },
              )
            }
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
