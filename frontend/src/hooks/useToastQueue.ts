import { useEffect, useRef, useState } from 'react'

export interface ToastItem {
  id: number | string
  message: string
  durationMs: number
  action?: { label: string; onClick: () => void }
}

export function useToastQueue() {
  const [toasts, setToasts] = useState<ToastItem[]>([])
  const timeouts = useRef(new Map<ToastItem['id'], ReturnType<typeof setTimeout>>())
  const onExpireMap = useRef(new Map<ToastItem['id'], () => void>())

  function dismissToast(id: ToastItem['id']) {
    const timeoutId = timeouts.current.get(id)
    if (timeoutId) clearTimeout(timeoutId)
    timeouts.current.delete(id)
    onExpireMap.current.delete(id)
    setToasts(prev => prev.filter(t => t.id !== id))
  }

  function pushToast(toast: ToastItem, onExpire?: () => void) {
    const previousTimeout = timeouts.current.get(toast.id)
    if (previousTimeout) clearTimeout(previousTimeout)

    if (onExpire) onExpireMap.current.set(toast.id, onExpire)
    else onExpireMap.current.delete(toast.id)

    setToasts(prev => [...prev.filter(t => t.id !== toast.id), toast])

    timeouts.current.set(
      toast.id,
      setTimeout(() => {
        onExpireMap.current.get(toast.id)?.()
        dismissToast(toast.id)
      }, toast.durationMs),
    )
  }

  useEffect(() => {
    const expireOnUnmount = onExpireMap.current
    // If the page unloads while toasts are still pending, honor whatever the
    // user already saw happen (e.g. a delete) rather than silently reverting it.
    return () => {
      expireOnUnmount.forEach(onExpire => onExpire())
    }
  }, [])

  return { toasts, pushToast, dismissToast }
}
