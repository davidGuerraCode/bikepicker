# Admin Dashboard (Phoenix LiveView)

## Overview
Add an internal admin dashboard to the existing Phoenix API app using LiveView and Tailwind CSS v4. The dashboard allows the team to manage motorcycle catalog data and quiz questions without touching the database directly, test recommendation logic live, and import bikes from CSV. Protected by HTTP Basic Auth since it's internal-only.

## Scope
- Asset pipeline setup (Tailwind v4 + esbuild)
- LiveView infrastructure (Layouts, CoreComponents)
- HTTP Basic Auth protection for all `/admin` routes
- `active` boolean field on motorcycles (inactive bikes excluded from recommendations)
- Motorcycles CRUD + active toggle + image preview + CSV bulk import
- Quiz questions CRUD with options management
- Coverage gaps dashboard (category × experience_level matrix)
- Recommendation simulator (pick answers → see live results)

## Acceptance Criteria

1. [AC-1] `GET /admin` returns a 401 without valid Basic Auth credentials
2. [AC-2] `GET /admin` with credentials `admin:admin` (dev) renders the coverage gaps dashboard
3. [AC-3] The dashboard matrix shows motorcycle counts grouped by category × experience_level; cells with zero are visually highlighted
4. [AC-4] `GET /admin/motorcycles` lists all motorcycles including inactive ones
5. [AC-5] Creating a motorcycle via the form persists it to the DB and redirects to the index
6. [AC-6] Editing a motorcycle via the form updates the DB record
7. [AC-7] The motorcycle form renders a live image preview when `image_url` is entered
8. [AC-8] Deleting a motorcycle removes it from the DB
9. [AC-9] Toggling `active` on a motorcycle updates the field in DB; inactive bikes no longer appear in `GET /api/motorcycles` or match results
10. [AC-10] Uploading a valid CSV file shows a parsed preview table before import
11. [AC-11] Confirming CSV import inserts valid rows and skips duplicates (by brand+model+year)
12. [AC-12] `GET /admin/quiz` lists all quiz questions with option count
13. [AC-13] Creating a quiz question with options persists to DB and appears in `GET /api/quiz/questions`
14. [AC-14] Editing a quiz question (label, options) updates the DB record
15. [AC-15] Deleting a quiz question removes it from DB
16. [AC-16] The simulator updates recommendation results live as quiz answers are selected, without page reload
17. [AC-17] `mix precommit` passes with no warnings or test failures

## Out of Scope
- User account management or role-based permissions
- Audit log / change history
- Production deployment configuration for Basic Auth credentials (handled separately via runtime.exs env vars)
- Public-facing UI changes (React frontend is untouched)

## Open Questions
None.
