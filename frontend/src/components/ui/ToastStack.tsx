import { useEffect, useState } from 'react'
import type { ToastItem } from '../../hooks/useToastQueue'

function ToastRow({ toast }: { toast: ToastItem }) {
  const [shrink, setShrink] = useState(false)

  useEffect(() => {
    const raf = requestAnimationFrame(() => setShrink(true))
    return () => cancelAnimationFrame(raf)
  }, [])

  return (
    <div className="cut-corner-sm bg-panel-2 border border-line overflow-hidden shadow-lg">
      <div className="flex items-center justify-between gap-4 px-4 py-3">
        <p className="text-paper text-sm">{toast.message}</p>
        {toast.action && (
          <button
            onClick={toast.action.onClick}
            className="cursor-pointer text-signal hover:text-paper font-display uppercase text-sm tracking-wide whitespace-nowrap transition-colors"
          >
            {toast.action.label}
          </button>
        )}
      </div>
      <div className="h-[2px] bg-line">
        <div
          className="h-full bg-signal"
          style={{
            width: shrink ? '0%' : '100%',
            transition: shrink ? `width ${toast.durationMs}ms linear` : 'none',
          }}
        />
      </div>
    </div>
  )
}

export function ToastStack({ toasts }: { toasts: ToastItem[] }) {
  if (!toasts.length) return null

  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-[calc(100%-2rem)] max-w-sm flex flex-col-reverse gap-3">
      {toasts.map(toast => (
        <ToastRow key={toast.id} toast={toast} />
      ))}
    </div>
  )
}
