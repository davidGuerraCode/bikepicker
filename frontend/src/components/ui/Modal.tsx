import { useCallback, useEffect, useRef, type ReactNode } from 'react'

interface ModalProps {
  title: string
  onClose: () => void
  confirmClose?: boolean
  children: ReactNode
}

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'

export function Modal({ title, onClose, confirmClose, children }: ModalProps) {
  const panelRef = useRef<HTMLDivElement>(null)

  const requestClose = useCallback(() => {
    if (confirmClose && !window.confirm('¿Descartar los cambios sin guardar?')) return
    onClose()
  }, [confirmClose, onClose])

  useEffect(() => {
    const focusable = panelRef.current?.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)
    focusable?.[0]?.focus()
  }, [])

  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') {
        requestClose()
        return
      }

      const panel = panelRef.current
      if (e.key !== 'Tab' || !panel) return

      const focusableEls = panel.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)
      if (!focusableEls.length) return

      const first = focusableEls[0]
      const last = focusableEls[focusableEls.length - 1]

      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault()
        last.focus()
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault()
        first.focus()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [requestClose])

  return (
    <div
      className="fixed inset-0 z-50 bg-asphalt/80 flex items-center justify-center px-4"
      onClick={requestClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div
        ref={panelRef}
        className="cut-corner bg-panel border border-line w-full max-w-md p-6"
        onClick={e => e.stopPropagation()}
      >
        <p id="modal-title" className="font-stat text-dim text-xs tracking-widest uppercase mb-4">
          {title}
        </p>
        {children}
      </div>
    </div>
  )
}
