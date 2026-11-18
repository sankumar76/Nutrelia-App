# Nutrelia – Product Requirements Document

Version 1.0 (draft) · Last updated: 18 Nov 2026 · Owner: Santhosh

## 1. Overview

Nutrelia is a responsive web application that lets users log meals in free text, see calories and macronutrients against personalised targets, log exercise, and share their food diary with chosen friends. This document is the build specification for Claude Code.

| Item | Value |
| --- | --- |
| Product name | Nutrelia |
| Tagline | Understand your food. Nourish your future. |
| Document version | 1.0 (draft, requirements still being agreed) |
| Repository | Private GitHub repo `Nutrelia-App.git` (existing) |
| Primary market | India-first (Indian foods, INDB), usable globally |

### 1.1 Goals

1. Make food logging fast: type `Chapathi 2, Dal 1 cup` and get nutrition instantly.
2. Give every user sensible daily targets for calories, carbs, fat, protein and fiber, calculated from their profile and editable.
3. Build a clean, de-duplicated food database: a curated public database plus a personal database per user.
4. Track activity so the day shows calories eaten, burned and remaining.
5. Let friends view each other's diaries for accountability and inspiration.

### 1.2 Requirement conventions

- **MUST** = required for v1. **SHOULD** = expected in v1 unless time-boxed out. **COULD** = future.
- Requirement IDs (e.g. `AUTH-03`) are used for traceability in commits, PRs and tests.
- Items marked **\[Added\]** were not in the original brief; they are drawn from standard practice in comparable apps (MyFitnessPal, Cronometer, HealthifyMe, Lose It!). A full list is in section 15.

## 2. Scope, platform and roles

### 2.1 In scope (v1)

- Responsive web app (desktop, tablet, mobile browser), installable as a PWA **\[Added\]**.
- Accounts, health profile, auto-calculated and editable targets.
- Public and personal food databases, external lookup (INDB, IFCT 2017, Open Food Facts, USDA FoodData Central).
- MyFitnessPal printable-diary import.
- Free-text food logging for Breakfast, Lunch, Snacks, Dinner; copy from another date.
- Activity logging, friend sharing, admin console.

### 2.2 Out of scope (v1)

- Native iOS/Android apps, wearable sync (Google Fit, Apple Health, Fitbit), barcode scanning by camera, paid subscriptions, AI photo recognition. These are listed as COULD items in section 13.

### 2.3 Recommended technical stack

Claude Code should use this stack unless the owner overrides it (see open questions).

| Layer | Choice | Reason |
| --- | --- | --- |
| Framework | Next.js (App Router) + TypeScript | One codebase for UI and API routes |
| Styling | Tailwind CSS + shadcn/ui + Framer Motion | Fast glassmorphism theming and animation |
| Database | PostgreSQL via Prisma ORM | Relational data, full-text and trigram search (`pg_trgm`) for fuzzy food matching |
| Auth | Auth.js (credentials provider), Argon2id password hashing | Email + password with secure sessions |
| Email | Resend free tier or SMTP (configurable) | Verification and password-reset emails |
| File parsing | Layout-preserving PDF text extraction (`pdftotext -layout` or pdf.js with coordinates) | MyFitnessPal printable diary import (section 5.1) |
| Charts | Recharts | Dashboard and progress charts |
| Testing | Vitest (unit), Playwright (end-to-end) | Parser and flow coverage |
| Local dev | Docker Compose (app + Postgres) | One-command setup |
| Hosting (lowest cost) | Vercel free tier (app) + Neon Postgres free tier (database) | $0 to start; move to paid tiers only when usage needs it |

Hosting notes: Neon's free plan gives each project 0.5 GB storage and 100 CU-hours a month, and compute suspends after 5 minutes idle, so the first request after a quiet spell is slower ([Neon pricing](https://neon.com/pricing), [review, Sept 2026](https://www.jetadmin.io/blog/neon-pricing/amp/)). That is ample for the food database and early users. Confirm the Vercel free tier's usage terms before any commercial launch.

All food data is stored in Nutrelia's own database. External sources are called only during search, and any item a user selects is copied into their personal database.

### 2.4 User roles

| Role | Can do |
| --- | --- |
| Guest | View landing page, register, log in, reset password |
| User | Manage own profile, targets, personal foods, diary, activities, sharing |
| Friend (viewer) | Read-only view of diaries shared with them, react and comment **\[Added\]** |
| Admin | Everything a user can, plus manage the public food database, review user-submitted foods, view import logs, manage users |

The first admin is created by a seed script: user ID `admin`, email `sankumar76@yahoo.com`. The initial password comes from an environment variable (`ADMIN_INITIAL_PASSWORD`), is never committed to the repo, and must be changed at first login. Admins can promote other users.

Reserved user IDs (case-insensitive) that nobody else can register: `admin`, `administrator`, `root`, `support`, `nutrelia`, `help`, `system`. **\[Added\]**

## 3. Accounts, profile and targets

### 3.1 Registration and authentication (AUTH)

| ID | Priority | Requirement |
| --- | --- | --- |
| AUTH-01 | MUST | Users register with email and password, then complete a profile wizard (3.2). |
| AUTH-02 | MUST | Password rules: minimum 8 characters, at least one letter and one number; strength meter shown; checked against a common-password list. |
| AUTH-03 | MUST | Email verification link (valid 24 h) before the account can log food. **\[Added\]** |
| AUTH-04 | MUST | Forgot password: user enters email, receives a single-use reset link valid 30 minutes; response is identical whether or not the email exists. |
| AUTH-05 | MUST | Logged-in users can change password (current password required); all other sessions are signed out. |
| AUTH-06 | MUST | Login rate-limited: 5 failed attempts per 15 minutes per account and IP, then temporary lockout. **\[Added\]** |
| AUTH-07 | SHOULD | "Remember me" option (30-day session); default session 24 h. |
| AUTH-08 | COULD | Sign in with Google. |
| AUTH-09 | MUST | Users can export all their data (JSON/CSV) and delete their account permanently. **\[Added\]** (India DPDP Act 2023, GDPR) |

