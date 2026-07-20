import { useEffect, useState } from 'react'

interface UndoToastProps {
  message: string
  durationMs: number
  onUndo: () => void
}

export function UndoToast({ message, durationMs, onUndo }: UndoToastProps) {
  const [shrink, setShrink] = useState(false)

  useEffect(() => {
    const raf = requestAnimationFrame(() => setShrink(true))
    return () => cancelAnimationFrame(raf)
  }, [])

  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-[calc(100%-2rem)] max-w-sm">
      <div className="cut-corner-sm bg-panel-2 border border-line overflow-hidden shadow-lg">
        <div className="flex items-center justify-between gap-4 px-4 py-3">
          <p className="text-paper text-sm">{message}</p>
          <button
            onClick={onUndo}
            className="cursor-pointer text-signal hover:text-paper font-display uppercase text-sm tracking-wide whitespace-nowrap transition-colors"
          >
            Deshacer
          </button>
        </div>
        <div className="h-[2px] bg-line">
          <div
            className="h-full bg-signal"
            style={{
              width: shrink ? '0%' : '100%',
              transition: shrink ? `width ${durationMs}ms linear` : 'none',
            }}
          />
        </div>
      </div>
    </div>
  )
}
