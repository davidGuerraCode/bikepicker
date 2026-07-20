import { useEffect, type ReactNode } from 'react'

interface ModalProps {
  title: string
  onClose: () => void
  children: ReactNode
}

export function Modal({ title, onClose, children }: ModalProps) {
  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose()
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [onClose])

  return (
    <div
      className="fixed inset-0 z-50 bg-asphalt/80 flex items-center justify-center px-4"
      onClick={onClose}
    >
      <div
        className="cut-corner bg-panel border border-line w-full max-w-md p-6"
        onClick={e => e.stopPropagation()}
      >
        <p className="font-stat text-dim text-xs tracking-widest uppercase mb-4">{title}</p>
        {children}
      </div>
    </div>
  )
}