- AUTH-10 MUST: The user ID is **not case-sensitive** at registration, login and friend search. `SanKumar`, `sankumar` and `SANKUMAR` are the same ID: registration rejects an ID that differs from an existing one only by case, and login and lookups match regardless of case. The ID is displayed as the user typed it at signup. Store a lowercased copy (or use Postgres `citext`) with a unique index. Passwords remain case-sensitive.
- AUTH-11 MUST: Users can log in with either their user ID or their email (both case-insensitive) plus password.

### 3.2 Health profile (PROF)

Collected in a 4-step onboarding wizard with a progress bar; every field is editable later under Settings → Profile.

| Field | Required | Notes |
| --- | --- | --- |
| First name, last name | Yes | Stored and shown in Title Case (3.4) |
| Username | Yes | The user ID: unique and not case-sensitive (AUTH-10), chosen at signup, shown on the profile; friends find each other by it **\[Added\]** |
| Date of birth | Yes | Age is calculated, not typed; minimum age 18 (see PROF-04) |
| Sex (for calculation) | Yes | Male / Female; needed for BMR formula **\[Added\]** |
| Nationality / country | Yes | Picks the default nutrition guideline (3.3): India → ICMR-NIN, all others → General |
| Height | Yes | cm, or ft + in |
| Current weight | Yes | kg or lb; also starts the weight history |
| Goal weight | Yes | **\[Added\]** |
| Activity level | Yes | Sedentary, Lightly active, Moderately active, Very active, Extra active **\[Added\]** |
| Goal | Yes | Lose, Maintain, Gain; weekly rate 0.25 / 0.5 / 0.75 / 1 kg **\[Added\]** |
| Diet preference | No | Vegetarian, Eggetarian, Non-vegetarian, Vegan, Jain; used to rank search results **\[Added\]** |
| Allergies / intolerances | No | Free tags, e.g. Lactose, Gluten, Peanut **\[Added\]** |
| Health conditions | No | Diabetes, Hypertension, PCOS, Thyroid, Pregnancy, Breastfeeding; informational, triggers advice banner **\[Added\]** |
| Units, time zone | Yes | Metric default; time zone auto-detected **\[Added\]** |
| Profile photo | No | Shown to friends **\[Added\]** |

- PROF-01 MUST: Show calculated BMI with category on the profile page.
- PROF-02 MUST: Weight log with date; a progress chart of weight over time on the dashboard. **\[Added\]**
- PROF-03 MUST: Show a health disclaimer at signup: Nutrelia is not medical advice; users with health conditions or who are pregnant should consult a professional. **\[Added\]**

* PROF-04 MUST: Users must be 18 or older, matching MyFitnessPal's current policy. Registration checks date of birth; an under-18 date blocks sign-up with a polite message, and no account or data is stored. **\[Added\]**

### 3.3 Daily targets (TGT)

- TGT-01 MUST: Calculate default targets when onboarding finishes and show them for confirmation.
- TGT-02 MUST: Users can edit any target as grams or as % of calories (macros stay summing to 100%); a "Reset to recommended" button restores defaults.
- TGT-03 MUST: Recalculate suggested targets when weight, activity or goal changes; ask before overwriting custom targets.
- TGT-04 SHOULD: Also track sugar, saturated fat, sodium and cholesterol, with default limits. **\[Added\]**
- TGT-05 MUST: Daily water target (default 35 ml per kg body weight) with a quick-add water tracker. **\[Added\]**

Default calculation (Mifflin-St Jeor):

```
BMR = 10 × weight_kg + 6.25 × height_cm − 5 × age + s
  where s = +5 (male), −161 (female)
```

Each user has a **nutrition guideline** setting. It defaults from nationality (India → ICMR-NIN, everyone else → General) and can be switched in Settings, for example by an Indian living abroad.

| Target | ICMR-NIN (Indian users) | General (other countries) |
| --- | --- | --- |
| Calories (kcal) | BMR × activity factor, minus 550 kcal per 0.5 kg/week to lose, plus for gain; floor 1,200 (female) / 1,500 (male) | Same |
| Protein (g) | 1.0 g per kg body weight; never suggest above 1.6 g/kg | 1.2 g/kg (1.6 g/kg if goal is Lose or Gain) |
| Fat (g) | 25% of calories, capped at 30% | 27.5% of calories (range 20–35%) |
| Carbs (g) | Remaining calories ÷ 4 (expected 50–60%) | Remaining calories ÷ 4 (range 45–65%) |
| Fiber (g) | 30 g/day (range 25–40 g) | 14 g per 1,000 kcal, minimum 25 g |
| Added sugar | Under 5% of calories | Under 10% of calories (WHO) |
| Sodium | Under 2,000 mg (salt under 5 g) | Under 2,300 mg |

ICMR-NIN's 2024 Dietary Guidelines for Indians set total fat at or below 30% of energy and sugar below 5%, and note no extra muscle gain from protein above about 1.6 g/kg ([summary](https://thesouthfirst.com/news/icmr-releases-dietary-guidelines-for-indians-after-13-years-says-no-to-protein-supplements)). Claude Code must check the protein, carb and fiber defaults against the official ICMR-NIN RDA tables before release and keep them in the config file. ICMR-NIN also publishes Indian-specific BMR equations; Claude Code should evaluate using them for the ICMR-NIN guideline instead of Mifflin-St Jeor.

The formula constants live in one config file so a dietitian can tune them.

### 3.4 Name capitalisation (UI-CAP)

