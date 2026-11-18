# Coding Standards

> **Customise this file for your company.** It is the rule-book reviewer-standards
> enforces and the developer follows. Keep the section headings; replace or extend the
> rules. Language-specific sections marked `<<...>>` should be completed per stack.

## 1. General Principles

- Readability over cleverness. Code is read far more often than it is written.
- Single Responsibility: a function does one thing; a module has one reason to change.
- Small units: functions ≤ 40 lines, files ≤ 400 lines, cyclomatic complexity ≤ 10 (justify exceptions inline).
- DRY, but prefer duplication over the wrong abstraction (rule of three).
- Fail fast and loudly at boundaries; never swallow exceptions silently.
- No magic numbers or strings — use named constants or configuration.

## 2. Naming

- Names reveal intent; avoid abbreviations except widely known ones (`id`, `url`, `http`).
- Booleans read as predicates: `isActive`, `hasAccess`, `shouldRetry`.
- Functions are verbs (`calculateTotal`), classes/types are nouns (`InvoiceRepository`).
- <<Casing conventions per language, e.g. camelCase for TS variables, PascalCase for types, snake_case for Python, kebab-case for file names>>

## 3. Structure & Architecture

- Follow the layering and source tree defined in `docs/04-architecture/architecture.md`.
- Dependencies point inward (domain must not import infrastructure/UI).
- No business logic in controllers/handlers or UI components.
- Cross-cutting concerns (logging, auth, validation) use the shared modules — do not re-implement.

## 4. Error Handling & Logging

- Use the project's error types; include actionable context, never sensitive data.
- Log at the right level: `error` (needs action), `warn` (degraded), `info` (business events), `debug` (diagnostics).
- Structured logs with correlation/request IDs. Never log secrets, tokens, passwords or PII.

## 5. Security (baseline — OWASP ASVS L1 minimum)

- Validate and sanitise all external input at the boundary; use allow-lists.
- Parameterised queries only; no string-built SQL/NoSQL/shell commands.
- Encode output for its context (HTML, URL, JS, SQL).
- AuthN/AuthZ checks on every protected operation; deny by default.
- Secrets come from the secrets manager / environment — never committed.
- Dependencies: no new library without architect approval (licence + vulnerability check).

## 6. Testing

- Test pyramid: many unit, fewer integration, few end-to-end.
- Tests are deterministic, isolated, and fast; no network calls in unit tests.
- Arrange–Act–Assert structure; one behaviour per test; descriptive names
  (`should_reject_expired_token_when_validating`).
- Test data via builders/factories; no real personal data.
- Coverage threshold on changed code: 80 %.

## 7. Performance

- Avoid N+1 queries; batch and paginate; index columns used in filters/joins.
- No unbounded loops/collections over external data; stream large payloads.
- Cache only with a defined invalidation strategy and TTL.
- Budgets: p95 API latency ≤ 300 ms for local reads and writes (diary, food search in the Personal and Public databases); external food search (USDA / Open Food Facts) ≤ 3 s; page LCP ≤ 2.5 s on 4G mobile; INP ≤ 200 ms; CLS ≤ 0.1; initial JS ≤ 200 KB gzipped per route; memory per instance ≤ 512 MB. Cold starts after the database has gone idle are excluded and tracked separately (target ≤ 3 s).

## 8. Documentation

- Public functions/classes have doc comments describing purpose, params, returns, errors.
- Comments explain *why*, not *what*.
- ADR for every significant or hard-to-reverse technical decision.

## 9. Version Control

- Branch: `feat/<story-id>-short-name`, `fix/<defect-id>-short-name`.
- Commits: Conventional Commits (`feat(auth): add token refresh [STORY-02.04]`).
- One logical change per commit; no generated artefacts or secrets committed.

## 10. Language-Specific Rules

### TypeScript

