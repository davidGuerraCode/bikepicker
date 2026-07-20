import { useState } from 'react'
import { Link } from '@tanstack/react-router'
import { RequireAuth } from '../../components/auth/RequireAuth'
import { BikeForm } from '../../components/garage/BikeForm'
import { SpendChart } from '../../components/garage/SpendChart'
import { useBikes, useCreateBike, useGarageSummary } from '../../hooks/useGarage'

function GarageHomeContent() {
  const { data: bikes, isLoading } = useBikes()
  const { data: summary } = useGarageSummary()
  const createBike = useCreateBike()
  const [showForm, setShowForm] = useState(false)

  return (
    <div className="min-h-screen bg-asphalt text-paper px-4 py-12">
      <div className="max-w-3xl mx-auto">
        <div className="mb-10 flex items-center justify-between">
          <div>
            <p className="font-stat text-signal text-sm tracking-[0.4em] mb-2">GARAGE</p>
            <h1 className="font-display uppercase text-4xl sm:text-5xl font-bold">Tus motos</h1>
          </div>
          <button
            onClick={() => setShowForm(s => !s)}
            className="cut-corner-sm px-6 py-3 bg-signal hover:bg-paper text-asphalt font-display font-semibold uppercase tracking-wide transition-colors cursor-pointer"
          >
            {showForm ? 'Cancelar' : '+ Agregar moto'}
          </button>
        </div>

        {showForm && (
          <div className="bg-panel border border-line p-6 mb-10 cut-corner">
            <BikeForm
              isSubmitting={createBike.isPending}
              onSubmit={attrs =>
                createBike.mutate(attrs, { onSuccess: () => setShowForm(false) })
              }
            />
          </div>
        )}

        {summary && (
          <div className="bg-panel border border-line p-6 mb-10 cut-corner">
            <p className="font-stat text-dim text-xs tracking-widest uppercase mb-4">
              Resumen general
            </p>
            <SpendChart summary={summary} />
          </div>
        )}

        {isLoading ? (
          <p className="text-dim">Cargando…</p>
        ) : !bikes?.length ? (
          <p className="text-dim">Todavía no has agregado ninguna moto.</p>
        ) : (
          <div className="grid sm:grid-cols-2 gap-4">
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
      </div>
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
