# BikePicker

Motorcycle recommendation app for the Colombian market. Answer 5 questions and get your top 3 motorcycle matches with scores and reasons in Spanish.

**Stack:** Elixir/Phoenix API · React + TanStack Router/Query · Tailwind 4 · PostgreSQL

---

## Prerequisites

- Elixir 1.15+ / Erlang 26+
- Node.js 18+
- Docker (for PostgreSQL)

---

## Setup

### 1. Database

```bash
docker run -d --name bikepicker-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16-alpine
```

### 2. Backend

```bash
cd motorcycle_advisor
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
mix phx.server
```

API runs at `http://localhost:4000`

### 3. Frontend

```bash
cd frontend
npm install
npm run dev
```

App runs at `http://localhost:5173`

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/quiz/questions` | Returns 5 quiz questions |
| `POST` | `/api/quiz/match` | Submit answers → top 3 recommendations |
| `GET` | `/api/motorcycles` | Motorcycle catalog (supports `?page=1&per_page=20`) |
| `GET` | `/api/motorcycles/:id` | Motorcycle detail |

### POST /api/quiz/match

```json
// Request
{
  "answers": {
    "use_case": "urban",
    "budget": "medium",
    "experience": "beginner",
    "priority": "economy",
    "category": "naked"
  }
}

// Response
{
  "recommendations": [
    {
      "motorcycle": { "brand": "Honda", "model": "CB190R", ... },
      "score": 92,
      "reasons": ["Ideal para moverse en ciudad", "Perfecta para principiantes"]
    }
  ]
}
```

**Answer values:**
- `use_case`: `urban` `highway` `mixed` `offroad`
- `budget`: `low` (< 8M COP) · `medium` (8–20M COP) · `high` (> 20M COP)
- `experience`: `beginner` `intermediate` `advanced`
- `priority`: `economy` `power` `comfort` `style` `tech`
- `category`: `naked` `sport` `cruiser` `adventure` `scooter` `touring` `offroad`

---

## Scoring

`score = use_case×30% + budget×25% + experience×25% + priority×10% + category×10%`

Always returns top 3 — a low score means no perfect match exists, not an error.