- UI-CAP-01 MUST: User first/last names and food names are displayed in Title Case, e.g. `chapathi` → `Chapathi`, `flax seeds` → `Flax Seeds`.
- UI-CAP-02 MUST: Keep common lowercase joiners lowercase mid-name (`and`, `of`, `with`, `in`), keep all-caps tokens like `USDA`, `MFP`, and handle apostrophes and hyphens (`Haldiram's`, `Rava-Upma` → `Rava-Upma`).
- UI-CAP-03 MUST: Normalise on save, so the database is consistent; one shared `toTitleCase()` utility with unit tests.

## 4. Food databases (FDB)

Nutrelia keeps two food tables: a curated **Public** database managed by admins, and a **Personal** database per user. External sources are search-only and never stored in bulk, except INDB (see FDB-08).

| ID | Priority | Requirement |
| --- | --- | --- |
| FDB-01 | MUST | Each food stores: name, brand (optional), category, diet tag (Veg/Egg/Non-veg/Vegan), one **base serving** (quantity + unit + gram weight), and nutrients per base serving. |
| FDB-02 | MUST | Nutrients stored: calories, carbs, fat, protein, fiber, sugar, saturated fat, sodium, cholesterol; SHOULD also store potassium, calcium, iron, vitamin C. |
| FDB-03 | MUST | Each food can have extra serving units with gram weights (e.g. Chapathi: 1 piece = 40 g; Rice: 1 cup = 158 g; Flax Seeds: 1 tbsp = 7 g) so any supported unit converts. |
| FDB-04 | MUST | Each food records its source (Admin, MFP import, INDB, Open Food Facts, USDA, User) and source ID, for traceability and de-duplication. |
| FDB-05 | MUST | **No duplicates in the public database.** A food is unique by normalised name + brand. Variants that differ only by quantity (`Flax Seeds 1 tbsp`, `Flax Seeds 2 tbsp`) are merged into one record with nutrients per base unit; any quantity is then calculated by scaling. |
| FDB-06 | MUST | Duplicate check runs on every insert, update and import; near-matches (trigram similarity ≥ 0.85) are shown to the admin as "possible duplicate" before saving. |
| FDB-07 | MUST | A seed script builds the initial public database from the owner's four MFP exports (194 distinct foods), de-duplicating as it goes, and writes a report of merges for admin review. |
| FDB-08 | MUST | Import the INDB dataset and IFCT 2017 (Indian Food Composition Tables, ICMR-NIN) into read-only reference tables at setup (neither has a live API; the owner has confirmed both may be used); Open Food Facts and USDA FoodData Central are queried live via their APIs. |
| FDB-09 | MUST | Users add, edit and delete foods in their personal database; admins do the same in the public database. |
| FDB-10 | SHOULD | Users can submit a personal food to the public database; it enters an admin review queue. **\[Added\]** |
| FDB-11 | SHOULD | Aliases per food for local spellings (Chapathi = Chapati = Roti = Phulka; Curd = Dahi). **\[Added\]** |
| FDB-12 | SHOULD | Recipes / custom meals: a user combines ingredients into one food with servings (e.g. Sambar, 4 servings). **\[Added\]** |

### 4.1 User-friendly food editor

One shared form, used by users (personal) and admins (public):

- Search-first: typing a name shows existing matches to avoid duplicates.
- Nutrition-label layout that mirrors a printed food label, with a live calorie check (4/4/9 kcal per g rule; warn if entered calories differ by more than 15%). **\[Added\]**
- "Copy from" button to start from an existing food.
- Admins also get CSV/Excel bulk upload with a template, preview, row-level validation errors and duplicate warnings before commit. **\[Added\]**

## 5. MyFitnessPal import (IMP)

| ID | Priority | Requirement |
| --- | --- | --- |
| IMP-01 | MUST | Accept the MyFitnessPal **Printable Diary** export (PDF, and the saved HTML page) via drag-and-drop upload. |
| IMP-02 | MUST | Import **foods only**: each food's name, serving and every nutrient column present (calories, carbs, fat, protein, cholesterol, sodium, sugar, fiber and any others). |
| IMP-03 | MUST | Ignore meal labels (Breakfast, Lunch, Dinner, Snacks), dates and daily totals for storage. Dates and totals are used only to validate the parse. No diary entries are created. |
| IMP-04 | MUST | Show a preview table before saving: foods found, parsed serving, nutrients, and flags (duplicate, unparsable serving, inconsistent per-unit values). |
| IMP-05 | MUST | Admin import → public database; user import → that user's personal database. Both apply de-duplication (FDB-05). |
| IMP-06 | MUST | Keep an import log (file name, who, when, foods added, merged, skipped, errors). |

### 5.1 Parser specification (from the owner's real exports)

The owner supplied four monthly exports (Oct 2025 – Jan 2026). A prototype parser using layout-preserving text extraction read them as follows; Claude Code must reproduce these numbers in its tests.

| Measure | Value |
| --- | --- |
| Files / days with entries | 4 / 120 |
| Food rows read | 2,581 |
| Distinct foods (to be imported) | 194 |
| Foods logged at more than one quantity | 69 (e.g. Egg White at 1–4 large; Tomato at 0.5, 1, 2 medium) |
| Rows with a `--` (not recorded) value | 291 |
| Food names wrapped onto a second line | 80 |
| Days whose rows sum to the TOTALS row (±1 kcal) | 119 of 120 |

Rules the parser MUST follow:

