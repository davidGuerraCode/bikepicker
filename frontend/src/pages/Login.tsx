import { useState } from 'react'
import { Link, useNavigate } from '@tanstack/react-router'
import { useAuth } from '../hooks/useAuth'

export function Login() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setIsSubmitting(true)
    try {
      await login(email, password)
      navigate({ to: '/garage' })
    } catch {
      setError('Correo o contraseña incorrectos.')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="min-h-screen bg-asphalt text-paper flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <p className="font-stat text-signal text-sm tracking-[0.4em] mb-2">ACCESO</p>
        <h1 className="font-display uppercase text-4xl font-bold mb-8">Entrar</h1>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <input
            type="email"
            placeholder="Correo electrónico"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            className="cut-corner-sm bg-panel border border-line text-paper px-4 py-3 focus:outline-none focus:border-signal"
          />
          <input
            type="password"
            placeholder="Contraseña"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
            className="cut-corner-sm bg-panel border border-line text-paper px-4 py-3 focus:outline-none focus:border-signal"
          />

          {error && <p className="text-accent text-sm">{error}</p>}

          <button
            type="submit"
            disabled={isSubmitting}
            className="cut-corner-sm mt-2 py-3 bg-signal hover:bg-paper disabled:opacity-30 text-asphalt font-display font-semibold uppercase tracking-wide transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Entrando…' : 'Entrar'}
          </button>
        </form>

        <p className="text-dim text-sm mt-6 text-center">
          ¿No tienes cuenta?{' '}
          <Link to="/signup" className="text-signal underline">
            Regístrate
          </Link>
        </p>
      </div>
    </div>
  )
}