- `strict: true` plus `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` in tsconfig.
- No `any`; use `unknown` and narrow it. A rare `any` needs an `// eslint-disable-next-line` comment explaining why.
- No non-null assertions (`!`) and no `as` casts except on validated data; validate all external input (API bodies, form data, USDA / Open Food Facts / MFP data) with Zod at the boundary.
- Prefer `readonly` properties and `ReadonlyArray`; never mutate function arguments.
- Exhaustive `switch` on unions (meals, food sources, units) with a `never` check in the default case.
- Model fixed sets as string-literal unions or `as const` objects, not `enum`.
- Nutrition values are numbers in base units (grams, mg, kcal, ml); round only for display. Unit conversion and scaling live in one tested module (`lib/nutrition`).
- Name formatting goes through the shared `toTitleCase()` helper (UI-CAP-03); never format names inline.
- Named exports only (except Next.js page/layout files); no default-exported utilities.
- Errors: throw typed errors in `lib/`; route handlers convert them to JSON `{ error: { code, message } }` with the correct HTTP status. Never leak stack traces to the client.

### SQL (PostgreSQL via Prisma)

- All schema changes via Prisma Migrate (`prisma migrate dev` locally, `prisma migrate deploy` in CI/CD). Never edit the database by hand, and never edit a migration that has been merged.
- Naming: tables and columns `snake_case` (map Prisma models with `@@map` / `@map`); tables are singular (`food_log`, `personal_food`); indexes `idx_<table>_<columns>`; unique constraints `uq_<table>_<columns>`; foreign keys `fk_<table>_<ref>`.
- Use Prisma queries by default. Raw SQL only for trigram/full-text food search (`pg_trgm`), always through `Prisma.sql` tagged templates (parameterised, never string-built).
- No `SELECT *`; use explicit `select` in Prisma and explicit column lists in raw SQL.
- Every query that reads user data filters by `user_id` from the session (row-level authorisation, NFR-03); there's a test for each repository function proving another user's rows are not returned.
- Index every foreign key and every column used in search or date filters (e.g. `food_log(user_id, date)`).
- Store user IDs and emails as `citext`, or keep lowercased copies with a unique index (AUTH-10).
- Money-like precision isn't needed; store nutrients as `numeric(10,2)` and weights as grams.
- Seed scripts (admin user, activity METs, INDB, IFCT 2017, the 194 MFP foods) are idempotent and safe to re-run.

### Frontend (Next.js App Router + React + Tailwind + shadcn/ui)

- Server Components by default; add `"use client"` only for interactivity (forms, rings, calendar, water tracker).
- Data changes via Server Actions or route handlers, validated with Zod on the server. Never trust client-side validation alone.
- State: server data via React Query (TanStack Query) or Server Component props; local UI state via `useState`/`useReducer`. No global state library unless a clear need is agreed. URL holds shareable state (selected date, tab).
- Components: one per file, PascalCase names, in `components/<feature>/`; shared primitives come from shadcn/ui in `components/ui/`. Glass card, gradient button and source badge are reusable components, not repeated class strings.
- Styling: Tailwind only; design tokens (`#22c55e`, `#3b82f6`, glass blur, shadows, radius) are defined once in the Tailwind config / CSS variables. No inline hex colours in components.
- Animations with Framer Motion, wrapped so they turn off under `prefers-reduced-motion`.
- Accessibility: `eslint-plugin-jsx-a11y` (recommended rules as errors); every interactive element is keyboard-reachable with a visible focus ring; text contrast ≥ 4.5:1 on glass backgrounds; colour never the only signal (Remaining, source badges); Playwright runs `@axe-core/playwright` on key pages with zero serious or critical violations.
- Forms: React Hook Form + Zod resolver; errors shown inline and announced to screen readers.
- Images via `next/image`; fonts via `next/font`.
- All user-facing strings live in one resource file (NFR-10).

## 11. Tooling (must pass in CI)

- Formatter: Prettier (with `prettier-plugin-tailwindcss`); CI runs `prettier --check .`
- Linter: ESLint (`next/core-web-vitals`, `@typescript-eslint/strict-type-checked`, `jsx-a11y`, `import/order`); zero errors, any warning needs a justifying comment
- Type checker: `tsc --noEmit` in strict mode
- Tests: Vitest unit tests with ≥ 80% coverage on `lib/`; Playwright end-to-end tests for the key flows in section 14, including axe accessibility checks
- Security scan:
  - `npm audit --audit-level=high` (fails on high or critical)
  - GitHub Dependabot alerts and weekly update PRs
  - Semgrep (free community rules for TypeScript, React and Next.js)
  - Gitleaks secret scan on every push, so no keys or passwords are committed
- Pre-commit: Husky + lint-staged runs Prettier and ESLint on changed files