1. **Extract with layout preserved.** Plain text extraction puts all numbers in one block and all food names in another, so rows can only be matched by position. Layout mode keeps each food on the same line as its eight values.
2. **Ignore page furniture:** the print timestamp and site title header, the `English` line, and the footer URL with page number (e.g. `1/26`).
3. **Read the column order from the header row** (`FOODS Calories Carbs Fat Protein Cholest Sodium Sugar Fiber`); MyFitnessPal lets users choose columns, so never hard-code positions.
4. **Structure:** `Printable Diary for <username>` → a date line (`Jan 1, 2026`) → meal headings (Breakfast, Lunch, Dinner, Snacks; skipped) → food rows → a `TOTALS` row. Days with nothing logged are absent (e.g. Oct 7, Nov 4, Dec 2) and must not be created.
5. **Values:** strip `g` / `mg` units; `--` means not recorded and is stored as null, never 0.
6. **Wrapped names:** when a line has no values, join it to the next line that does (e.g. `Hemp Hearts - Hemp Hearts, Raw Shelled Hemp Seeds,` + `1 tbsp`).
7. **Food text format:** `[Brand - ]Food[, descriptor], <quantity> <unit>`. Split the serving off at the last comma followed by a number. Treat the brand as optional and drop a repeated brand (`Onion - Onion` → Onion).
8. **Messy servings to handle:** `gram(s)`, `gms`, `gm`, `Gram`; `1 Tb`; `4 oz (84g)` (prefer the grams in brackets); `1 medium (approx 2-3/4" long, 2-1/2" dia)`; `1 Small (500 gm)`; doubled quotes `""`; and `2.5 100 g`, which means 2.5 × 100 g.
9. **Validate every day** against its TOTALS row (±1 per column for rounding) and flag mismatches in the import preview. The prototype's one miss (Oct 4, 2025) is a TOTALS row split across a page break; the real parser must handle it.
10. **Derive per-unit nutrients carefully.** MyFitnessPal rounds each row to whole numbers, so scaling from a small portion magnifies rounding (1 Egg White = 17 kcal, but 3 large = 51). Use the largest logged quantity of each food as the base, keep other servings as extra units, and flag foods whose implied per-unit values differ by more than 10%.
11. **Same food, different unit names** (Avocado `0.5 avocado` vs `0.5 medium`) go to the review list for the admin or user to map.

The four exports are to be committed to the private repo as test fixtures (`tests/fixtures/mfp/`) with expected JSON output.

## 6. Food logging (LOG)

### 6.1 Diary page

- LOG-01 MUST: Diary shows one day with four meal cards: **Breakfast, Lunch, Snacks, Dinner**, each with its foods, quantities and a subtotal.
- LOG-02 MUST: A day summary shows totals vs targets for calories, carbs, fat, protein and fiber, as progress rings/bars, plus calories burned and remaining. **\[Added: remaining\]**
- LOG-03 MUST: Date navigation (previous / next / date picker / Today).
- LOG-04 MUST: Edit quantity, change meal, or delete any logged item inline.
- LOG-05 SHOULD: Quick-add from Recent, Frequent and Favourite foods per meal. **\[Added\]**
- LOG-06 SHOULD: Optional notes per day and a mark-day-complete button. **\[Added\]**

#### Calendar date picker (CAL)

- CAL-01 MUST: Tapping the date in the diary header (or a calendar icon beside it) opens a calendar picker, **defaulted to today's date**.
- CAL-02 MUST: The picker drills down in three steps: **Year → Month → Date**. Tapping the header label zooms out a level (Date view → Month view → Year view); picking a year shows its 12 months, picking a month shows its days, picking a day opens that diary immediately.
- CAL-03 MUST: The year list runs from the user's earliest logged date (or signup year) to the current year. Future dates can be opened for planning meals but are shown in a lighter style.
- CAL-04 MUST: Days with food logged show a small dot; today is outlined; the selected day is filled with the green–blue gradient. In Month and Year views, months/years containing logs are marked too.
- CAL-05 MUST: A **Today** button jumps back to the current date from any level. Previous/next day arrows stay beside the date for one-step moves.
- CAL-06 MUST: Works by keyboard (arrow keys move, Enter selects, Esc closes) and opens as a bottom sheet on mobile.
- CAL-07 SHOULD: The same picker is used for Copy from date (LOG-14), the Activity tab and viewing a friend's diary.

#### Data source label (LOG-SRC)

LOG-SRC-01 MUST: Every food item in the diary shows a small badge naming where its calories and nutrition values came from. Hovering or tapping the badge shows the full source name and, for external sources, the source's record ID.

| Badge | Meaning |
| --- | --- |
| Nutrelia | Added directly to the public database by an admin |
| Personal | Created by the user in their personal database |
| MyFitnessPal | Imported from a MyFitnessPal printable diary (including the 194 foods seeded into the public database) |
| INDB | Indian Nutrient Databank |
| IFCT 2017 | Indian Food Composition Tables 2017 (ICMR-NIN) |
| Open Food Facts | Open Food Facts product database |
| USDA | USDA FoodData Central |

- LOG-SRC-02 MUST: When a food was copied from one source into a database, the badge shows the path as **origin → database**:

  | Case | Badge |
  | --- | --- |
  | USDA food copied to a user's personal database | `USDA → Personal` |
  | INDB, IFCT 2017 or Open Food Facts food copied to personal | `INDB → Personal`, `IFCT 2017 → Personal`, `Open Food Facts → Personal` |
  | User's own MFP import | `MyFitnessPal → Personal` |
  | Foods seeded into the public database from the owner's MFP exports | `MyFitnessPal → Nutrelia` |
  | Food created by the user from scratch | `Personal` |
  | Food added by an admin from scratch | `Nutrelia` |
- LOG-SRC-03 MUST: If a user or admin edits the nutrition values, the badge adds an "Edited" marker (e.g. `USDA → Personal · Edited`), and the tooltip shows who edited it and when.
- LOG-SRC-04 MUST: The source path is saved with each diary entry's nutrient snapshot, so past days keep their label even if the food is later changed.
- LOG-SRC-05 SHOULD: Each origin has its own badge colour, with the name always in text so colour is never the only cue (WCAG). On narrow mobile screens the badge may shorten to the origin plus an arrow icon (e.g. `USDA ↗`), with the full path in the tooltip. The same badges appear in the matching picker (LOG-09), the food editor and the My Foods list.

