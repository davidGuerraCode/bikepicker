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
      className={`w-full text-left px-5 py-4 rounded-xl border-2 transition-all ${
        selected
          ? 'border-orange-500 bg-orange-500/10 text-white'
          : 'border-gray-700 bg-gray-800 text-gray-300 hover:border-gray-500 hover:bg-gray-750'
      }`}
    >
      <span className="text-2xl mr-3">{icon}</span>
      <span className="font-semibold">{label}</span>
      <p className="text-sm text-gray-400 mt-1 ml-9">{description}</p>
    </button>
  )
}
