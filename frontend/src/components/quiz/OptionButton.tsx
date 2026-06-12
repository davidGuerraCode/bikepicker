interface Props {
  icon: string
  label: string
  description: string
  selected: boolean
  onClick: () => void
}

export function OptionButton({ icon, label, description, selected, onClick }: Props) {
  return (
    <button
      onClick={onClick}
      className={`w-full text-left px-5 py-4 flex items-start gap-4 border-l-4 transition-colors ${
        selected
          ? 'border-signal bg-panel-2'
          : 'border-line bg-panel hover:border-dim hover:bg-panel-2'
      }`}
    >
      <span className={`font-stat text-2xl shrink-0 ${selected ? 'text-signal' : 'text-dim'}`}>
        {icon}
      </span>
      <span>
        <span
          className={`font-display uppercase tracking-wide block ${
            selected ? 'text-paper' : 'text-paper/85'
          }`}
        >
          {label}
        </span>
        <span className="text-sm text-dim">{description}</span>
      </span>
    </button>
  )
}
