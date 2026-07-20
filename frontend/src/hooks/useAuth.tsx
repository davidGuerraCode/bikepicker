import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { api, setAuthToken } from '../services/api'
import type { User } from '../types'

const STORAGE_KEY = 'bikepicker_auth_token'

interface AuthContextValue {
  user: User | null
  isLoading: boolean
  login: (email: string, password: string) => Promise<void>
  register: (email: string, password: string) => Promise<void>
  logout: () => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(() => !!localStorage.getItem(STORAGE_KEY))

  useEffect(() => {
    const token = localStorage.getItem(STORAGE_KEY)
    if (!token) return

    setAuthToken(token)
    api
      .me()
      .then(res => setUser(res.data))
      .catch(() => {
        localStorage.removeItem(STORAGE_KEY)
        setAuthToken(null)
      })
      .finally(() => setIsLoading(false))
  }, [])

  function persistSession(token: string, user: User) {
    localStorage.setItem(STORAGE_KEY, token)
    setAuthToken(token)
    setUser(user)
  }

  async function login(email: string, password: string) {
    const res = await api.login(email, password)
    persistSession(res.token, res.data)
  }

  async function register(email: string, password: string) {
    const res = await api.register(email, password)
    persistSession(res.token, res.data)
  }

  async function logout() {
    await api.logout().catch(() => {})
    localStorage.removeItem(STORAGE_KEY)
    setAuthToken(null)
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ user, isLoading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider')
  return ctx
}