#### Diary layout (LOG-UI)

The diary follows the familiar MyFitnessPal table (meal sections, nutrient columns, Totals / Goal / Remaining) and improves on it with clearer progress, exercise and water in the same view, and a mobile-first layout.

**Meal sections (desktop and tablet)**

- LOG-UI-01 MUST: Each meal (Breakfast, Lunch, Snacks, Dinner) is a glass card with a table: Food (name, serving, source badge) and one column per nutrient. Default columns: Calories (kcal), Carbs (g), Fat (g), Protein (g), Fiber (g), Sugar (g). Units sit under each column header.
- LOG-UI-02 MUST: Users choose which nutrient columns to show (up to 6, from all tracked nutrients including Sodium, Cholesterol, Saturated Fat) in Settings → Diary.
- LOG-UI-03 MUST: Each meal card ends with a subtotal row and two actions: **Add food** (opens the free-text box) and **Quick tools** (copy yesterday, copy from date, save as meal, clear meal).
- LOG-UI-04 MUST: Each row has edit (tap the row: change quantity or meal inline) and delete (icon). Delete shows an Undo toast for 5 seconds instead of a confirm dialog.
- LOG-UI-05 MUST: Numbers are right-aligned with tabular figures, rounded to whole numbers in the table; the row's detail view shows one decimal place.
- LOG-UI-06 SHOULD: Empty meals collapse to a single line with "Add food". Column headers stay visible (sticky) while scrolling a long day.

**Day summary**

- LOG-UI-07 MUST: Below the meals, a summary card shows four rows for every visible column: **Totals**, **Daily Goal**, **Exercise** (calories burned, calories column only), **Remaining**. Calories remaining = Goal + Exercise − Food.
- LOG-UI-08 MUST: Remaining is green when under goal, amber within 10% over, red beyond 10% over. Colour is always paired with a sign or label (e.g. "−120 over") for accessibility.
- LOG-UI-09 MUST: A progress ring (calories) and progress bars (each macro and fiber) show eaten vs goal and animate on load.
- LOG-UI-10 MUST: A macro split donut shows Carbs / Fat / Protein as % of calories, labelled with percentages, alongside the target split (e.g. "Carbs 58% · goal 55%"). This replaces MyFitnessPal's unlabelled pie.
- LOG-UI-11 SHOULD: "View all nutrients" opens a panel with every tracked nutrient vs goal (sodium, cholesterol, saturated fat, sugar, micronutrients where data exists); nutrients with missing data on some foods are marked "incomplete".
- LOG-UI-12 MUST: The water tracker card (6.5) sits beside the summary.

**Mobile (under 768 px)**

- LOG-UI-13 MUST: Tables become stacked rows: food name, serving and badge on the first line; calories on the right; macros as small chips (C 56 · F 1 · P 5) below. Tap a row to expand all nutrients and edit.
- LOG-UI-14 MUST: The day summary pins as a compact bar at the top (calories remaining + mini macro bars) and expands on tap.

### 6.2 Free-text entry and parsing

LOG-07 MUST: Each meal card has a text box. Items are separated by **comma or new line**. The parser accepts all of these:

| Input | Parsed as |
| --- | --- |
| `Chapathi 2` | Chapathi × 2 (default unit) |
| `Chapathi-2` | Chapathi × 2 |
| `2 Chapathi` | Chapathi × 2 |
| `Flax seeds 10tbsp` | Flax Seeds, 10 tbsp |
| `Rice 1.5 cup` | Rice, 1.5 cup |
| `Milk 200ml` | Milk, 200 ml |
| `Idli` | Idli × 1 (no quantity = 1 base serving) |
| `Dosa ½` | Dosa × 0.5 (fractions and ½ ¼ ¾ supported) |

Supported units: piece/no., g, kg, ml, l, tsp, tbsp, cup, bowl, katori, glass, slice, oz, lb, serving. Unit conversion uses FDB-03; if a unit isn't defined for a food, ask the user for the gram weight once and save it.

### 6.3 Matching order

LOG-08 MUST: For each parsed item, search in this order and stop at the first tier with results:

1. User's **personal** database (name + aliases, fuzzy match).
2. App **public** database.
3. Reference and external sources together: **INDB**, **IFCT 2017**, **Open Food Facts**, **USDA FoodData Central**, results grouped by source with a source badge.

- LOG-09 MUST: If exactly one confident match is found, log it directly. If **multiple matches** are found in a tier, show a picker with name, brand, source, serving and calories, and ask the user to choose. The picker remembers the choice so the same text auto-matches next time. **\[Added: remember choice\]**
- LOG-10 MUST: A food chosen from an external source is copied into the user's personal database, then logged.
- LOG-11 MUST: If nothing matches anywhere, offer "Create custom food" pre-filled with the typed name.
- LOG-12 MUST: Nutrition for any quantity = nutrients per base serving × (entered quantity in grams ÷ base serving grams). Example: Flax Seeds base 1 tbsp (7 g) = 37 kcal → 10 tbsp = 370 kcal.
- LOG-13 MUST: Before saving, show a review list of all parsed items with their matches and nutrition; user confirms with one click.

### 6.4 Copy from another date

- LOG-14 MUST: "Copy from date" lets the user pick a source date, then choose the whole day or selected meals, and a target meal mapping (e.g. yesterday's Lunch → today's Dinner).
- LOG-15 SHOULD: Shortcut "Copy yesterday" on each meal card. **\[Added\]**
- LOG-16 SHOULD: Copy a meal from a friend's shared diary into your own. **\[Added\]**

