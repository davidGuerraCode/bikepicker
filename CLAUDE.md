# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

BikePicker is a motorcycle recommendation app. A React frontend (port 5173) sends quiz answers to a Phoenix JSON API (port 4000), which scores all motorcycles against the answers and returns the top 3 recommendations.

## Commands

### Backend (Elixir/Phoenix) — `motorcycle_advisor/`

```bash
mix setup           # Install deps + create/migrate DB
mix phx.server      # Start API at http://localhost:4000
iex -S mix phx.server  # Interactive shell + server
mix test            # Run all tests
mix test test/my_test.exs  # Run a single test file
mix test --failed   # Re-run only previously failed tests
mix precommit       # Compile (warnings-as-errors) + deps check + format + tests — run before finishing
mix ecto.reset      # Drop and recreate DB
mix run priv/repo/seeds.exs  # Seed 42 motorcycles + 5 quiz questions
mix catalog.load    # Load motorcycles from data/candidates.csv into DB
```

### Frontend (React/Vite) — `frontend/`

```bash
npm install         # Install dependencies
npm run dev         # Start Vite dev server at http://localhost:5173
npm run build       # Production build → dist/
npm run lint        # ESLint check
npm run preview     # Preview production build
```

## Architecture

### Data Flow

1. Frontend loads quiz questions via `GET /api/quiz/questions` (TanStack Query, cached)
2. User answers 5 questions → stored in `useState` in `useQuiz` hook
3. Submit calls `POST /api/quiz/match` with `{ answers: { use_case, budget, experience, priority, style } }`
4. Backend scores every motorcycle in the DB and returns top 3 `{ motorcycle, score, reasons }`
5. Results are placed in `src/store.ts` (a plain module-level object) for cross-route access
6. Router navigates to `/results`, which reads from the store

### Backend Layers

- **`catalog/`** — Motorcycle schema (41 fields, `tags` is a string array) and Ecto queries
- **`quiz/quiz.ex`** — Orchestrates matching: fetches motorcycles, calls matcher, sorts, slices top 3
- **`quiz/matcher.ex`** — Core scoring algorithm (270 lines). Five weighted criteria:
  - `use_case` (0.25): exact match
  - `budget` (0.20): price_cop range check (low <8M, medium 8–20M, high >20M COP)
  - `experience` (0.20): exact match on `experience_level`
  - `priority` (0.10): fuel_efficiency / horsepower / weight+category / tags depending on type
  - `category` (0.25): similarity matrix (e.g. touring↔adventure = 0.6, sport↔cruiser = 0.1)
  - Generates human-readable reason strings from the top 3 scoring criteria
- **`quiz/quiz_question.ex`** — Schema for the 5 seeded questions (JSONB options)
- **Controllers** — Thin; delegate entirely to context modules (`Quiz`, `Catalog`)

### Frontend Layers

- **`services/api.ts`** — All HTTP calls + TanStack Query key definitions
- **`hooks/useQuiz.ts`** — Combines `useState` (answers), `useQuery` (questions), `useMutation` (submit)
- **`store.ts`** — Plain object for passing recommendations from Quiz → Results route
- **`types/index.ts`** — Shared types: `Motorcycle`, `QuizQuestion`, `QuizAnswers`, `Recommendation`
- **`pages/`** — Three pages: `Home` (CTA), `Quiz` (carousel + progress bar), `Results` (top 3 cards)
- **`index.css`** — Tailwind 4 + custom theme (6 CSS vars: `--asphalt`, `--signal`, `--paper`, etc.; fonts: Oswald/JetBrains Mono/Work Sans; utilities: `.hazard-stripes`, `.cut-corner`)

### API Endpoints

```
POST /api/quiz/match          # { answers } → { recommendations: [{motorcycle, score, reasons}] }
GET  /api/quiz/questions      # → { data: [QuizQuestion] }
GET  /api/motorcycles         # → { data: [...] } (supports page, per_page, category, experience_level, use_case)
GET  /api/motorcycles/:id     # → { data: Motorcycle }
```

CORS is configured for `http://localhost:5173` only (see `endpoint.ex`).

### Database

PostgreSQL. Two tables:
- `motorcycles` — 42 seeded rows; indexed on `category`, `experience_level`, `use_case`
- `quiz_questions` — 5 seeded rows with JSONB `options` column

CSV import: edit `data/candidates.csv` (set `status` to `approved`), then run `mix catalog.load`. Duplicate detection is by `brand + model + year`.

## Elixir/Phoenix Conventions

- Use `mix precommit` after all changes; it enforces warnings-as-errors and formatting.
- Use `Req` for HTTP requests — never `:httpoison`, `:tesla`, or `:httpc`.
- Access changeset fields with `Ecto.Changeset.get_field/2`, never map access syntax on structs.
- Generate migrations with `mix ecto.gen.migration name_with_underscores` to get correct timestamps.
- In tests, use `start_supervised!/1` for processes and `Process.monitor/1` instead of `Process.sleep/1`.
- Never nest multiple modules in the same file.
- Elixir lists don't support `list[i]` — use `Enum.at/2` or pattern matching.
- Predicate functions end in `?`, not `is_` prefix (reserve `is_` for guards).
