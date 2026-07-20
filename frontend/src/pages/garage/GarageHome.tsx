import { useState } from 'react'
import { Link } from '@tanstack/react-router'
import { RequireAuth } from '../../components/auth/RequireAuth'
import { BikeForm } from '../../components/garage/BikeForm'
import { SpendChart } from '../../components/garage/SpendChart'
import { formatCop } from '../../components/garage/categories'
import { ToastStack } from '../../components/ui/ToastStack'
import { useToastQueue } from '../../hooks/useToastQueue'
import { useBikes, useCreateBike, useGarageSummary } from '../../hooks/useGarage'

function GarageHomeContent() {
  const { data: bikes, isLoading } = useBikes()
  const { data: summary } = useGarageSummary()
  const createBike = useCreateBike()
  const [showForm, setShowForm] = useState(false)
  const [createBikeError, setCreateBikeError] = useState<string | null>(null)
  const { toasts, pushToast } = useToastQueue()

  function handleCreateBike(attrs: { nickname?: string; brand: string; model: string; year?: number }) {
    setCreateBikeError(null)
    createBike.mutate(attrs, {
      onSuccess: () => {
        setShowForm(false)
        pushToast({ id: `bike-added-${Date.now()}`, message: 'Moto agregada', durationMs: 3000 })
      },
      onError: err => setCreateBikeError(err instanceof Error ? err.message : 'No se pudo guardar la moto.'),
    })
  }

  return (
    <div className="min-h-screen bg-asphalt text-paper px-4 py-12">
      <div className="max-w-3xl mx-auto">
        <div className="mb-10 flex items-center justify-between">
          <div>
            <p className="font-stat text-signal text-sm tracking-[0.4em] mb-2">GARAGE</p>
            <h1 className="font-display uppercase text-4xl sm:text-5xl font-bold">Tus motos</h1>
            {!!summary?.total_cop && (
              <p className="font-stat text-dim text-sm mt-2">
                Gasto total: <span className="text-signal font-semibold">{formatCop(summary.total_cop)}</span>
              </p>
            )}
          </div>
          <button
            onClick={() => {
              setShowForm(s => !s)
              setCreateBikeError(null)
            }}
            className="cut-corner-sm px-6 py-3 bg-signal hover:bg-paper text-asphalt font-display font-semibold uppercase tracking-wide transition-colors cursor-pointer"
          >
            {showForm ? 'Cancelar' : '+ Agregar moto'}
          </button>
        </div>

        {showForm && (
          <div className="bg-panel border border-line p-6 mb-10 cut-corner">
            <BikeForm isSubmitting={createBike.isPending} error={createBikeError} onSubmit={handleCreateBike} />
          </div>
        )}

        {isLoading ? (
          <p className="text-dim mb-10">Cargando…</p>
        ) : !bikes?.length ? (
          <p className="text-dim mb-10">Todavía no has agregado ninguna moto.</p>
        ) : (
          <div className="grid sm:grid-cols-2 gap-4 mb-10">
            {bikes.map(bike => (
              <Link
                key={bike.id}
                to="/garage/bikes/$bikeId"
                params={{ bikeId: String(bike.id) }}
                className="cut-corner bg-panel border border-line p-6 hover:border-signal transition-colors"
              >
                <p className="font-display uppercase text-xl font-semibold">
                  {bike.nickname || `${bike.brand} ${bike.model}`}
                </p>
                <p className="text-dim text-sm">
                  {bike.brand} {bike.model} {bike.year ? `· ${bike.year}` : ''}
                </p>
              </Link>
            ))}
          </div>
        )}

        {summary && !showForm && (
          <div className="bg-panel border border-line p-6 cut-corner">
            <h2 className="font-stat text-dim text-xs tracking-widest uppercase mb-4">
              Resumen general
            </h2>
            <SpendChart summary={summary} />
          </div>
        )}
      </div>

      <ToastStack toasts={toasts} />
    </div>
  )
}

export function GarageHome() {
  return (
    <RequireAuth>
      <GarageHomeContent />
    </RequireAuth>
  )
}