### 6.5 Water tracking (WAT)

- WAT-01 MUST: The diary shows a water card for each day with amount drunk vs the daily water target (TGT-05), as a filling glass/progress animation.
- WAT-02 MUST: Quick-add buttons for a glass (250 ml), bottle (500 ml) and a custom amount; a minus button removes the last entry. Container sizes are editable in Settings.
- WAT-03 MUST: Units follow the user's preference: ml / litres, or fl oz.
- WAT-04 MUST: Each addition is stored with its time, so the day shows a small timeline; entries can be edited or deleted.
- WAT-05 SHOULD: Weekly and monthly water history chart on the Progress page; a streak count for days the target was met.
- WAT-06 SHOULD: Water is included in "Copy from date" only if the user ticks it, and can be shared with friends via the share extras (SHR-05).
- WAT-07 COULD: Optional reminder notifications (e.g. every 2 hours, 8 am–8 pm).

## 7. Activities (ACT)

A separate **Activity** tab, modelled on MyFitnessPal and Cronometer.

| Category | Examples | Fields captured |
| --- | --- | --- |
| Cardio / Aerobic | Walking, Brisk walking, Jogging, Running, Cycling, Swimming, Skipping, Elliptical, Stair climbing, Dance, Zumba | Duration, distance (optional), intensity |
| Strength training | Bench press, Squats, Deadlift, Push-ups, Pull-ups, Dumbbell exercises, Resistance bands | Sets, reps, weight per set, duration |
| Flexibility & mind-body | Yoga, Surya Namaskar, Pilates, Stretching, Tai chi | Duration, intensity |
| Sports | Cricket, Badminton, Football, Tennis, Basketball, Table tennis, Kabaddi | Duration, intensity |
| Daily activity | Steps, Household chores, Gardening, Climbing stairs | Steps or duration |
| Custom | Anything else | Name, duration, calories (manual) |

- ACT-01 MUST: Calories burned = MET × body weight (kg) × duration (h); MET values from the Compendium of Physical Activities, stored in a seed table.
- ACT-02 MUST: User can override the calculated calories (e.g. from a smartwatch).
- ACT-03 MUST: Daily activity total feeds the diary summary (eaten − burned = net; remaining vs target).
- ACT-04 SHOULD: Save workout templates (e.g. "Leg Day") and copy activities from another date. **\[Added\]**
- ACT-05 SHOULD: Weekly activity minutes vs WHO guideline of 150 minutes moderate activity. **\[Added\]**

## 8. Sharing with friends (SHR)

Friendship works like Facebook friend requests; sharing is a separate per-friend switch.

- SHR-01 MUST: Users find friends only by typing a friend's exact user ID. The app never lists, browses or suggests other users, and does not autocomplete partial IDs. An exact match shows that one person's display name and photo with a Send request button; no match shows "No user found". The other user must accept the request; they can also decline or ignore it. Pending requests appear under Friends → Requests with a badge count.
- SHR-01a MUST: User ID lookups are rate-limited (e.g. 20 per hour per user) so nobody can guess IDs to discover who uses the app. Users can copy or share their own user ID from their profile to give to friends. **\[Added\]**
- SHR-02 MUST: An accepted request makes both users friends. Either side can unfriend at any time, which ends all sharing both ways immediately.
- SHR-03 MUST: The Friends list shows a **Share my food log** ON/OFF toggle beside each friend. Default is ON when the friendship is accepted (configurable in Settings). Turning it OFF hides your diary from that friend only.
- SHR-04 MUST: Sharing is one-directional: if A shares with B but B's toggle is OFF for A, B can see A's diary and A cannot see B's.
- SHR-05 SHOULD: Under the toggle, optional extras: also share activities, nutrition totals, weight (weight default OFF). **\[Added\]**
- SHR-06 MUST: Friends see a read-only Friends feed and can open a sharing friend's diary by date.
- SHR-07 SHOULD: Friends can react (like) and comment on a meal; the owner gets an in-app notification. **\[Added\]**
- SHR-08 MUST: A user can mark a single day or meal as private, hidden even from friends with sharing ON. **\[Added\]**
- SHR-09 SHOULD: Users can block another user, which removes the friendship and stops further requests. **\[Added\]**

## 9. Administration (ADM)

- ADM-01 MUST: Admin console with: Public foods (search, add, edit, merge, delete), Bulk upload, MFP import, Review queue (FDB-10), Duplicate report, Users (list, deactivate, promote to admin), Import logs.
- ADM-02 MUST: Every change to the public database is recorded in an audit log (who, when, before/after). **\[Added\]**
- ADM-03 SHOULD: Merge tool: pick two foods, choose the surviving values, and repoint all diary entries to the survivor. **\[Added\]**
- ADM-04 SHOULD: Basic usage stats: active users, foods logged per day, top searched foods with no match (to guide database growth). **\[Added\]**

## 10. Data model (core entities)

Claude Code may refine fields, but these entities and relationships are required.

