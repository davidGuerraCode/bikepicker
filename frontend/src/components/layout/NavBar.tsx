import { Link, useLocation } from '@tanstack/react-router'
import { useAuth } from '../../hooks/useAuth'

export function NavBar() {
  const { pathname } = useLocation()
  const { user, logout } = useAuth()

  if (pathname === '/') return null

  return (
    <nav className="bg-panel border-b border-line px-6 py-4 flex items-center justify-between">
      <Link to="/" className="font-display font-bold uppercase text-lg text-paper tracking-wide">
        Bike<span className="text-signal">Picker</span>
      </Link>

      <div className="flex items-center gap-6 font-stat text-sm tracking-widest uppercase">
        <Link to="/quiz" className="text-dim hover:text-paper transition-colors" activeProps={{ className: 'text-signal' }}>
          Quiz
        </Link>
        <Link to="/garage" className="text-dim hover:text-paper transition-colors" activeProps={{ className: 'text-signal' }}>
          Garage
        </Link>

        {user ? (
          <div className="flex items-center gap-4">
            <span className="text-dim normal-case tracking-normal">{user.email}</span>
            <button onClick={() => logout()} className="cursor-pointer text-dim hover:text-paper transition-colors">
              Salir
            </button>
          </div>
        ) : (
          <Link to="/login" className="text-signal hover:text-paper transition-colors">
            Entrar
          </Link>
        )}
      </div>
    </nav>
  )
}
