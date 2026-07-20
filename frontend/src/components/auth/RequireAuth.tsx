import { useEffect, type ReactNode } from 'react'
import { useNavigate } from '@tanstack/react-router'
import { useAuth } from '../../hooks/useAuth'

export function RequireAuth({ children }: { children: ReactNode }) {
  const { user, isLoading } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    if (!isLoading && !user) {
      navigate({ to: '/login' })
    }
  }, [isLoading, user, navigate])

  if (isLoading || !user) {
    return (
      <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center">
        <p className="font-stat text-dim text-sm tracking-widest animate-pulse">CARGANDO…</p>
      </div>
    )
  }

  return <>{children}</>
}