| Entity | Key fields | Relationships |
| --- | --- | --- |
| User | id, email, username, password\_hash, first\_name, last\_name, role, email\_verified\_at, created\_at | has one Profile, many Targets, FoodLogs, Activities |
| Profile | dob, sex, height\_cm, units, timezone, activity\_level, goal, weekly\_rate, diet\_pref, allergies\[\], conditions\[\] | belongs to User |
| WeightEntry | date, weight\_kg | belongs to User |
| Target | effective\_from, calories, carbs\_g, fat\_g, protein\_g, fiber\_g, sugar\_g, sodium\_mg, water\_ml, is\_custom | belongs to User (history kept) |
| PublicFood | name, normalized\_name, brand, category, diet\_tag, base\_qty, base\_unit, base\_grams, nutrients (columns), source, source\_id, status | has many FoodServingUnits, FoodAliases |
| PersonalFood | same as PublicFood + owner\_id, copied\_from (source + id) | belongs to User |
| FoodServingUnit | food\_id, unit, grams | belongs to a food |
| FoodAlias | food\_id, alias | belongs to a food |
| IndbReference | INDB and IFCT 2017 fields as published (one table per source) | read-only lookup |
| FoodLog | user\_id, date, meal (Breakfast/Lunch/Snacks/Dinner), food\_ref, quantity, unit, grams, nutrient snapshot, source, source\_record\_id, edited flag | belongs to User |
| MatchMemory | user\_id, typed\_text, food\_ref | remembers picker choices |
| ActivityType | name, category, met\_value | seed data |
| ActivityLog | user\_id, date, activity\_type, duration\_min, distance, sets\[\], calories, is\_override | belongs to User |
| Share | owner\_id, viewer\_id, status, scopes | between two Users |
| Comment / Reaction | author\_id, food\_log\_date, meal, body | on a shared meal |
| ImportJob | uploaded\_by, file\_name, target (public/personal), counts, errors, created\_at | — |
| AuditLog | actor\_id, entity, entity\_id, before, after, at | — |

FoodLog stores a **nutrient snapshot** at logging time, so editing a food later does not silently change past days. **\[Added\]**

Additional entities: **WaterLog** (user\_id, date, amount\_ml, logged\_at) and **DiaryPreferences** (user\_id, visible nutrient columns, container sizes).

## 11. Non-functional requirements (NFR)

| ID | Area | Requirement |
| --- | --- | --- |
| NFR-01 | Performance | Diary page loads in under 2 s on 4G; local food search returns in under 300 ms; external search results within 3 s with a loading skeleton. |
| NFR-02 | Resilience | If an external API fails or times out, show local results and a non-blocking notice; cache external responses for 24 h. |
| NFR-03 | Security | OWASP Top 10 covered: Argon2id hashing, CSRF protection, input validation (Zod), parameterised queries (Prisma), HTTPS only, secure HttpOnly cookies, row-level authorisation on every query. |
| NFR-04 | Privacy | Health data treated as sensitive; no third-party analytics without consent; secrets only in environment variables, never committed. |
| NFR-05 | Accessibility | WCAG 2.1 AA: text contrast ≥ 4.5:1 over glass backgrounds, full keyboard navigation, visible focus rings, `prefers-reduced-motion` respected. |
| NFR-06 | Responsiveness | Works from 360 px to 1920 px width; bottom tab bar on mobile, sidebar on desktop. |
| NFR-07 | Browsers | Latest two versions of Chrome, Edge, Safari, Firefox. |
| NFR-08 | Reliability | Daily database backup; migrations via Prisma, never manual. |
| NFR-09 | Quality | Unit tests for parser, unit conversion, target formulas, title-casing, de-duplication; Playwright tests for register → log food → copy day → share. Minimum 80% coverage on `lib/`. |
| NFR-10 | Localisation | English UI; all strings in one resource file so Tamil/Hindi can be added later. |

## 12. UI / UX design system

### 12.1 Visual direction

Premium, modern glassmorphism on a minimal neutral base, with a green-to-blue accent gradient.

| Token | Value |
| --- | --- |
| Accent green | `#22c55e` |
| Accent blue | `#3b82f6` |
| Primary gradient | `linear-gradient(135deg, #22c55e 0%, #3b82f6 100%)` |
| Base background (light) | Neutral off-white `#f8fafc` with 2–3 large, blurred, low-opacity green/blue gradient blobs |
| Base background (dark) **\[Added\]** | `#0b1120` with the same blobs at lower opacity |
| Glass card | `background: rgba(255,255,255,0.55)`; `backdrop-filter: blur(16px) saturate(160%)`; `border: 1px solid rgba(255,255,255,0.35)`; radius 20 px |
| Shadow | Soft, layered: `0 8px 32px rgba(15,23,42,0.08)` |
| Typography | Inter or Plus Jakarta Sans; tabular numbers for nutrition values |
| Text | Slate-900 / Slate-600 (light), Slate-50 / Slate-400 (dark) |
| Motion | 200–300 ms ease-out transitions; disabled under reduced motion |

### 12.2 Where the gradient is used

- **Highlights:** active nav item, today's date, progress rings, key numbers (calories remaining).
- **Buttons:** primary buttons filled with the gradient, white text; secondary buttons glass with gradient border.
- **Hover states:** cards lift 2 px and gain a soft gradient glow; buttons brighten and shift the gradient angle.
- **Decorative glows:** background blobs, glow behind the logo, focus rings.

### 12.3 Required elements

- Soft shadows on all elevated surfaces.
- Glassmorphism cards for every section: meal cards, summary, activity, profile, admin panels.
- Gradient accent buttons, smooth hover and press transitions.
- Animated macro progress rings that fill on load; count-up animation on calorie totals.
- Subtle illustrations or food imagery: landing hero, empty states ("Nothing logged for Breakfast yet"), onboarding steps. Use royalty-free or original illustrations only. **\[Added\]**
- Skeleton loaders during search; toast notifications for saves and errors.
- Logo: wordmark "Nutrelia" with a leaf/drop mark in the gradient; tagline on landing and login pages.

### 12.4 Information architecture

| Area | Screens |
| --- | --- |
| Public | Landing (hero, tagline, features), Login, Register, Forgot / Reset password, Verify email |
| Onboarding | 4-step wizard: About you → Body → Goal & activity → Review targets |
| App (nav tabs) | Dashboard · Diary · Activity · Foods (My Foods) · Friends · Progress · Settings |
| Admin | Public Foods · Bulk Upload · MFP Import · Review Queue · Duplicates · Users · Logs |

Dashboard shows today's calorie ring, macro bars, water, net calories, weight trend and a friends' activity snippet.

## 13. Delivery plan

### 13.1 Repository and workflow

- Code lives in the **private** GitHub repository `sankumar76/Nutrelia-App` (`https://github.com/sankumar76/Nutrelia-App.git`).
- Branching: `main` (stable) + feature branches per milestone; Conventional Commits referencing requirement IDs (e.g. `feat(LOG-07): free-text parser`).
- Repo includes `README.md` (setup, env vars, scripts), `.env.example`, `docker-compose.yml`, seed scripts (admin user, activity METs, INDB reference, sample public foods), and GitHub Actions CI running lint, type-check and tests on every push. **\[Added\]**
- No secrets, API keys or personal data committed.

### 13.2 Milestones

1. **Foundation:** project setup, design system (glass components, gradient buttons, theme), auth, onboarding, profile, targets.
2. **Food data:** schema, public/personal databases, food editor, INDB load, OFF + USDA search, de-duplication script.
3. **Logging:** diary with four meals, free-text parser, matching tiers, picker, copy from date, dashboard.
4. **Import:** MFP printable-diary parser, preview, import log.
5. **Activity:** activity tab, MET calculations, net calories.
6. **Social & admin:** sharing, friend feed, comments, admin console, audit log.
7. **Hardening:** accessibility pass, performance, end-to-end tests, deployment.

### 13.3 Future (COULD)

Barcode scanning, native mobile apps, Google Fit / Apple Health sync, photo-based food recognition, meal plans, reminders/push notifications, Tamil and Hindi UI, dietitian accounts.

## 14. Acceptance criteria (key flows)

- [ ] A new user registers, verifies email, completes onboarding and sees calculated targets within 2 minutes.
- [ ] Forgot password sends a link; the link works once and expires after 30 minutes.
- [ ] Typing `chapathi-2, Dal 1 cup` in Lunch logs Chapathi × 2 and Dal × 1 cup with correct nutrition, displayed in Title Case.
- [ ] Typing `Flax seeds 10tbsp` logs 10× the 1 tbsp values from a single public record.
- [ ] A food with two matches opens the picker; the chosen item is remembered next time.
- [ ] A food found only in USDA is added to the user's personal database after selection.
- [ ] Importing an MFP printable diary creates foods without duplicates and shows an import summary.
- [ ] Copying yesterday's Breakfast into today works for whole day and single meal.
- [ ] Logging 30 min of jogging reduces calories remaining by the MET-based amount.
- [ ] Friend B sees only what A shared; access disappears immediately when A revokes.
- [ ] Admin cannot save a public food that duplicates an existing one without confirming a merge.
- [ ] All screens pass WCAG AA contrast and work at 360 px width.

## 15. What I added to your brief

| Area | Addition | Why (industry standard) |
| --- | --- | --- |
| Accounts | Email verification, login rate-limit, change password, data export and account deletion | Security baseline; required by India's DPDP Act 2023 and GDPR |
| Profile | Date of birth (age derived), sex, goal weight, activity level, goal and weekly rate, diet preference, allergies, health conditions, units, time zone, username | Needed for accurate calorie targets (Mifflin-St Jeor) and relevant food results; used by MyFitnessPal, HealthifyMe |
| Safety | Health disclaimer, minimum age 18, calorie floor of 1,200/1,500 kcal | Standard guardrails in nutrition apps |
| Targets | Sugar, saturated fat, sodium, cholesterol limits; water target; target history | Cronometer and MyFitnessPal track these |
| Progress | Weight log and progress chart, BMI | Core motivation feature in all comparable apps |
| Foods | Serving units with gram weights, aliases (Roti/Chapati), recipes, submit-to-public review queue, nutrition-label editor with calorie check, bulk CSV upload, audit log, merge tool | Keeps data clean and makes quantity scaling work for any unit |
| Logging | Recent/Favourite quick add, remembered picker choices, review-before-save, nutrient snapshot, copy yesterday, copy from friend | Speeds up daily logging, a top retention driver |
| Activity | Full category list, MET-based calories, manual override, workout templates, weekly 150-minute goal | Mirrors MyFitnessPal/Cronometer exercise logs and WHO guidance |
| Sharing | Per-friend visibility scopes, reactions and comments, private days/meals | Privacy control plus the "review/get inspired" goal |
| Design | Dark mode, illustrations for empty states, skeleton loaders, reduced-motion support, WCAG AA | Modern UX and accessibility standards |
| Engineering | Tech stack, CI, Docker, test coverage, performance targets | Gives Claude Code a clear definition of done |

Also added during review: nationality-based nutrition guideline (ICMR-NIN or General), an 18+ age gate, a block option for friends, the detailed MFP parser rules, IFCT 2017 as a reference source, and free-tier hosting notes.

## 16. Open questions for the owner

Resolved on 17 Oct 2026:

| Question | Decision |
| --- | --- |
| Blue accent | `#3b82f6` |
| Existing repo | Keep it if it uses the 2.3 stack, otherwise start a new private repo |
| Hosting | Lowest cost: Vercel free tier + Neon free Postgres |
| MFP sample | Four exports supplied; parser spec in 5.1 |
| MFP import scope | Foods and nutrition only; meal labels, dates and diary entries are not imported |
| Friends | Mutual friend requests by exact user ID, with a per-friend share toggle (section 8) |
| Share default | ON when a friend request is accepted |
| Minimum age | 18 (PROF-04) |
| Targets | ICMR-NIN for Indian users, General formula for others, switchable (3.3) |
| Indian food data | INDB and IFCT 2017 both approved for use |
| Public database seed | The 194 distinct foods from the owner's MFP exports |
| First admin | User ID `admin`, email `sankumar76@yahoo.com` (2.4) |

Still open:

No open questions remain. New requirements may still be added while the document is at 1.0 (draft).
