# UX Specification: Nutrelia v1 (early preview)

| Field | Value |
|-------|-------|
| Version | 0.6 (round 5 after the delivery lead's decisions of 2026-11-19: palette B "Calm Teal" everywhere, light slate side menu with a solid teal Add food button that first asks which meal, merge confirmation in the MyFitnessPal import, 30-day grace period for account deletion, admin tools drawn, recipes in v1, Settings > Diary column chooser. Round 4 before it: designed side menu, unmistakable table headers, full-width three-line food rows. Round 3: smaller type scale, single-line tables, day summary at the bottom, full-page Add food) |
| Owner | ux-expert |
| Status | Draft for customer review. Not a gate decision. G1/G2 artefacts do not exist yet. |
| Inputs | `REQUIREMENTS.md` v1.0 draft (de-facto PRD), `CLAUDE.md`, `docs/templates/ux-spec.md` |
| Visual reference | `docs/03-ux/wireframes/nutrelia-screens.html` (high-fidelity static mock-ups, open in a browser). Website (desktop) frames come first in every section; phone frames are kept collapsed under "Mobile version (for later review)". Responsive behaviour: section 4.1. |
| Decisions needed | `docs/03-ux/review-notes.md` (Q1 to Q28; Q24 to Q28 are new in round 5) |

Terminology follows REQUIREMENTS.md: Guest, User, Friend (viewer), Admin; Public / Personal food database; Diary; Meals are **Breakfast, Lunch, Snacks, Dinner**; "Targets" (not "goals") in the product, "Daily Goal" row only in the diary summary as the requirements name it (LOG-UI-07). Plain-language labels are used in the UI; the formal terms stay in this spec.

Assumptions used throughout (A-nn): see section 11.

---

## 1. Design Principles

1. **One obvious next step.** Every screen has exactly one primary button. Everything else is secondary, ghost or a link.
2. **Say what happened, in words.** Colour never carries meaning alone. Status, "over target" and data source are always written ("1 g over the 22 g limit", "USDA to Personal").
3. **Type like a person.** Free text is the main way in. The app shows what it understood and asks only when it must (LOG-07 to LOG-13).
4. **Safe by default, undoable.** Delete shows an Undo toast, not a confirm box (LOG-UI-04). Destructive account actions need a typed confirmation. Nothing is saved from a parse without a review step (LOG-13).
5. **Calm, readable, Indian-first.** Compact text (14 px body, 12 px small; reduced from 16/14 after review), generous spacing, Indian foods and units (katori, bowl, piece) in every example, glass effects kept subtle so text always wins.

## 2. Personas & Key Tasks

Personas are derived from the roles in REQUIREMENTS.md section 2.4. No role is invented. The named sample people are placeholders. Persona traits (age, habits) are **assumptions** (A-01) to validate in the usability test.

| Persona | Role | Top tasks | Context of use |
|---------|------|-----------|----------------|
| **Priya S.** (new/regular tracker, 28, wants to lose weight steadily) | User | Register, set up profile and targets, log meals by typing, check calories left, copy a day, log a walk, check weight trend | Mostly phone browser/PWA, several times a day, quick sessions, often on 4G |
| **First-time non-technical user** (any age 18+) | Guest then User | Understand the product from the landing page, register without confusion, finish onboarding, log the first meal | First visit, low patience, no nutrition vocabulary |
| **Rohan K.** (friend/accountability partner) | Friend (viewer) | Accept request, view a shared diary read-only, react and comment, copy a meal | Phone or laptop, a few times a week |
| **Admin (owner / curator)** | Admin | Manage public foods, resolve duplicates, review user-submitted foods, run MyFitnessPal import, view import logs, manage users | Desktop, weekly sessions, data-heavy |

## 3. User Journeys

Each journey lists trigger, steps, recovery paths, success criteria and linked requirements. High-fidelity frames are in the HTML (section numbers in brackets).

### UJ-01 Join and get first targets  [HTML 1 to 5]
- **Persona / trigger:** First-time user opens the landing page.
- **Steps:** 1. Landing, tap "Create free account". 2. Register (User ID, email, date of birth, password, health disclaimer tick). 3. "Check your email" screen; open the link (24 h). 4. Onboarding steps 1 to 4 with progress bar. 5. Review and confirm targets. 6. Lands on the Diary with a first-time hint.
- **Recovery paths:** User ID taken or reserved: inline message with how to fix. Under 18: friendly block, nothing stored (PROF-04). Password too common or weak: inline guidance. Verification link expired: "Send me a new link". Browser closed mid-onboarding: resume at the first incomplete step on next login. Unverified user can browse but cannot log food (banner on Diary).
- **Success criteria:** Targets shown within 2 minutes of starting (REQUIREMENTS section 14).
- **Linked FRs:** AUTH-01, 02, 03, 10; PROF-01, 03, 04; TGT-01, 02, 05.

### UJ-02 Log a meal by typing  [HTML 7, 8]
- **Trigger:** User wants to record Dinner.
- **Steps (full page, no pop-up):** 1. Diary: tap "Add food" under Dinner (goes straight to Dinner; the menu button and the page-level "Add food" first show the meal chooser, SCR-28), or type in the Dinner box and press "Check". 2. The page "Add food to Dinner - Wed, 18 Nov 2026" opens with the search box pre-filled with what was typed (`Chapathi-2, Dal 1 cup, paneer butter masala 1 katori`). 3. The list of typed items appears on the left (matched, please choose, not found); the live-filter results for the selected item fill the rest of the page (full width, no detail panel). 4. Edit the search or use the Source filter and tabs; the list updates after about 300 ms with a "Showing N of M foods" line. 5. Every result already shows its calories and nutrients; change Servings or Serving size on the row if needed (the numbers update live). 6. Single food: press the round + on the row (toast "Added Chapathi (whole wheat) x1 to Dinner. Undo", row shows "Added"), or tick several rows with "Select several" and press "Add N foods to Dinner". Several typed items: + on a row chooses that food for the selected item, then "Add N foods to Dinner" (final check page). 7. Back on the Diary, meal tables, subtotal and the bottom summary update.
- **Recovery paths:** Several matches: results list, choice remembered. External source chosen: copied to My Foods, then logged. No match anywhere or filters too narrow: "No foods match ... Clear filters or create a new food" with Create and Try another spelling. Unknown unit: ask grams once, remember. External source down: local results plus a calm notice (NFR-02). Over the daily goal: warning shown on the final check page, user may still save. Leaving mid-way: typed text kept as draft; "Back to diary" asks before discarding resolved items.
- **Success criteria:** `chapathi-2, Dal 1 cup` logs Chapathi x2 and Dal x1 cup in Title Case with correct nutrition.
- **Linked FRs:** LOG-07 to LOG-13, FDB-03, LOG-SRC-01 to 05, UI-CAP-01 to 03.

### UJ-03 Review today and adjust  [HTML 6, 7]
- **Steps:** Dashboard shows calories left; open Diary; edit quantity inline; delete an item and use Undo; add water; add a note; mark day complete.
- **Recovery:** Delete mistake: Undo for 5 s. Failed load: "We could not load your day" with Try again.
- **FRs:** LOG-01 to 06, LOG-UI-01 to 14, WAT-01 to 04, TGT-05.

### UJ-04 Pick another day / copy a day  [HTML 9, 10]
- **Steps:** Tap date, drill Year, Month, Day; or Quick tools, "Copy yesterday's Dinner"; or "Copy from another date" with whole-day or meal mapping and a plain summary before copying.
- **Recovery:** Source day empty: message "Nothing was logged on that day" and the copy button is disabled. Future dates open for planning, shown lighter.
- **FRs:** CAL-01 to 07, LOG-03, LOG-14, LOG-15, WAT-06.

### UJ-05 Find or create a food  [HTML 11, 12]
- **Steps:** Search a name (same live-filter page as UJ-02, opened from the Foods menu without a meal); results in one-line rows grouped Your foods, Nutrelia list, Other databases; narrow with tabs and the Source filter; add; or create a food with the nutrition-label editor; optionally suggest it to Nutrelia (review queue).
- **Recovery:** No results: create option. Calorie check mismatch: warning with fix text. Duplicate warning (admin must merge or rename).
- **FRs:** LOG-08, 10, 11, FDB-01 to 06, 09 to 11, NFR-01, NFR-02.

### UJ-06 Import foods from MyFitnessPal  [HTML 13]
- **Steps:** Foods, Import; upload PDF/HTML; preview with flags; fix or skip flagged rows; for every food already in My Foods choose "Merge with my ..." or "Keep both" (or "Merge all N"), Import stays off until every merge row has a choice; confirm; see result and the import log.
- **Recovery:** Unreadable file: plain explanation and how to get the right file. Day totals mismatch: warning, foods from that day flagged. Nothing merges automatically: each duplicate needs an explicit choice (Q11). Unparsable serving: user types the serving. Same food, two unit names: user chooses one.
- **FRs:** IMP-01 to 06, FDB-05.

### UJ-07 Log activity  [HTML 14]
- **Steps:** Activity tab, "Add activity", pick category, enter minutes and intensity, see estimated calories, optionally override, save; see calories burned feed the Diary and Dashboard.
- **FRs:** ACT-01 to 05, CAL-07.

### UJ-08 Connect with a friend  [HTML 15]
- **Steps:** Friends, Add; type exact User ID; "Send request". Friend sees it in Requests, Accept. Sharing defaults ON; either person can switch it Off per friend. Friend opens the diary read-only, likes or comments.
- **Recovery:** "No user found" is shown for any non-match, without hints. Rate limit reached: "Too many searches. Try again in an hour." Sharing turned off while viewing: permission-denied screen.
- **FRs:** SHR-01 to 09, LOG-16.

### UJ-09 Change profile, targets and security  [HTML 16]
- **Steps:** Settings tabs: Profile, Targets, Diary columns, Water, Sharing, Security, My data. Weight change triggers the targets-recalculation prompt. Choose diary columns (Calories fixed, up to 7). Export data; delete account with typed confirmation: the account is hidden at once and deleted after 30 days; logging back in during that time shows the "Deletion scheduled" banner with Cancel deletion or Continue (SCR-31).
- **FRs:** PROF fields, TGT-02, TGT-03, AUTH-05, AUTH-09, LOG-UI-02, WAT-02.

### UJ-10 Recover a password  [HTML 4]
- **Steps:** Log in, "Forgot your password?", enter email, neutral confirmation, open link (30 min, once), choose new password. Other sessions signed out.
- **Recovery:** Expired or used link: "This link has expired", send a new one. Locked out after 5 failed logins: explanation and a reset shortcut.
- **FRs:** AUTH-04, 05, 06.

### UJ-11 Curate the public food database (Admin)  [HTML 18]
- **Steps:** Admin, Public Foods; add or edit with duplicate stop; Review Queue approve, merge or reject with a note; MFP Import to public list; check Import logs; manage Users; Bulk Upload (template, upload, check row errors, import); Duplicates (pairs with similarity %) then Merge (choose surviving values, audit note, confirm); Audit log (filter, before and after).
- **FRs:** ADM-01 to 04, FDB-05, 06, 10, IMP-05, 06.

### UJ-12 Track progress  [HTML 17]
- **Steps:** Progress tab: log weight, read weight trend, calories vs goal by day, water streak, weekly 150 active minutes.
- **FRs:** PROF-02, WAT-05, ACT-05.

### UJ-13 Make a recipe  [HTML 19]
- **Trigger:** The user cooks the same dish often and wants to log it as one food.
- **Steps:** 1. My Foods, "Create recipe". 2. Name it and say how many servings it makes. 3. Search ingredients with the same live search as Add food and press + on each (amount and unit are on the row). 4. Adjust amounts; the per-serving totals (calories, four macros, all seven diary columns) update live. 5. "Save recipe". 6. Later: Add food, tab Recipes, press + (change Servings first if needed); or open the recipe from My Foods and press "Add to diary" (meal chooser).
- **Recovery paths:** No ingredients or no name: Save is off with the reason. Wrong amount: edit on the row. Leaving mid-way: "You have changes that are not saved" guard. Deleting a recipe: dialog "Delete Veg Pulao? Past diary days keep their numbers."
- **Success criteria:** A five-ingredient recipe is saved in under 3 minutes and logged with one press afterwards.
- **Linked FRs:** FDB-12, FDB-09, LOG-08.

## 4. Information Architecture

```
Public (Guest)
  Landing  ->  Register  ->  Check email (Verify)  ->  Onboarding (4 steps)
           ->  Log in    ->  Forgot password -> Reset password
App (User)   [bottom tabs on phone: Home | Diary | Activity | Foods | More]
             [left sidebar on tablet/desktop: all items below]
  Home (Dashboard)
  Diary  (one day)   -> Meal chooser (menu or page-level Add food only) -> Add food (FULL PAGE: live search, items list, amount) -> Final check / Create food
                     -> Calendar picker (Year > Month > Day)
                     -> Copy from another date
                     -> Quick tools (copy yesterday, save as meal, clear meal)
  Activity           -> Add activity (cardio / strength / ...)
  Foods (My Foods)   -> Find a food, Create/Edit food, Create/Edit recipe (builder, detail), Import from MyFitnessPal
  Friends            -> Friends | Requests | Add;  Friend's diary (read-only)
  Progress           (More on phone)
  Settings           (More on phone) Profile | Targets | Diary | Water | Sharing | Security | My data
Admin (Admin only, separate "Admin" group in sidebar)
  Public Foods | Bulk Upload | MFP Import | Review Queue | Duplicates (-> Merge) | Users | Import logs | Audit log
```

- **Entry points:** Landing and Log in for guests; after login the user lands on Home (Dashboard). First login after onboarding lands on Diary with a hint.
- **Deep-link rules:** `/diary/YYYY-MM-DD`, `/diary/YYYY-MM-DD/add-food?meal=dinner&q=chapathi&source=nutrelia,indb&tab=all` (the search text, filters and tab live in the URL so Back, refresh and sharing keep the state), `/friends/<userId>/diary/YYYY-MM-DD`, `/foods`, `/foods/recipes/new`, `/foods/recipes/<id>`, `/settings/diary`, `/admin/bulk-upload`, `/admin/duplicates`, `/admin/duplicates/merge?a=..&b=..`, `/admin/audit`, `/foods/import`, `/admin/*`. Unauthenticated deep link: redirect to Log in, then back. A friend diary link without permission shows the permission-denied screen (SCR-24), never a 404 that reveals existence. Admin routes for non-admins show "You don't have access to this page" with a Home button.
- **Naming:** "Home" (Dashboard), "Foods" on phone and "My Foods" on desktop, "Add food" everywhere food is logged.
- **Phone navigation (Q2):** four primary tabs plus "More". REQUIREMENTS section 12.4 lists seven tabs; seven do not fit a 360 px bottom bar with readable labels.

## 4.1 Responsive rules

Decision (Santhosh): the site must be responsive on any device. Website (desktop) screens are reviewed first; the phone layouts are kept for later review. There are **no separate tablet mock-ups**: tablet widths use the same pages with the rules below.

| Rule | Detail |
|------|--------|
| Fluid, not stepped | Layouts stretch smoothly between widths. Columns use flexible grids (for example `grid-template-columns: 2fr 1fr` that collapses to one column), cards fill their column, content sits in a centred container with a maximum width of 1280 px on very wide screens. No fixed-width page layouts. Fixed sizes are allowed only for components (40 px website and 44 px phone tap targets, the 176 px ring, icon sizes). |
| Below 768 px (phone layout) | Single column. **Bottom navigation bar** with icons and labels (Home, Diary, Activity, Foods, More; Q2). Page padding 16 px. Diary tables become stacked one-line rows (LOG-UI-13). Only a slim "kcal left" bar is pinned at the top (LOG-UI-14); the full day summary is at the bottom, as a Nutrient / Totals / Goal / Remaining table. **Add food is a full screen, not a sheet.** The calendar and confirmation dialogs open as bottom sheets. |
| From 768 px (tablet width) | The bottom bar is replaced by a **collapsible left-hand menu**: shown as a 64 px icon rail (same light slate surface, labels in a tooltip, the Add food button becomes a round + icon), expandable to the full 224 px menu with a menu button. Page padding 24 px. Two-column pages (diary plus summary, dashboard plus right rail) stack the second column under the first until 1024 px. Dialogs are centred (max 560 to 860 px). |
| From 1024 px (full desktop layout) | Full left menu (224 px, expanded by default, the user's collapse choice is remembered). Two-column and three-card layouts as drawn in the website frames. Calendar and Quick tools open as dropdowns. |
| Typography and spacing | The four text sizes and the spacing scale never change with width. Only layout changes. |
| Wide tables | Every table is wrapped in its own horizontal scroll box and every cell stays on one line (section 7, "Table rule"). Diary and My Foods show all columns from about 1100 px of content width; narrower, the table scrolls sideways inside its box (first column and meal name stay visible, A-17). The page itself never scrolls sideways. |
| Images and charts | Charts resize to their container and keep their text summary. |
| Orientation and zoom | Works in portrait and landscape and at 200% zoom without losing content or functions (WCAG reflow). |

**Test widths** for every screen before sign-off: **360, 768, 1024 and 1440 px**. Also check the widths just below each breakpoint (767 and 1023 px) for smooth stretching with no overlap or clipped text. Per-screen "Responsive" notes elsewhere in this spec that mention 360, 768 and 1280 should be read as phone, tablet width and full desktop; this section takes precedence.

## 4.2 Side navigation (website, every user and admin screen)

Round 4 replaced the plain list with a designed menu. Same structure on every website frame; the phone keeps its bottom bar (last row).

| Part | Specification |
|------|---------------|
| Surface | Light slate: `--nav-bg` #f1f5f9 (dark #0f172a) with a 1 px `--nav-border` line on its right edge. 224 px wide, full height of the app area. (Round 4's deep green gradient is gone.) |
| Text and icons | `--nav-text` #1e293b (13.4:1), icons 20 px, same colour. Group labels use `--nav-muted` #526277 (5.7:1), 12 px semibold, uppercase with letter spacing. Dark theme: #e2e8f0 and #9aa8bd on #0f172a, both above 7:1. |
| Logo | Logo mark and "Nutrelia" at the top, on the surface, in `--nav-text`. |
| Add food button | Directly under the logo: a **solid teal button** (`--nav-cta-bg` #0f766e, text `--nav-cta-text` #ffffff, 5.5:1; dark #2dd4bf with #042f2e), 40 px, + icon, hover `--brand-hover`. It is the app-wide menu control (`aria-haspopup="dialog"`) and **first opens the meal chooser** (SCR-28); it does not guess the meal (Q23c). **Relation to the one-primary rule:** the rule counts primary buttons in a page's content area. The menu button belongs to the app chrome, always sits in the same place and does the same thing as a page-level "Add food" (it opens the same chooser), so a page keeps its own single primary. On the Diary and Dashboard two teal "Add food" buttons are therefore visible; flagged as Q24. Not shown in the admin menu. There is no "on-dark" button style any more. |
| Groups | User menu: **Track** (Home, Diary, Activity, Progress), **Foods** (My Foods), **Social** (Friends). Admin menu: **Admin** (Public Foods, Bulk Upload, MFP Import, Review Queue with a count badge, Duplicates, Users, Import logs, Audit log). Each group is `role="group"` with an `aria-label`; the visible small-caps label is decorative for screen readers. |
| Item | 40 px high, 12 px side padding, 12 px gap between icon and label, 12 px radius, semibold. |
| Hover | Faint teal tint (`--row-hover`). |
| Active | White-teal pill (`--nav-active-bg` #d3efec, text `--nav-active-text` #0b4a45, 8.3:1) with a 4 px teal edge bar (`--nav-bar`) on its left; the link has `aria-current="page"`. Shown by fill, bar and text colour, not colour alone. |
| Focus | 3 px `--brand-ink` outline (offset 2 px), 5.5:1 on the slate surface. |
| User card | Pinned to the bottom, under a divider: avatar with initials ("PS"), name ("Priya S."), a muted "Signed in" line, then two small links side by side: **Settings** (shows the active pill and `aria-current` on Settings screens) and **Log out**. Links are 32 px high (above the 24 px minimum of 2.5.8). The admin card shows "Admin user" with **Back to app** and **Log out**. |
| shadcn/ui | Built from the `sidebar` block (SidebarHeader, SidebarGroup with SidebarGroupLabel, SidebarMenu and SidebarMenuButton with `isActive`, SidebarFooter for the user card), themed by mapping the `--sidebar-*` variables to the `--nav-*` tokens in section 7. The Add food button is a `Button` (default variant) with the nav CTA tokens; it opens a `Dialog`. |
| Phone bottom bar | Unchanged: five tabs (Home, Diary, Activity, Foods, More), icon above label. The active tab gets a brand-tinted pill (56 x 32 px, full radius) behind its icon and a brand-coloured label; inactive tabs keep a transparent pill so icons do not jump. Bar height 64 px. |

## 5. Screen Inventory

HTML column: section in `nutrelia-screens.html`. Fidelity: **H** = high-fidelity mock-up in the HTML, **W** = written wireframe and specification in section 6 only.

| ID | Screen | Purpose | Persona | Journeys | Requirements | Fidelity |
|----|--------|---------|---------|----------|--------------|----------|
| SCR-01 | Landing | Explain value, one CTA | Guest | UJ-01 | Section 2.4, 12.3, PROF-03 | H (1) |
| SCR-02 | Register | Create account | Guest | UJ-01 | AUTH-01, 02, 10; PROF-03, 04 | H (2) |
| SCR-03 | Check email / Verify | Confirm email | Guest | UJ-01 | AUTH-03 | H (2) |
| SCR-04 | Log in | Sign in with ID or email | Guest | UJ-10 | AUTH-06, 07, 11 | H (3) |
| SCR-05 | Forgot / Reset password | Recover access | Guest | UJ-10 | AUTH-04, 02 | H (4) |
| SCR-06 | Onboarding steps 1 to 3 | Collect health profile | User | UJ-01 | PROF fields, PROF-01 | H (5) |
| SCR-07 | Onboarding step 4: targets | Review and edit targets | User | UJ-01 | TGT-01, 02, 05 | H (5) |
| SCR-08 | Dashboard (Home) | Today at a glance | User | UJ-03 | LOG-02, TGT-05, PROF-02, ACT-03, SHR-07 | H (6) |
| SCR-09 | Diary (day) | Log, view and edit food | User | UJ-02, 03 | LOG-01 to 06, LOG-UI-01 to 14, LOG-SRC, WAT-01 to 04 | H (7) |
| SCR-10 | Add food page (full page): live search, typed-items list, amount, final check, create | Free-text and search logging | User | UJ-02 | LOG-07 to 13, FDB-03, LOG-SRC | H (8, 19) |
| SCR-11 | Calendar picker | Choose a date | User | UJ-04 | CAL-01 to 07 | H (9) |
| SCR-12 | Copy from another date + Quick tools | Reuse meals | User | UJ-04 | LOG-14, 15, WAT-06 | H (10) |
| SCR-13 | Find a food (same page as SCR-10, no meal preselected) | Search all tiers | User | UJ-05 | LOG-08, 10, LOG-SRC, NFR-01, 02 | H (11) |
| SCR-14 | My Foods | Manage personal foods | User | UJ-05 | FDB-09, 10, 11, LOG-05 | H (11, 19) |
| SCR-15 | Create / edit food | Shared food editor | User, Admin | UJ-05, 11 | FDB-01 to 06, FDB-11, section 4.1 | H (12) |
| SCR-16 | MFP import: upload, preview with merge choices, result | Import foods | User, Admin | UJ-06 | IMP-01 to 06 | H (13) |
| SCR-17 | Activity | Log exercise | User | UJ-07 | ACT-01 to 05 | H (14) |
| SCR-18 | Friends: list, requests, add | Manage friends and sharing | User | UJ-08 | SHR-01 to 05, 09 | H (15) |
| SCR-19 | Friend's diary (read-only) | View, react, comment, copy | Friend | UJ-08 | SHR-06, 07, 08, LOG-16 | H (15) |
| SCR-20 | Settings: Profile, Security, My data (30-day deletion) | Profile and account | User | UJ-09 | PROF, AUTH-05, 09 | H (16) |
| SCR-21 | Settings: Targets, Diary (choose columns), Water, Sharing | Preferences | User | UJ-09 | TGT-02, 03, 04, LOG-UI-02, WAT-02, SHR-03 | H (16, Diary) and W (6.21) |
| SCR-22 | Progress | Trends | User | UJ-12 | PROF-02, WAT-05, ACT-05 | H (17) |
| SCR-23 | Admin: Public Foods, Review Queue, Import logs, Users | Curate | Admin | UJ-11 | ADM-01, 04, FDB-05, 06, 10, IMP-05, 06 | H (18) |
| SCR-24 | Permission denied / Not found / Offline | Safe failure pages | All | all | NFR-02, SHR-02, SHR-03 | H (15) and W |
| SCR-25 | Admin: Bulk Upload, Duplicates report, Audit log, Merge tool | Data quality | Admin | UJ-11 | Section 4.1, FDB-06, ADM-02, ADM-03 | H (18) |
| SCR-26 | Notifications panel | See likes and comments | User | UJ-08 | SHR-07 | W (6.26) |
| SCR-27 | More (phone) | Overflow menu | User | all | Section 12.4 | H (16) |
| SCR-28 | Meal chooser (menu and page-level Add food) | Ask which meal before Add food | User | UJ-02 | LOG-07, LOG-UI-03 | H (8) |
| SCR-29 | Recipe builder (and empty state) | Make a recipe from ingredients | User | UJ-13 | FDB-12 | H (19) |
| SCR-30 | Recipe detail | View, edit, add a saved recipe | User | UJ-13 | FDB-12 | H (19) |
| SCR-31 | Deletion scheduled banner | Cancel or continue a pending account deletion | User | UJ-09 | AUTH-09 | H (16) |

## 6. Screen Specifications

### Global rules (apply to every screen unless a screen overrides them)

| Topic | Rule |
|-------|------|
| Loading | Skeleton rows that match the final layout for lists, cards and search (NFR-01). Spinners only inside a button after a press. Show skeletons only if loading takes longer than 300 ms. |
| Empty | Illustration or icon, one sentence on what goes here, one primary action, and an example where typing is involved. |
| Error | Plain words: what happened, that data is safe if true, what to do. Button "Try again" where retrying helps. Never show codes or blame. Errors beside fields appear on blur (first time) and on submit; the first invalid field receives focus after submit. |
| Success | Toast (5 s, polite live region) for saves; inline confirmation for page-level actions. |
| Disabled | Controls stay visible, 50% opacity, and a hint says why (for example "Fix 2 items to continue"). |
| Permission denied | Dedicated message with a way back; never reveals whether another user or page exists. |
| Offline (PWA) | Banner "You are offline. Showing your saved diary. New entries will be saved when you are back online." (A-06) |
| Delete | Undo toast 5 s for diary items (LOG-UI-04). Destructive account or database actions use a dialog with a typed or explicit confirmation. |
| Numbers | Tabular figures, right-aligned in tables, whole numbers in tables, one decimal in detail view (LOG-UI-05). |
| Table style (round 4) | Every table has an unmistakable header: a **solid slate header band** (`--th-bg` #1e293b, text `--th-text` #f8fafc, with a 3 px `--th-line` teal underline; dark #26354f) with semibold 12 px text, not uppercase. Macro columns (Carbs, Fat, Protein, Fiber) show their colour as a small dot with a light ring and a 3 px line along the bottom of the header cell; the name is always written. **Meal tables** (diary, copy preview, friend's diary) add a **meal band** above the column header: tinted `--band-bg` with a 4 px brand edge, meal name bold on the left and meal calories bold on the right ("Breakfast ... 321 kcal"); the column header then starts with "Food". The day summary table starts with a "Summary" header. Body rows: subtle zebra tint on even rows (`--zebra`), 1 px row dividers, hover tint (`--row-hover`), numbers right-aligned with tabular figures. **Total rows** (meal total, Remaining) are bold on `--foot-bg` with a 2 px top border; Remaining keeps the green, amber and crimson words (`--success`, `--warning`, `--error`) ("742 left", "1 over"). Applies to every table in every section, website and phone (on phone a meal card's title bar is the meal band). Header text is at least 9.9:1 on its band; success, warning and error text on the total row tint stays above 4.5:1. |
| Table rule (single line) | Every table cell, header cells included, stays on one line (`white-space: nowrap` on `th` and `td`). Numeric columns are right-aligned. Header labels are short with units in brackets ("Carbs (g)", "Protein (g)", "Sodium (mg)", "Calories"). Long text (food names, notes) is truncated with an ellipsis (`max-width`, `overflow: hidden`, `text-overflow: ellipsis`) and the full text is in a `title` tooltip and available to screen readers. Each table sits in its own scroll wrapper (`overflow-x: auto`); a table wider than its container scrolls inside the wrapper, never the page. No two-line headers ("Calories / kcal" is not allowed). |
| Summary at the bottom | A daily or day summary ("Today so far", totals vs goals) sits **below** the list it summarises, never above or beside it. The header may carry one slim line ("742 kcal left" with a thin bar). Applies to Diary, Activity and the friend's diary; the Dashboard is itself a summary page and is unchanged (Q20). |
| Food rows | Search result lists (Add food, Find a food) use the three-line food row in section 7 and SCR-10: everything visible at once, quick-add + on the row, no detail panel. Diary line items stay one-line table rows. |
| Names | Title Case on save and display (UI-CAP-01 to 03). |

### SCR-01 Landing
```
+---------------------------------------------+
| (logo) Nutrelia                   [Log in]  |
| Understand your food.                        |
| Nourish your future.                         |
| [ Create free account ]  <- only primary     |
| +-----------------------------------------+ |
| | Try typing:  Chapathi 2, Dal 1 cup      | |
| |  Chapathi x 2   208 kcal                | |
| |  Dal 1 cup      198 kcal                | |
| +-----------------------------------------+ |
| v Made for Indian foods                      |
| v Daily targets set up for you               |
| v Share with friends you choose              |
| Not medical advice.                          |
+---------------------------------------------+
```
**Components:** Button, Card, Input (display only), Badge. **Content:** H1 is the tagline; CTA "Create free account"; secondary "Log in" (ghost in header). **States:** Default; Loading (static page, none); Error (none); signed-in visitor is redirected to Home. **Responsive:** 360 single column; 768 hero plus demo side by side; 1280 hero, three feature cards, footer. **Accessibility:** one H1; sample box is decorative text with `aria-hidden` on the fake input; CTA first in tab order after the logo; contrast on glass 4.5:1 checked against the blob backgrounds.

### SCR-02 Register / SCR-03 Check email
**Form fields**

| Field | Type | Required | Validation rule | Error message |
|-------|------|----------|-----------------|---------------|
| User ID | text | Yes | 3 to 20 letters, numbers, underscore; unique ignoring case (AUTH-10); not reserved (section 2.4) | "That User ID is taken. Try another." / ""admin" is reserved. Please choose a different User ID." / "Use 3 to 20 letters or numbers." |
| Email | email | Yes | Valid format | "Enter an email like name@example.com." |
| Date of birth | date | Yes | 18 or older (PROF-04) | "Nutrelia is for people aged 18 and over, so we cannot create this account. We have not saved any of your details." |
| Password | password with show toggle | Yes | 8+ characters, a letter and a number, not in common list (AUTH-02) | "Use at least 8 characters with a letter and a number." / "That password is too common. Try a longer one that mixes words and numbers." |
| Health disclaimer | checkbox | Yes | Must be ticked (PROF-03) | "Please tick the box to continue." |

**Interactions:** validate on blur, strength meter updates live with text ("Strength: Good"); submit shows a spinner in the button. Registering with an existing ID or email never reveals which (uses the same generic text for email: "If this email can be used, we have sent a link"). **States:** Default; Loading (button); Error (per field and a top summary on submit); Success (go to Check email); Under 18 (block message, no data stored). **Check email screen:** shows the email address, "Open my email app", "Send the link again" (cooldown 60 s with countdown), "Wrong email? Go back." Link valid 24 h; expired link page offers a new link. **Responsive:** form column max 400 px centred at 768+. **Accessibility:** labels above inputs; password toggle is a button with `aria-pressed`; error summary has `role="alert"`; strength meter has text, not only colour; date input supports typing or picker.

### SCR-04 Log in
Fields: "User ID or email" (required, "Enter your User ID or email."), "Password" (required, "Enter your password."), "Keep me signed in for 30 days" checkbox (AUTH-07). Wrong credentials: "That ID or password is not right. Check both and try again." (does not say which). After 5 failures per 15 min: locked state, password input and button disabled, text "Too many tries. For your safety, log in is paused for 15 minutes." and a "Reset my password" button. **States:** Default, Loading (button), Error, Locked. **Accessibility:** autocomplete attributes (`username`, `current-password`); lock message in `role="alert"`; countdown not announced every second.

### SCR-05 Forgot / Reset password
Steps: (1) email field, button "Send reset link"; (2) neutral confirmation identical for every email (AUTH-04); (3) new password and repeat with strength meter ("The two passwords are different. Type the same password in both boxes."); (4) expired or used link page "This link has expired" with "Send me a new link". Success toast on step 3 then redirect to Log in with a message "Password changed. Please log in." **Accessibility:** focus moves to the page heading on each step; confirmation is a live region.

### SCR-06 Onboarding steps 1 to 3
Progress: segmented bar plus text "Step 2 of 4 - Your body". Back keeps entered values.

| Step | Fields |
|------|--------|
| 1 About you | First name, Last name (required, stored Title Case), Sex (Male/Female, helper "used only for your calorie calculation"), Country (required, picks guideline: India = ICMR-NIN, else General) |
| 2 Your body | Height (cm or ft+in), Current weight (kg or lb), Goal weight (required) with live BMI note (PROF-01) |
| 3 Your goal | Goal (Lose / Stay the same / Gain), Weekly rate (0.25, 0.5, 0.75, 1 kg), Activity level with plain examples, Diet preference (optional), Allergies (optional tags), Health conditions (optional chips; if any chosen, advice banner), Units and time zone (auto-detected, editable in Settings) |

| Field | Validation | Error message |
|-------|-----------|---------------|
| First / last name | 1 to 50 characters | "Please enter your first name." |
| Height | 100 to 250 cm | "Enter a height between 100 and 250 cm." (A-04: ranges to be confirmed) |
| Weight, goal weight | 30 to 300 kg | "Enter a weight between 30 and 300 kg." |
| Goal weight vs goal | Lose: goal below current | "For weight loss, your goal weight should be lower than your current weight." |
| Weekly rate | Required when goal is not "Stay the same" | "Choose how fast you would like to go." |

Primary button: "Continue" (steps 1 and 2), "See my targets" (step 3). **States:** Default; Error (inline); Loading (computing targets, 1 s skeleton on step 4); Resume (returning users start at the first incomplete step). **Accessibility:** one H1 per step, focus moved to it on step change; the segmented bar has `role="progressbar"` with `aria-valuenow`; segmented controls are radio groups with arrow-key support; the unit toggles announce their state.

### SCR-07 Onboarding step 4: Your daily targets
Shows Calories, Carbs, Fat, Protein, Fiber (grams or percent, a "Grams / Percent" switch; carbs, fat, protein stay at 100% in percent mode), Water (default 35 ml per kg), a one-line explanation of where the numbers come from ("Worked out from your profile using Indian (ICMR-NIN) guidelines. You can change any number.") and an expandable "How we worked this out" (A-03). Buttons: "Reset to recommended" (ghost), "Looks good, start logging" (primary). Calorie floor warning: "This is lower than the safe minimum of 1,200 kcal. We have set it to 1,200." **Validation:** percentages must total 100 ("Carbs, fat and protein must add up to 100%. Now: 104%."); calories 800 to 6,000 (A-04). **States:** default, Loading, Error computing ("We could not work out your targets. You can enter them yourself."), Edited (shows "Edited" badge and enables Reset). **Accessibility:** each macro row is labelled "Carbs in grams"; the total line is a live region.

### SCR-08 Dashboard
Regions: header (greeting, date, notification bell, primary "Add food"); calorie ring card (left: kcal left, eaten, burned, goal); nutrients card (four macro bars, colours fixed: carbs blue, fat orange, protein deep violet, fiber magenta; shown as dots and bars, never as text colour); weight trend card; right column: water, friends activity, notifications. **Primary action:** Add food. **States:** Loading skeleton cards; Empty (new user: ring at 0, "Log your first meal to see your day" with an example); Error per card (card shows "Could not load. Try again" without blocking others); Partial (friends card empty: "Add a friend to see their activity"). **Responsive:** 360 single column, ring first, then Add food, nutrients, water; 768 two columns; 1280 main plus right rail. **Accessibility:** ring is `role="img"` with label "742 kilocalories left of 1,933"; each bar is a `progressbar` with name, value and max; number count-up animation off under reduced motion; charts have text summaries.

### SCR-09 Diary
```
Desktop (1240 frame; table needs about 1100 px of content width):
+-------+--------------------------------------------------------------------+
| Side  | [<] [Wed 18 Nov 2026 v] [>] [Today]   742 kcal left |||||  [Add food]|
| nav   | [Breakfast ........................................ 321 kcal]  <- meal band
|       | Food           | Calories | Carbs (g) | Fat (g) | Protein (g) | Fiber (g) | Sugar (g) | Sodium (mg) | x |
|       |  Idli – 3 pieces [Nutrelia]    174       36         1        6          2          1         280      [bin]
|       |  + Add food | Quick tools v
|       |  Breakfast total               321       50         9        11         6          5         710
|       | Lunch ... Snacks ... Dinner (empty: type box + Check)
|       | ---- Day summary (BOTTOM) -------------------------------------------
|       | Totals / Your Daily Goal / Exercise / Remaining   (same columns as above)
|       | [Today so far: ring + bars] [Calories donut] [Water + Day notes]
+-------+--------------------------------------------------------------------+
Phone 390:
[ 742 kcal left  mini macro bars   Day summary ]   <- slim pinned bar only
[<]  Today, 18 Nov  [>]
[Breakfast .................. 321 kcal]  <- meal band (card title bar)
  Idli – 3 pieces                      174     (one line, ellipsis)
  [Nutrelia] C 36 · F 1 · P 6                  (one line)
  [ + Add food to Breakfast ]
...
Day summary (table: Nutrient | Totals | Goal | Remaining)   <- BOTTOM
[ Home | Diary | Activity | Foods | More ]
```
**Pattern:** a familiar food-diary table, as a structure only (the look is Nutrelia's: its palette, type scale, badges and spacing; no other brand's name, logo, colours or artwork). Each meal is a card containing one table. Above the column header sits the **meal band** (meal name left, meal calories right; see "Table style" in the global rules). The column header row is: **Food | Calories | Carbs (g) | Fat (g) | Protein (g) | Fiber (g) | Sugar (g) | Sodium (mg)** plus an unlabelled actions column (Q17, Q18). Macro colours appear as a dot and a 3 px line on the column header (carbs blue, fat orange, protein deep violet, fiber magenta), with the name written in the header. Each food row is one line: bold link-style name, then "– serving" in muted text, truncated with an ellipsis, then a small source badge (LOG-SRC); numbers right-aligned; one small "Remove" icon button; the name opens inline edit (LOG-UI-04). Under the rows: an "Add food" link and a "Quick tools" menu (LOG-UI-03), then the meal subtotal row. The phone Diary lists every food of each meal so each list adds up to its band (Lunch: 4 foods, 710 kcal; Snacks: 2 foods, 160 kcal in the sample). An empty meal collapses to one line with the type box, "Check" and "Copy yesterday's Dinner" (LOG-UI-06).
**Day summary at the bottom (replaces the right-hand "Today so far" column):** a table under the same columns with rows **Totals**, **Your Daily Goal**, **Exercise** (calories column only) and **Remaining** (LOG-UI-07). Remaining: green with "left" when under, amber with "over" up to 10% over, crimson with "over" beyond 10% (LOG-UI-08); protein and fiber show "Goal met" when over (A-14). Below it: progress ring and bars (LOG-UI-09), macro donut (LOG-UI-10), water and day notes (LOG-UI-12, LOG-06). The header keeps only one slim line: calories left (or "74 kcal over") with a thin bar, as a live status region. On phone the pinned bar is the same slim line (LOG-UI-14, reduced to one line) and the bottom summary is transposed (rows are nutrients; columns Totals, Goal, Remaining) so it fits without sideways scrolling.
**Components:** Card, Table inside a scroll wrapper, Badge (source), Progress, Tabs, Toast, DropdownMenu (Quick tools), Dialog (confirmations only). **Behaviour:** one primary button, "Add food" (header on desktop; on phone only in the empty meal, other meals use secondary buttons). "Add food" under a meal and the type box's "Check" open the Add food page (SCR-10) for that meal and date. The header "Add food" has no meal, so it opens the meal chooser (SCR-28), like the menu button. Delete shows toast "Removed Curd from Lunch. Undo" for 5 s. Source badge text is always visible; hover or tap shows the full path, record ID and "Edited by ... on ..." (LOG-SRC-01, 03); on narrow screens the badge shortens (LOG-SRC-05).

| State | Behaviour / content |
|-------|---------------------|
| Default | As above |
| Loading | Skeleton meal cards, summary skeleton at the bottom keeps its height |
| Empty day | "A fresh page. Nothing logged yet." Primary "Add your first food", secondary "Copy from another day", hint "Tip: type Idli 3, Sambar 1 katori". Meals collapse to single lines; the bottom summary shows zeros and Remaining equal to the goal |
| Empty meal | One line "Nothing logged for Dinner yet" with a type box, "Check" and "Copy yesterday's Dinner" |
| Partial | Nutrient missing on some foods: column shows an "incomplete" marker with tooltip (LOG-UI-11) |
| Over target | Slim header line turns amber or crimson with words ("74 kcal over"); alert above the summary table; Remaining cells coloured with "over" |
| Error | "We could not load your day. Your food is safe. Please check your internet connection and try again." [Try again] |
| Success | Toast "Added 4 foods to Dinner" |
| Email unverified | Warning banner; Add food links and button disabled with hint "Confirm your email first" |
| Future date | Lighter header style, label "(tomorrow)"; logging allowed for planning (CAL-03) |
| Permission denied | n/a (own diary) |

**Responsive:** under 768 px stacked one-line rows, slim pinned bar, bottom summary table (LOG-UI-13, 14); from 768 px the meal tables with all columns inside the scroll wrapper; the summary is below the meals at every width. Sticky table header on long days (LOG-UI-06). **Accessibility:** each table has a `<caption>` (visually hidden) per meal and column headers with units in the label; truncated names expose the full name through `title` and an `aria-label` on the link; icon buttons have names ("Remove Idli"); the summary table has row headers (Totals, Your Daily Goal, Exercise, Remaining) and Remaining uses words as well as colour; the slim header line is `role="status"`; delete toast is `role="status"` and Undo is reachable with Tab for the full 5 s (timer pauses while focused or hovered, A-07); keyboard shortcut `A` opens Add food (A-08, optional); focus returns to the row's neighbour after delete; animations off with `prefers-reduced-motion`.

### SCR-10 Add food page (full page; no pop-up, no sheet, no detail panel)
Route `/diary/YYYY-MM-DD/add-food?meal=dinner&q=...`. Only food selection moved to a page; other dialogs (delete, copy day, destructive confirmations) stay dialogs. **Round 4:** the right-hand detail panel (servings, serving size, meal, nutrition card) is removed. The results list is full width and every food is a self-contained row that shows everything at a glance.
**Round 5 additions.** (1) Tabs are now **All / Recent / Frequent / My Foods / Meals / Recipes** (counts as before). **Meals** stays "saved groups of foods" (Save as a meal); **Recipes** lists the recipes made in SCR-29. A recipe row is a normal three-line row with a "Recipe" badge and one serving as its serving size. The "Meals" tab is not renamed, because a meal group and a recipe are different things (a group is logged as separate foods; a recipe is one food). (2) The page is reached either straight from a meal ("Add food" link under Breakfast, Lunch, Snacks or Dinner, the meal is fixed) or through the **meal chooser** (SCR-28), which the menu button and the page-level "Add food" use.
```
Desktop, one search (full width):
< Back to diary   Diary / Wed 18 Nov / Add food to Dinner
H1 Add food to Dinner - Wed, 18 Nov 2026
[ search  chapathi                                   x ]
Showing 1-8 of 48 foods matching "chapathi"
[All 48 | Recent | Frequent | My Foods | Meals]
[Source v]                                        [Select several]
+--------------------------------------------------------------------------+
| Chapathi (whole wheat)  (v Verified)                                  (+) |  line 1
| Nutrelia · 1 medium (40 g) · 104 kcal                                    |  line 2
| 104 kcal · o Carbs 18 g · o Fat 2 g · o Protein 3 g · o Fiber 2 g        |  line 3
|                          Servings [1]  Serving size [1 medium (40 g) v]  |  (same line, right)
+--------------------------------------------------------------------------+
| ... 7 more rows, each the same three lines ...                           |
| [Show more results]                                                      |
+--------------------------------------------------------------------------+
Toast: Added Chapathi (whole wheat) x1 to Dinner      Undo

Desktop, several items typed (two columns, no third column):
+ Your items (4) --+ Choosing a food for: Paneer butter masala, 1 katori +
| Chapathi x2  ok  | [refine search x]  Showing 1-2 of 2 ...  [tabs]     |
| Dal 1 cup    ok  | row (three lines; + chooses this food for the item) |
| Paneer  choose   | row (three lines; inline grams question if needed)   |
| Kaddu   not found|                                                     |
| So far 406 kcal  |                                                     |
| [Add 4 foods][Add only matched]                                        |
Phone: full screen. Top bar, typed-text box, item chips, refine box, count line, tabs, Source chip, rows (line 3 wraps; Servings and Serving size on a 4th line).
```
**Live search (like an Excel filter):** unchanged from round 3. The search box is pre-filled with what the user typed and is editable; no Search button; the list filters after about 300 ms (A-16) and the previous results stay visible (dimmed, `aria-busy`) so it never flashes empty. A status line reads "Showing 1-8 of 48 foods matching "chapathi"" (adds "with Source: Nutrelia, INDB" when filters apply). Matched text is highlighted with `mark`. A clear (x) button returns focus to the box. Search text, tab and filters are kept in the URL.
**Filters:** tabs **All | Recent | Frequent | My Foods | Meals** with counts; an Excel-style **Source** dropdown ("Select all", a checkbox per source with its count, ticking applies instantly, "Clear filter"); removable chips and "Clear filters". The dropdown is a non-modal popover: Esc closes it and returns focus to its button. Beside the Source button, a ghost button **Select several** (see below).
**The food row (new pattern: three lines, always visible, about 72 to 84 px high on the website):**

| Line | Content |
|------|---------|
| 1 | Food name in bold with matched text highlighted; a small **Verified** badge (tick icon and the word) for admin-verified foods; at the far right a **round + quick-add icon button** (secondary button, icon only, 44 px, `aria-label="Add Chapathi (whole wheat) to Dinner"`, tooltip with the same text). |
| 2 | Small muted text: "source · serving · calories", for example "Nutrelia · 1 medium (40 g) · 104 kcal" (the base serving of the food). |
| 3 | Nutrition **for the chosen amount** in one line: "104 kcal · [dot] Carbs 18 g · [dot] Fat 2 g · [dot] Protein 3 g · [dot] Fiber 2 g", each macro with its colour dot and its name in words. Right-aligned on the same line: a compact **Servings** number box (label visible, default 1, 28 px high) and a **Serving size** select (label visible, the food's units, default the food's base serving). On phone, line 3 wraps and the two controls sit on a 4th line at 44 px height. |

- **Changing the amount** updates that row's line 3 immediately (servings x base values; a different serving size rescales by grams). Line 2 stays the base serving. Nothing is saved until + is pressed. Row 2 in the mock-up shows 2 servings (numbers doubled).
- **Quick add:** pressing + adds the food at the amount shown on that row to the page's meal, with no confirmation step (Q21). Feedback: toast "Added Chapathi (whole wheat) ×1 to Dinner · Undo" (5 s, polite live region, Undo reachable by Tab; timer pauses on hover or focus, A-07) and the row switches to the **Added** state (green left edge; + replaced by a check icon and the word "Added"; `aria-label` "Chapathi (whole wheat) added to Dinner, 1 serving. Press to add another."). The row stays in the list so the user can add another portion or keep searching. The Diary behind is updated when the user goes back.
- **Select several (optional, Q22):** the ghost button swaps each + for a tick box (the first control in the row). A bar at the bottom of the list shows "3 foods selected · 678 kcal", a ghost "Clear selection" and the page's one primary button **"Add 3 foods to Dinner"**. Servings and Serving size stay editable on each row. The toolbar button changes to "Done selecting" to leave the mode. Ticked rows are tinted with a brand left edge and the count is announced politely.
- **Unknown unit weight:** the question appears **inline on the row that needs it**, below line 3, in a warning-tinted strip: "We don't know how heavy 1 katori is for this food. About how many grams? We will remember it." with a "Grams in one katori" box (1 to 5,000), the checkbox "Remember my choice for "paneer butter masala"" and a secondary button "Use this food". The row cannot be added until it is answered.
- **Several items typed (LOG-07 to 13):** items split by comma or new line (max 30, A-04). The left list (240 px) shows each item with an icon, words ("Matched", "You chose this before", "2 matches - please choose", "Not found") and calories; selecting an item loads its own live search into the rest of the page (box pre-filled with the item name, editable; the typed text is not changed). There is **no third column**. In this mode the row's + means "use this food for the selected item" (`aria-label="Use Paneer Butter Masala for “Paneer butter masala 1 katori”"`): the item turns "Matched" in the left list and the next unresolved item is selected (A-20). Rules kept: "Add N foods to Dinner" is the primary button and stays disabled until every item is resolved (Q7); ghost "Add only the 2 matched foods"; "Not found" offers Create (SCR-15 pre-filled, then back here) and Try another spelling; remembered choices (LOG-12); 3 s external-source limit with partial results (Q9, NFR-01, NFR-02). The **final check** page is unchanged: one table (You typed, We found with source badge, Calories, Carbs, Fat, Protein), the Dinner total, the over-goal warning if relevant, "Edit text" (ghost) and "Add 4 foods to Dinner" (primary).
Accepted input examples (shown as the hint): `Chapathi 2`, `Chapathi-2`, `2 Chapathi`, `Flax seeds 10tbsp`, `Rice 1.5 cup`, `Milk 200ml`, `Idli`, `Dosa ½`.

| Field | Type | Required | Validation (when) | Error message |
|-------|------|----------|-------------------|---------------|
| Search / food text | search input | No for browsing; at least one item to add | Live, after about 300 ms; max 30 items (A-04) | "Type at least one food, for example Chapathi 2." / "That is a lot at once. Please add up to 30 foods at a time." |
| Quantity in text | parsed | No | Number, fraction or unicode fraction; positive | "We could not read the amount in "Rice abc". Try "Rice 1 cup"." |
| Servings (on each row) | number | Yes | On blur and on + ; above 0, up to 99 (A-04); an invalid value keeps the last good numbers on the row and disables + | "Enter a number above 0, for example 1 or 1.5." (inline under the row, linked with `aria-describedby`) |
| Serving size (on each row) | select | Yes | A unit must be chosen | "Choose a serving size." |
| Grams for unknown unit | number | Yes if unit unknown | 1 to 5,000 | "Enter the weight in grams, like 150." |
| Source filter | checkbox list | No | At least one source ticked; unticking all resets to All | n/a |
| Row tick box (Select several) | checkbox | No | The Add button needs at least one ticked row | "Tick at least one food." (button stays disabled with this hint) |

| State | Behaviour |
|-------|-----------|
| Default | Focus in the search box; results from Recent shown if the box is empty; every row shows lines 1 to 3 |
| Loading | Skeleton rows the height of a food row (three lines); status "Checking your foods..." with `aria-busy`; the external tier shows its own skeleton and times out at 3 s (NFR-01) |
| Row hover / focus | Light tint; the row never changes height |
| Row amount changed | Line 3 recalculates; no toast |
| Row added | "Added" state and toast with Undo; Undo removes the entry and restores the + |
| Row needs grams | Inline question strip on that row; + disabled until answered |
| Row error | Invalid Servings: red border, message under the row, + disabled |
| Select several | Tick boxes instead of +, bottom bar with count and the primary button |
| Filter applied | Chips, "Showing 1-5 of 11 foods matching "dal" with Source: Nutrelia, INDB", Clear filters link |
| Empty filter | "No foods match "kaddu ki sabzi" with Source: Nutrelia." / "Clear filters or create a new food." Buttons: Clear filters (secondary), Create "Kaddu Ki Sabzi" (primary) |
| Partial | External source failed: info alert "Open Food Facts is not answering right now. Showing everything else." |
| Not found (typed item) | "We could not find "Kaddu Ki Sabzi"" with Create and Try another spelling; item marked "Not found" |
| Error | "Something went wrong while checking your foods. Your text is still here. Try again." |
| Success | Toast per quick-add; on leaving, the Diary shows the updated meal table |
| Over target | Quick-add still works; the Diary shows the over-target state. The final check shows the warning; save allowed |
| Disabled / unverified | Page not reachable while email is unverified (links disabled on the Diary); a direct URL shows the unverified banner and the + buttons are disabled |
| Permission denied | n/a (own diary); a friend's diary has no Add food (SCR-19) |
| Offline | Banner; search of already loaded foods only; + is queued or disabled per A-06 |

**Responsive:** from about 1100 px of content width line 3 fits on one line; narrower (and in the several-items layout, where the left list takes 240 px) the two amount controls wrap onto a second line of line 3 and the row grows to about 100 px. Below 768 px the items list becomes a row of chips, the page is a single full screen and the Servings and Serving size controls sit on a 4th line at 44 px. No bottom sheet at any width. **Accessibility:** the page title and H1 are "Add food to Dinner"; on opening, focus moves to the search box. The results are a plain list (`ul` of `li`), **not** a listbox, because every row holds several controls. **Keyboard: from the search box, Tab goes into the first row and then through each row in this order: (tick box in Select several mode,) Servings, Serving size, + (Add)**; Enter on + adds; Space toggles a tick box; the name is text, not a stop. A skip link "Skip to results" follows the filters. Every + has a descriptive `aria-label` ("Add Chapathi (whole wheat) to Dinner"; in the several-items layout "Use ... for ..."); Servings and Serving size have visible `label`s tied with `for`. A polite `role="status"` line announces "Showing 8 of 48 foods matching chapathi" (and "No foods match ...") after each update, debounced so it is not announced per keystroke; a changed row announces its new line 3 politely (only the row being edited); the toast and the "Added" state are announced once; focus stays on the + (now "Added") after adding so keyboard users can press again or continue; Undo is reachable by Tab for the full 5 s. Item statuses and macro dots always come with words; highlighted matches keep 4.5:1 and are a convenience only. Targets: + is 44 px; the compact Servings and Serving size controls are 28 px high on the website (above the 24 px minimum of 2.5.8, at least 8 px apart) and 44 px on phone. The Source dropdown is a labelled group of checkboxes; chips have named remove buttons; "Back to diary" is first in the tab order after the skip link.

### SCR-11 Calendar picker
Header label button zooms out: Day view ("November 2026") -> Month view ("2026") -> Year view. Grid: logged days have a dot, today is outlined, selected is filled with the brand gradient, future days lighter. "Today" button at every level. Prev/next arrows move month (Day view), year (Month view). Year list runs from the user's earliest logged date or signup year to the current year (CAL-03). Bottom sheet on phone, popover on desktop. **States:** default; loading dots (skeleton dots, 300 ms); no logged days (no dots, nothing else changes). **Accessibility:** `role="grid"` with roving tabindex; arrows move, Enter selects, Esc closes (CAL-06); each cell has a full label ("Tuesday 17 November, food logged"); selected and today are indicated by outline and fill, not colour only; month and year changes announced politely.

### SCR-12 Copy from another date / Quick tools
Quick tools menu (per meal): Copy yesterday's {meal}, Copy from another date, Save as a meal, Clear this meal ("Clear" uses a dialog "Clear Dinner? 4 foods will be removed. You can undo for 5 seconds" or the Undo toast, A-09). Copy dialog: source date (uses SCR-11), "Whole day / Choose meals", per-meal mapping selects (Lunch into Dinner), optional "Also copy water" (WAT-06), a plain summary ("4 foods (710 kcal) will be added to today's Dinner. Nothing is replaced."), primary "Copy to Dinner". Errors: source day empty: "Nothing was logged on that day. Pick another day." Success: toast "Copied 4 foods to Dinner. Undo". **Accessibility:** menu is a `menu` with arrow keys; mapping selects have labels naming the source meal.

### SCR-13 Find a food
The same page and behaviour as SCR-10 (live search, tabs, Source filter, Select several, full-width three-line food rows with quick-add, no detail panel), opened from the Foods menu with no meal preselected. Because there is no fixed meal, the header carries an **"Add to" select** (default: the meal that fits the time of day, A-19) and + adds to that meal on the diary date. Results keep the app's search order as thin group rows: **Your foods**, **Nutrelia food list**, **Other databases** (INDB, IFCT 2017, Open Food Facts, USDA). Adding an external result copies it into My Foods and then logs it (hint under the list). Diet preference ranks results (A-05). **States:** as SCR-10 (Default, Loading, Filter applied, Empty filter "No foods match "dal xyz". Clear filters or create a new food.", Partial with one source down, Error "We could not reach the other databases. Your own foods and the Nutrelia list are still available.", Offline). **Responsive and accessibility:** as SCR-10; the "Add to" select has a visible label and comes before the search box in the tab order.

### SCR-14 My Foods
List with a search that filters the table as you type (with a "Showing 4 of 4 foods" line), tabs All / Favourites / Recent / Recipes (a recipe is a row with a "Recipe" badge and opens SCR-30), a single-line row in the food-table pattern: favourite star, name in bold link style with "– serving" and the source badge in the same cell, Calories, Carbs (g), Fat (g), Protein (g), Edit / Delete / Suggest to Nutrelia actions; "Suggest to Nutrelia" link (FDB-10); primary "Create food", secondary "Create recipe" (opens SCR-29) and secondary "Import". Empty: "No personal foods yet. Foods you create or pick from other databases will appear here." with Create and Import. Delete uses the dialog "Delete Almonds? Past diary days keep their numbers." (LOG-SRC-04, snapshot).

### SCR-15 Create / edit food (shared by users and admins)
Fields:

| Field | Type | Required | Validation | Error message |
|-------|------|----------|-----------|---------------|
| Name | text, search-first | Yes | 1 to 100 chars; saved in Title Case | "Please give the food a name." |
| Brand | text | No | 0 to 60 | n/a |
| Type | segmented (Veg, Egg, Non-veg, Vegan) | Yes | One chosen | "Choose a type." |
| Serving (quantity, unit, grams) | number, select, number | Yes | Quantity > 0, grams > 0 | "Enter how much one serving weighs, in grams." |
| Other units | repeatable (unit, grams) | No | Grams > 0 | "Enter the weight in grams." |
| Other names | tags | No | 0 to 10 | n/a |
| Calories, carbs, fat, protein, fiber, sugar, sodium (more under "More nutrients": sat fat, cholesterol, potassium, calcium, iron, vitamin C) | number >= 0 | Calories, carbs, fat, protein required | Calorie check: 4 x carbs + 4 x protein + 9 x fat within 15% of calories (section 4.1) | "These numbers add up to about 40 kcal, but you typed 55. Please check the calories, carbs, fat and protein." (warning, user may still save) |

Buttons: primary "Save food", secondary "Start from a food I already have", ghost "Cancel". Duplicate similar-name banner while typing (info). **Admin only:** at save, near matches 85%+ open the "This food may already exist" dialog: primary "Merge into the existing food", ghost "Go back and edit" (FDB-05, 06). Source badge with "Edited" marker shown for copied foods (LOG-SRC-03). **States:** default; saving; error ("We could not save this food. Try again."); success toast; permission denied (non-admin editing public food: "Only admins can change the Nutrelia list. You can make your own copy."). **Accessibility:** nutrition fields in a fieldset "Nutrition for 1 serving"; calorie warning linked with `aria-describedby`; unit and grams on one logical group.

### SCR-16 MyFitnessPal import
Steps (progress bar, "Step 1 of 3 - Upload / Check / Done"). **Upload:** dropzone plus "Choose a file" (PDF or saved HTML; max 20 MB, A-04), expandable "How do I get this file?" (3 steps), statement "Foods are saved to My Foods. Your diary days are not copied." (IMP-03). **Preview (desktop table, phone stacked cards):** summary tiles (found, ready, will merge, need fix), validation alert for day totals that did not match (IMP-03), table of food, serving used, calories, carbs, fat, protein and a plain-language note per row ("Ready", "Already in My Foods" with a choice (see Merge choices below), "Same food, two unit names - choose one", "Please type the serving", "Amounts differ across days - please check"); "--" is shown for not recorded (never 0); primary "Import N foods" (off until every merge row has a choice), secondary "Choose a different file". **Result:** counts (added, merged, skipped), "See the import log", primary "Go to My Foods". Admin version: banner "Saved to the public food list" and target is fixed by role (IMP-05).
**Merge choices (Q11, decided 2026-11-19: no automatic merging).** Every row whose food already exists in My Foods shows a radio pair in its last column: **"Merge with my <food>"** (your food stays; empty nutrients are filled from the file; the file's row is not added) and **"Keep both"** (the file's row is added as a second food named "<food> (MyFitnessPal)"). Nothing is selected at first. Above the table an info strip says "N foods are already in My Foods. Nothing is merged unless you say so." with a bulk button **"Merge all N"** (secondary) and a live count "1 of N chosen". **Import N foods** is disabled until every merge row has a choice, with the reason in text under the header ("Import is off until you choose Merge or Keep both for all 9 foods that are already in My Foods (1 of 9 chosen)"); N counts ready rows plus merge rows. Rows that need a fix or are skipped are not merge rows and do not block Import. Each radio pair is a fieldset with a hidden legend ("What to do with Tomato"); the choice count is a polite status region; "Merge all N" announces "All 9 set to Merge". Phone: each merge row is a card with the two radios stacked, bulk button full width, Import fixed at the bottom. The result screen counts added (including "kept both"), merged and skipped separately. Admin imports to the public list use the same per-row choice (an admin merge follows the admin merge rules, SCR-25).

| State | Behaviour |
|-------|-----------|
| Loading | "Reading your file..." with a progress bar of pages read; cancelable |
| Error: no foods | "We could not find any foods in "diary-jan.pdf". This looks like a photo or a different kind of report. Please use the Printable Diary from MyFitnessPal, saved as PDF or HTML." |
| Error: too large | "Files larger than 20 MB are too big. Pick fewer dates and try again." |
| Partial | Merge choices missing: Import disabled and the reason shown. Some rows need fixing: Import button reads "Import 56 foods" and skips flagged rows unless fixed; skipped rows listed in the log |
| Success | Result screen and toast |
| Permission denied | Admin import link hidden for users |

**Accessibility:** dropzone is a real button and file input (not drag-only); the table has row headers; flags are words; progress announced via `role="progressbar"`; results summary is focused after import.

### SCR-17 Activity
Day header with the shared date picker (CAL-07), list of activities as a single-line table (icon and name, Minutes, How hard, Calories, delete with Undo) ending in a "Total burned today" row, saved workouts chips (ACT-04), then at the bottom the "Burned today" card and weekly progress vs 150 minutes (ACT-05) (summary-at-the-bottom rule), primary "Add activity". On phone the order is the same: list, saved workouts, Burned today, This week. Add sheet: category chips (Cardio, Strength, Yoga and stretching, Sports, Daily, Other), Activity (searchable), Minutes, Distance (optional), Intensity (Light, Moderate, Hard), estimate line ("About 133 kcal burned. Worked out from your weight (62 kg) and the activity."), "I will type my own calories" switch (ACT-02). Strength shows set rows (Reps, Weight kg) and "Add a set". Custom shows Name, Minutes, Calories (required).

| Field | Validation | Error message |
|-------|-----------|---------------|
| Minutes | 1 to 1,440 | "Enter minutes between 1 and 1,440." |
| Distance | >= 0 | "Enter a distance of 0 or more." |
| Reps | 1 to 200 | "Enter reps between 1 and 200." |
| Weight | 0 to 500 kg | "Enter a weight between 0 and 500 kg." |
| Own calories | 0 to 10,000 | "Enter calories between 0 and 10,000." |

**States:** empty ("No activity yet today. A short walk counts. Tap Add activity."), loading skeleton, error, success toast. Formula (ACT-01) shown only as the plain line above; details under "How is this worked out?". **Accessibility:** tab order follows visual; switches have visible On/Off text.

### SCR-18 Friends
Tabs Friends | Requests (badge count) | Add. **Friends:** per friend card: avatar, name, @id, "View diary", "Share my food log" switch with On/Off text, expandable "Also share" checkboxes (activities, nutrition totals, weight default off, SHR-05), menu Unfriend / Block (confirm dialog "Unfriend Rohan K.? You will both stop seeing each other's diaries."). **Requests:** Accept (primary), "Not now" (secondary), Block link. On accepting, a one-line notice: "Sharing is on for this friend. You can switch it off any time." (Q12). **Add:** your own User ID with Copy (SHR-01a), exact-ID field with Find, result card with "Send request"; no match: "No user found. Check the spelling, or ask your friend to copy their User ID from their profile." Rate limit: "Too many searches. Please try again in about an hour." No partial IDs, no suggestions, no autocomplete.
**States:** Empty friends ("No friends yet. Share your User ID or add a friend by their User ID."), Empty requests ("No requests right now."), loading skeleton, error, success toast ("Request sent to Anita M."), pending state label "Request sent". **Accessibility:** switches are `role="switch"` with accessible name "Share my food log with Rohan K."; tab badge count included in the tab's accessible name ("Requests, 2 new").

### SCR-19 Friend's diary (read-only)
Info banner "You are viewing Rohan K.'s diary. You can look, react and comment, but not change anything." (A-10 wording), same meal tables as the Diary (single-line rows, no Add, Remove or Quick tools), per-meal Like and Comment, a "Shared by Rohan" chip line under the header, a bottom summary table (Totals, Daily Goal, Remaining) only when Rohan shares nutrition totals, "Copy to my diary" (LOG-16, opens SCR-12 style mapping), private meals show a lock and "Rohan chose to keep this meal private." (SHR-08),  Date navigation uses SCR-11. **States:** loading skeleton; empty ("Nothing logged on this day."); permission denied (SCR-24); error. Comments: textarea max 300 characters, "Enter a comment." / "Comments can be up to 300 characters." **Accessibility:** the read-only status is stated in text and by the page heading, not only the banner; like toggle is a button with `aria-pressed`; new comments announced politely.

### SCR-20 Settings: Profile, Security, My data
Profile: fields as in onboarding; User ID and email read-only with "This cannot be changed." (A-02); nutrition guideline select (India ICMR-NIN / General); units and time zone; photo upload (JPG/PNG up to 2 MB: "Choose a JPG or PNG smaller than 2 MB."); BMI card with category and note. Security: change password (current, new, repeat; "You will be signed out on your other devices."). My data: Download JSON, Download CSV, Delete my account (dialog, Q13 decided: **30-day grace period**). The dialog explains in plain words: "Your account is hidden right away and deleted for good after 30 days (on 18 Dec 2026). Until then nobody can see it, not even your friends. Log in again within 30 days to cancel the deletion and keep everything. After 30 days your diary, foods and friends cannot be brought back. Tip: download your data first." Then "Type your User ID to confirm", destructive "Delete my account" (disabled until it matches) and secondary "Keep my account" (initial focus). On confirm the user is signed out everywhere and a confirmation email says the date. The Security card text reads "Your account is hidden at once and deleted for good after 30 days. Log in again within 30 days to cancel the deletion." While pending, the same card shows "Deletion scheduled for 18 Dec 2026" with a "Cancel deletion" button. Primary on Profile: "Save changes" (disabled until something changes). Weight change opens the recalculation prompt (TGT-03): "Your weight changed. Update your targets?" with "Use the new suggestions" (primary) and "Keep my own targets" (secondary). **States:** loading, error ("We could not save your changes. Try again."), success toast, unsaved-changes guard ("You have changes that are not saved." Save / Leave). **Accessibility:** tabs are a `tablist`; destructive dialog focuses the cancel button first; export completion announced.

### SCR-21 Settings: Targets, Diary columns, Water, Sharing  (Diary tab drawn, others written)
```
Targets:  [Calories 1800 kcal]  (Grams | Percent)
          Carbs 262 g 58%   Fat 50 g 25%   Protein 75 g 17%   Fiber 30 g
          More limits: Sugar 22 g, Saturated fat, Sodium 2000 mg, Cholesterol  (TGT-04)
          Water 2.2 L   [Reset to recommended]  [Save targets]
Diary:    Columns to show: [x]Calories (fixed, always shown) [x]Carbs [x]Fat [x]Protein [x]Fiber [ ]Sugar [x]Sodium [ ]Sat fat [ ]Cholesterol [ ]Potassium ...   6 of 7 chosen   (default 7: Calories, Carbs, Fat, Protein, Fiber, Sugar, Sodium)
Water:    Glass 250 ml  Bottle 500 ml  Custom  | Units: ml / L / fl oz
Sharing:  Default for new friends: Share my food log [On]    Extras default: activities [ ] totals [ ] weight [ ]
```
Validation: percent total 100; more than the allowed number of columns: "You can show up to N columns. Turn one off first." (N is 7, Q17) Container size 50 to 2,000 ml. States: loading, error, success toast, disabled Save until changed.
**Diary tab (drawn, Q17, Q18):** "Columns in your diary", intro "Choose which nutrients show next to each food. Calories is always shown. You can show up to 7 columns." A two-column list of checkboxes (Calories checked, disabled, badge "Always shown"; Carbs, Fat, Protein, Fiber, Sugar, Sodium; then Saturated fat, Cholesterol, Potassium, Calcium, Iron, Vitamin C unchecked). A live status "6 of 7 columns chosen" (polite), ghost "Reset to the default 7", and a **preview** table of the Diary header with the chosen columns. At the limit (7 of 7) the unchecked boxes are disabled (muted) and an info message says "You can show up to 7 columns. Turn one off first."; turning one off enables the rest again. The default is exactly 7 (Calories, Carbs, Fat, Protein, Fiber, Sugar, Sodium), so the limit is reached from the start. Primary "Save changes" (disabled until something changes). The choice applies to every diary day of this user; a friend viewing the diary sees the columns the friend chose for their own Diary. **Phone (assumption A-23):** the stacked rows keep calories and Carbs, Fat, Protein; every chosen column appears in the day summary table. **Accessibility:** the list is a fieldset with a hidden legend "Diary columns"; disabled boxes keep their label and the reason is in the message, linked with `aria-describedby`; the count is `role="status"`.

### SCR-22 Progress
Period tabs (Week, Month, 3 months); weight chart with "Log weight" (secondary; weight 30 to 300 kg, date not in future: "Pick today or an earlier date."); calories per day vs goal (bars with text labels for over days, never colour only); water streak and weekly water chart (WAT-05); weekly activity vs 150 minutes. Empty: "Log your weight to see your trend." with an Add weight button. Every chart has a text summary and a "View as table" link. **Accessibility:** chart `role="img"` plus table alternative; colours from fixed macro and semantic tokens only.

### SCR-23 Admin console (Public Foods, Review Queue, Import logs, Users)
Admin group in the sidebar (only for role Admin). **Public Foods:** search, source filter, table (food, source badge, serving, kcal, status, actions Edit/Merge/Review), "Possible duplicate (92%)" flag, primary "Add food", secondary "Bulk upload", link to audit log (ADM-02). **Review Queue:** list on the right, detail on the left: suggested nutrients vs the closest existing food, similarity warning, "Approve and add" (primary), "Merge into ..." (secondary), "Reject" (destructive, requires a note: "Please write a short note so the user knows why."). **Import logs:** table of imports (when, file, by, saved to, added, merged, skipped, result), primary "New MyFitnessPal import". **Users:** usage tiles (active users, foods logged today, top searches with no match, ADM-04), search, table with Make admin / Deactivate / Reactivate; the own row has no actions. Make admin and Deactivate use a confirm dialog naming the person. States: loading skeleton rows, empty ("No foods suggested right now. Nice and tidy."), error, success toast, permission denied (non-admin). **Accessibility:** data tables with sortable headers announced via `aria-sort`; row action buttons have names including the row ("Edit Chapathi"); status badges are text.

### SCR-24 Permission denied / Not found / Offline
Template: icon, H1 ("Rohan K. is not sharing right now" / "We could not find that page" / "You are offline"), one sentence, one primary button back to a safe place. Friend-diary denial and not-found use the same wording for unknown and forbidden targets.

### SCR-25 Admin tools: Bulk Upload, Duplicates, Merge, Audit log (drawn, Q14)
Same site, "Admin" menu group (Public Foods, Bulk Upload, MFP Import, Review Queue, Duplicates, Users, Import logs, Audit log), admin user card, no menu Add food button. All tables use the new table style (slate header band with teal underline, zebra, single line).
**Bulk Upload** `/admin/bulk-upload`: four steps (progress bar): 1 Download template (secondary "Download CSV template", 13 columns, one example row), 2 Upload (file chosen, size and row count), 3 Check, 4 Import. Check shows tiles (rows read, ready, possible duplicates held back, errors skipped), a warning strip for duplicates ("9 rows look like foods already in the list (85% or more similar). They are not imported. Review them in Duplicates after the import."), and a preview table: Row | Name | Brand | Calories | Status (Ready, Possible duplicate 91%, Error) | What to do. Row error text is plain and says where: "Row 14: calories is missing. Add a number.", "Row 31: serving grams must be more than 0." Links: "Show only rows that need attention", "Download the 8 error rows (CSV)". Primary "Import 183 rows" (nothing is saved before it). Errors: wrong file type ("Please upload a .csv file made from the template."), over the limits (placeholders, A-04: 5 MB or 2,000 rows), missing header ("The first row must be the template header."). Success: toast and a line in the Audit log ("Bulk import, public-foods-nov.csv, 183 foods added").
**Duplicates** `/admin/duplicates`: similarity filter (85% and above by default), status "Showing 5 of 12 pairs, most similar first", table Food | Similar to | Similarity | Diary entries | actions "Review and merge" (opens Merge) and "Keep both" (asks for a short note, hides the pair). Each food cell shows name, serving and source badge. Empty: "No duplicates found."
**Merge** `/admin/duplicates/merge?a=..&b=..`: heading "Merge foods", line "Chapathi and Chapati are 96% similar. Choose the value to keep for each field." A compare table: Field | food A column | food B column | Result after the merge. Each field row has a radio in both food columns (the kept value is bold and tinted, so colour is not the only cue); fields: Name, Type, Serving, Calories, Carbs, Fat, Protein, Fiber, Sodium (more under "More fields") and a checkbox "Keep the other names of both foods". Under it: "What will happen" (entries and recipes that use the merged-away food will use the survivor; past diary days keep their numbers; the merged-away food is hidden from search and stays in the audit log) and a required **Audit note** ("Why are you merging these?", "Saved in the audit log with your name and the time."). Buttons: ghost "Cancel", primary "Merge foods" (disabled until the note is typed). Pressing it opens the confirmation dialog "Merge Chapati into Chapathi?" naming both foods and the effect, focus on "Go back", primary "Merge foods". A merge cannot be undone from the app. This follows the 85% rule of FDB-05/06 and Q10.
**Audit log** `/admin/audit`: search (person or food), Action select (All actions, Added, Edited, Merged, Approved, Rejected, Bulk import, Deleted), When select (Last 7 days, 30 days, custom), "Clear filters", "Download CSV"; status "Showing 6 of 214 changes, newest first"; table When | Who | Action | Item | Change | "View before and after". The selected row is tinted and bold and opens a Before and after table (Field | Before | After) below. Empty: "No changes match these filters." Entries are read-only.
States: empty ("No duplicates found."), loading skeleton rows, error ("We could not load this list. Try again."), success toast, permission denied (non-admin: "You don't have access to this page" with a Home button). Same table, dialog and toast patterns as SCR-23. **Accessibility:** radios in the compare table have hidden labels naming field and food ("Calories from Chapathi"); the chosen state is also bold; status badges are text; sortable headers use `aria-sort`; the confirmation is an `alertdialog`; the before-and-after link names the item ("View before and after for Dal Tadka").

### SCR-26 Notifications panel  (written wireframe)
Bell with unread count (accessible name "Notifications, 2 new"). Popover list: "Rohan K. liked your Lunch", "Anita M. commented: ..." with time; "Mark all as read". Empty: "You are all caught up." Phone: full page under More. Keyboard: Esc closes, focus returns to the bell.

### SCR-27 More (phone)
List: Friends (count), Progress, Settings, Log out. Admin users also see "Admin".

### SCR-28 Meal chooser (menu "Add food" and page-level "Add food")
```
+--------------------------------------------+
| Which meal are you adding?              [x]|
| Wed, 18 Nov 2026 - it is 7:40 pm           |
| [ Breakfast   3 foods logged       321 kcal]|
| [ Lunch       4 foods logged       710 kcal]|
| [ Snacks      2 foods logged       160 kcal]|
| [ Dinner [Fits this time of day]     0 kcal]|  <- highlighted, not chosen
| The highlighted meal is only a suggestion.  |
+--------------------------------------------+
```
Q23c decided: the menu "Add food" asks which meal first. A compact dialog (440 px, bottom sheet on phone) with four rows in the order Breakfast, Lunch, Snacks, Dinner, each showing what is logged (count and kcal for the day shown). The meal that fits the time of day (A-19: before 11:00 Breakfast, 11:00 to 15:00 Lunch, 15:00 to 18:00 Snacks, from 18:00 Dinner) is **pre-highlighted** with a 2 px brand border, a tint and a "Fits this time of day" badge, but **nothing is chosen**: the user must press a meal. Pressing a meal opens Add food for that meal and day (SCR-10). There is no primary button in the dialog; the rows are the choices. Close with the X, Esc or by clicking outside; nothing happens. **Day:** the day being viewed in the Diary, otherwise today (A-21). **Used by:** the menu button, the header "Add food" on Dashboard and Diary, "Add to diary" on a recipe, "Add your first food". **Not used by:** "Add food" links inside a meal (they go straight to that meal) and Find a food (it has its own "Add to" select).
| State | Behaviour / content |
|-------|---------------------|
| Default | As above, suggested meal highlighted |
| Loading | Meal totals show a skeleton for 300 ms or longer; rows are usable at once (totals are informative only) |
| Empty meal | "Nothing logged yet", 0 kcal |
| Error | Totals cannot load: rows still work, totals show "--" |
| Disabled | Email unverified: the menu button is disabled with the hint "Confirm your email first" (as on the Diary) |
| Permission denied | n/a |
**Accessibility:** `role="dialog"` with `aria-modal` and a title; initial focus on the highlighted meal (a visible focus ring, not selected; Enter or Space chooses it), Tab moves through the rows and the close button; focus is trapped; Esc closes and focus returns to the button that opened it; the badge is linked to its row with `aria-describedby`; rows are native buttons at least 56 px high (40 px minimum target on the website, 44 px on phone). **Responsive:** centred dialog from 768 px; bottom sheet under 768 px. **Components:** Dialog (Sheet on phone), Button.

### SCR-29 Recipe builder (FDB-12, Q15 decided: in v1)
Route `/foods/recipes/new` (edit: `/foods/recipes/<id>/edit`). Header: back link "Back to My Foods", breadcrumb, H1 "Create recipe", ghost "Cancel", **primary "Save recipe"**.
```
Desktop (1240 frame):
< Back to My Foods     My Foods / Recipes / New recipe
Create recipe                                   [Cancel] [Save recipe]
[About the recipe: name | makes N servings | one serving is called ]   [Per serving: 233 kcal, Carbs, Fat, Protein, Fiber]
Add an ingredient  [search ............ x]   Showing 2 of 6 foods matching "tomato"
  three-line result rows, Amount + Unit on the row, round +
Ingredients (5)   three-line rows, Amount + Unit editable, bin button
Nutrition: all 7 diary columns:  Per serving | Whole recipe (N servings)
```
| Field | Type | Required | Validation (when) | Error message |
|-------|------|----------|-------------------|---------------|
| Recipe name | text | Yes | 1 to 100 characters; Title Case on save; same name as another of your recipes is allowed with a warning (on blur) | "Please give the recipe a name." |
| This recipe makes (servings) | number | Yes | 0.5 to 50, steps of 0.5 (A-26) (on blur) | "Enter how many servings the recipe makes, for example 4." |
| One serving is called | text | No | 0 to 40 characters; default "1 serving" | n/a |
| Ingredient amount | number + unit select | Yes, per ingredient | More than 0 (on blur) | "Enter an amount greater than 0." |
**Behaviour:** the search is the Add food live search (300 ms, count line, three-line rows with Verified badge, nutrition for the amount and Amount and Unit controls); the round + adds the food to the ingredient list at the amount on the row (toast "Added Tomato to Veg Pulao. Undo"); an ingredient that is already in the list is added as a second line so the user sees both (A-26). Ingredient rows use the same row design; the right-hand button is a ghost bin ("Remove Salt from the recipe", Undo toast). Totals: the "Per serving" card (calories as the big number, four macros with colour dots, names written) and the "Nutrition: all 7 diary columns" table (Per serving, Whole recipe) recompute on every change, in a polite live region that announces once after typing pauses ("Veg Pulao: 233 kcal per serving"). **Save:** "Save recipe" stores the recipe in My Foods as a recipe (badge "Recipe"), toast "Saved Veg Pulao to My Foods", then opens SCR-30. Recipes appear in Add food under the **Recipes** tab and in My Foods under Recipes.
| State | Behaviour / content |
|-------|---------------------|
| Default | Filled as drawn |
| Empty | No ingredients: illustration, "No ingredients yet. Search for a food above and press + to add it.", totals show "--", Save disabled with the reason "Save is off: add at least one ingredient." (also needs a name) |
| Loading | Skeleton rows for search results; the ingredient list keeps its rows |
| Partial | An ingredient lacks a nutrient: its cell shows "--" and the total gets an "incomplete" marker with a tooltip (LOG-UI-11) |
| Error | "We could not save this recipe. Your ingredients are still here. Try again." |
| Success | Toast and redirect to the detail |
| Unsaved changes | Guard on Cancel or Back: "You have changes that are not saved." Save / Leave |
| Permission denied | n/a (own recipes) |
**Phone:** one column; details card, per-serving summary card, search, ingredient rows (amount on the row), primary "Save recipe" fixed at the bottom; the 7-column table becomes the same list as the saved recipe (SCR-30). **Accessibility:** labels above every field; hints linked; each + and bin has a name that includes food and recipe; the totals region is `aria-live="polite"` with the announcement debounced; the ingredient list is a list with a count in its heading. **Components:** Card, Form (react-hook-form + Zod), Input, Select, the Add food row, Table, Alert, Sonner toast.

### SCR-30 Recipe detail
Route `/foods/recipes/<id>`. Title with a "Recipe" badge, line "Makes 4 servings - 1 serving = 1 katori (about 250 g) - saved to My Foods on 18 Nov 2026", buttons: **primary "Add to diary"** (opens the meal chooser, SCR-28, then Add food with the recipe selected), secondary "Edit recipe", ghost "Delete". A table of ingredients (Ingredient | Amount | Calories | Carbs | Fat | Protein | Fiber | Sugar | Sodium) with total rows "Whole recipe (4 servings)" and "Per serving". Hint: editing a recipe never changes past diary days. Delete uses the dialog "Delete Veg Pulao? Past diary days keep their numbers." **States:** loading skeleton; error; success toast; permission denied (not the owner: "We could not find that recipe." same as not found). **Phone:** per-serving card, ingredient list with kcal, Add to diary first. **Accessibility:** table caption "Ingredients and nutrition of Veg Pulao", row header column, total rows labelled.

### SCR-31 Deletion scheduled banner (Q13)
After the user logs in again within the 30 days, the first screen (Home) shows a warning banner (`role="alert"`) at the top: "Your account is scheduled for deletion on 18 Dec 2026." with text "You asked us to delete it on 18 Nov 2026. Until 18 Dec your account is hidden from your friends and all your data is still here. Choose Cancel deletion to keep your account. Choose Continue to go on and let the deletion happen." Buttons: **primary "Cancel deletion"**, secondary **"Continue"**. On this first screen the banner owns the one primary button (the page's own "Add food" button is not shown). Cancel deletion: account is visible again, toast "Deletion cancelled. Welcome back, Priya." Continue: the banner closes for this visit, the deletion date stays, and the banner returns at the next login and as a card in Settings, Security and my data until the date. After the date the account and its data are deleted (a reminder email goes out 3 days before; A-27). Open question Q25 asks whether logging in should cancel automatically instead. **Accessibility:** focus moves to the banner heading on load; both buttons are reachable first in the tab order; the date is written in words. **Phone:** the banner is a card at the top of Home with two full-width buttons.


## 7. Design Tokens / System Usage

One system, defined once in the HTML as CSS variables and shown in its section 0. The product build maps these to shadcn/ui theme variables (A-11). Anything not in this list is not allowed in the UI.

**Typography (one family, four sizes, three weights)**

| Token | Value | Use |
|-------|-------|-----|
| Font | Inter (Google Fonts), system fallback | Everything; numbers use tabular figures |
| `--fs-h1` | 24 px, bold 700, line height 1.25 | Page title, big numbers (calories left) |
| `--fs-h2` | 18 px, semibold 600, line height 1.25 | Card titles, subheadings, sheet titles |
| `--fs-body` | 14 px, regular 400 (semibold 600 for emphasis), line height 1.5 | Body, inputs, buttons, table cells, food names |
| `--fs-small` | 12 px, regular or semibold | Captions, hints, badges, table headers, helper and error text, food-row detail line |

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64 (`--s1` to `--s8`). Card padding 16. Gap between cards and between form fields 16. Gap inside a card 12. Page padding 16 on phone and 24 on desktop. Section spacing 48. Tap target height: 44 on phone (`--tap`), 40 on the website (`--tap` is 40 inside website frames).

**Shape and depth:** one radius 12 px (cards, buttons, inputs, sheets); full radius only for pills, switches, rings. One shadow `0 4px 24px rgba(15,23,42,.08)`. One glass style: surface at 80% opacity with a 12 px blur and a 1 px border, readability first (Q1 notes the move from the heavier glass in section 12 of the requirements).

**Colour tokens** (light and dark values defined; dark follows `prefers-color-scheme`)

| Group | Token | Light | Dark |
|-------|-------|-------|------|
| Brand | `--brand` / hover / on-brand | #0f766e / #115e59 / #ffffff | #2dd4bf / #5eead4 / #042f2e |
| Brand ink (links, outline and ghost button text, focus ring) | `--brand-ink` | #0f766e | #2dd4bf |
| Logo and ring gradient (decorative only) | `--logo-a` `--logo-b` `--logo-ink` | #0d9488, #0f766e, #ffffff | #2dd4bf, #14b8a6, #042f2e |
| Neutrals | `--bg` `--surface` `--surface-solid` `--surface-2` `--border` | #f6f8fb, white at 80%, #ffffff, #eef2f6, #d7dee7 | #0b1220, #131c2e at 78%, #131c2e, #1b2740, #2d3b55 |
| Input and outline-button border | `--field-border` | #64748b (4.8:1) | #7d8ca5 (5.0:1) |
| Text | `--text` / `--text-2` | #0f172a / #475569 | #f1f5f9 / #b6c2d4 |
| Status (words always shown) | `--success` `--warning` `--error` | #14703a, #8a5a00, #a8102a | #4ade80, #fbbf24, #f87171 |
| Macros (dots, bars and header underlines only; never text colour) | `--carbs` `--fat` `--protein` `--fiber` | #2563eb, #c2410c, #3b1a85, #c026d3 | #8ec5fc, #fb923c, #8160f6, #f472d0 |
| Side menu | `--nav-bg` / `--nav-text` / `--nav-muted` | #f1f5f9 / #1e293b / #526277 | #0f172a / #e2e8f0 / #9aa8bd |
| | `--nav-active-bg` / `--nav-active-text` / `--nav-bar` | #d3efec / #0b4a45 / #0f766e | #134e4a / #ccfbf1 / #2dd4bf |
| | `--nav-cta-bg` / `--nav-cta-text` / `--nav-border` | #0f766e / #ffffff / #d7dee7 | #2dd4bf / #042f2e / #2d3b55 |
| Tables | `--th-bg` / `--th-text` / `--th-line` | #1e293b / #f8fafc / #2dd4bf | #26354f / #f8fafc / #2dd4bf |
| | `--band-bg` (meal band, group rows) | #e4f2f1 | #123a3a |
| | `--zebra`, `--row-hover`, `--foot-bg` | rgba(15,23,42,.035), rgba(15,118,110,.07), #edf1f6 | rgba(255,255,255,.04), rgba(45,212,191,.10), #1b2740 |

Palette B "Calm Teal" (chosen 2026-11-19 from `wireframes/palette-options.html`, which holds the full token table and every calculated contrast result) replaces the round 4 green palette. The old `--accent-green`, `--accent-blue`, `--nav-top`, `--nav-bot`, `--nav-fill`, `--nav-fill-2`, `--nav-outline`, `--nav-divider` and `--nav-hover` tokens are removed. New tokens: `--brand-ink`, `--field-border`, `--logo-a/-b/-ink`, `--nav-bar`, `--nav-cta-*`, `--nav-border`, `--th-line`. The macro colours protein (#7c3aed to #3b1a85) and fiber (#0f766e to #c026d3) changed because teal is now the brand. The success, warning and error values are darker than before so they pass 4.5:1 on tinted badges and the Remaining row.

Brand note: the requirements (12.1) ask for a green-to-blue gradient on primary buttons. White text on a light gradient end fails AA, so primary buttons are solid deep teal and the gradient (`--logo-a` to `--logo-b`) is kept for the logo mark and the progress ring; the selected calendar day uses a brand to brand-hover gradient with on-brand text (Q1).

**Components (shadcn/ui mapping, A-11):** Button (four variants only: `default`=primary, `outline`=secondary, `ghost`, `destructive`; one size, 40 px website / 44 px phone; the side-menu "Add food" is a default-variant Button with the nav CTA tokens (not a fifth variant); the round + quick-add is `outline` with `size="icon"` and a full radius), Input, Textarea, Select, Checkbox, RadioGroup, Switch, Tabs, Card, Badge, Alert, Dialog, Sheet (bottom on phone, for the calendar and confirmations only; never for choosing a food), Popover and DropdownMenu, Calendar (custom three-level wrapper), Table / Data Table, Progress, Skeleton, Sonner toast, Tooltip, Command is not used for food search any more (the live search is a page: Input with `type="search"` plus a plain list of food rows), Form (react-hook-form + Zod for the validation messages in section 6). Reuse blocks: login, sidebar (section 4.2), dashboard. Custom: food row (three lines, quick-add) and food table pattern (below), items list, calorie ring, macro donut, water card, source badge, parse review list, Calendar drill-down, friend diary banner.

**Table and food-row pattern (structure only, Nutrelia branding).** Round 4: tables get the meal band, slate header band, zebra rows and bold total rows (global rule "Table style"); search results use the three-line food row (SCR-10). Where the older text below says "result rows 48 px" or "3 px line on the column header", the round 4 rules win (food rows about 72 to 84 px; macro dot plus 3 px line). The diary table (Food then nutrient columns, header row per meal, Add food link, subtotal row, and a Totals / Your Daily Goal / Exercise / Remaining block under the same columns) and the search result row (bold name, muted "source · serving · calories", calories on the right, hover and selected states) follow the structure people know from established food-diary apps. This is a layout convention only: no other product's name, logo, colours or artwork are used, and everything is drawn with the Nutrelia tokens above. Row heights: table rows 40 px, result rows 48 px minimum. Macro colours appear as a dot and a 3 px line on the column header with the name written out. **Table rule:** see the "Table rule (single line)" row in the global rules (section 6): no wrapping, truncate with tooltip, right-aligned numbers, scroll wrapper per table.

**Source badges** (LOG-SRC): one neutral style with text always shown (Nutrelia and its seeded foods use the brand tint, all others neutral). The requirement for a different colour per origin (LOG-SRC-05) is not applied because it would add six one-off colours (Q3).

**Icons:** one set (Lucide, as shipped with shadcn/ui), 20 px, 2 px stroke, always with a text label nearby or an accessible name.

**Motion:** 200 to 300 ms ease-out; ring fill and count-up; cards do not lift on hover (kept calm). All off under `prefers-reduced-motion`.

## 8. Accessibility Requirements (WCAG 2.2 AA), project-wide

REQUIREMENTS NFR-05 says WCAG 2.1 AA; this spec targets 2.2 AA, which includes 2.1 (A-12).

| Area | Rule |
|------|------|
| Contrast | Calculated for palette B (full table in `wireframes/palette-options.html`), light / dark: body text 16.7 / 14.0:1; secondary text 7.1 / 8.5:1; link and secondary button text 5.1 / 8.3:1; primary button text 5.5 / 7.8:1; menu text 13.4 / 14.5:1, menu group labels 5.7 / 7.4:1, active item 8.3 / 8.4:1, menu Add food text 5.5 / 7.8:1; table header text 14.0 / 11.8:1; meal band text 15.5 / 11.3:1; Remaining under 5.0 / 7.3:1, slightly over 4.9 / 7.6:1, well over 5.9 / 5.1:1; input border 4.8 / 5.0:1 (3:1 needed); focus ring 5.5 / 9.2:1; macro dots, bars and underlines 4.4 or more (3:1 needed); logo glyph 3.7 / 5.8:1 (non-text). Macro colours are never used for text. Text on glass over the background blobs: test the worst case (surface is 80% opaque). Token values are expected to pass and must be verified with an automated scan (axe) and a manual check in both themes. Warning text on tinted backgrounds is the tightest case. |
| Colour is never the only cue | Over/under target, status, macro identity (name next to the colour), source (text), calendar markers (dot plus outline plus fill), chart days (text label). |
| Keyboard | Everything operable by keyboard; logical tab order; skip link "Skip to main content"; visible focus ring 3 px (2.4.7, 2.4.11 focus not obscured: sticky headers and the pinned summary use scroll padding so focus is never hidden); calendar arrow keys, Enter, Esc (CAL-06). |
| Target size | 44 px on phone and 40 px on the website for buttons, inputs, tabs and switches (both above the 24 px minimum of 2.5.8). Table icon buttons are 40 px on the website. |
| Dragging | The upload dropzone also has a button (2.5.7); no feature needs drag. |
| Focus management | Dialogs and sheets trap focus, set initial focus (first field, or the cancel button for destructive dialogs), `Esc` closes, focus returns to the trigger. On route change focus moves to the page H1 and the title updates. After delete, focus moves to the next row. |
| Forms | Visible label above every input; hints linked with `aria-describedby`; errors linked and announced (`role="alert"` on summary, inline error per field); no placeholder-only labels; `autocomplete` attributes; do not ask for the same data twice in one flow (3.3.7: use Back with values kept); no cognitive tests (3.3.8: password managers and paste allowed). |
| Live search | Search results are a plain list of rows; each row's controls are reached with Tab in this order: Servings, Serving size, + (a tick box first in Select several mode); every + has a descriptive `aria-label` ("Add Chapathi (whole wheat) to Dinner"); a debounced polite `role="status"` line announces "Showing N of M foods matching ..." or "No foods match ..."; filter changes are announced the same way; focus is never moved by an update. |
| Screen readers | Landmarks (header, nav, main); tables with captions and header cells; icon buttons named; progress rings and bars expose name, value, max; toasts and parse status in polite live regions; loading regions `aria-busy`. |
| Motion | `prefers-reduced-motion` turns off ring fill, count-up, skeleton shimmer, sheet slide. No auto-playing content. |
| Zoom and reflow | Usable at 200% zoom and 320 px width without horizontal scrolling; body text is 14 px (12 px small text is never the only carrier of key information); text spacing overrides do not clip; single-line table cells scroll inside their wrapper at zoom instead of wrapping. |
| Language and time | `lang="en"`, dates written with the month name ("18 Nov 2026"), no time limits except the 5 s Undo (pauses on hover or focus, A-07) and link expiries which are stated in text. |
| Auth | Login and reset pages allow password managers; lock-out message explains the wait. |

## 9. FR to Screen Coverage

| FR / NFR | Screens | Journeys |
|----------|---------|----------|
| AUTH-01, 02, 03, 10 | SCR-02, 03 | UJ-01 |
| AUTH-04, 05, 06, 07, 11 | SCR-04, 05, 20 | UJ-09, 10 |
| AUTH-08 (COULD) | Not designed (Sign in with Google slot reserved under Log in) | n/a |
| AUTH-09 | SCR-20, 31 (30-day deletion grace) | UJ-09 |
| PROF fields, PROF-01, 03, 04 | SCR-02, 06, 20 | UJ-01, 09 |
| PROF-02 | SCR-08, 22 | UJ-12 |
| TGT-01, 02, 03, 05 | SCR-07, 20, 21 | UJ-01, 09 |
| TGT-04 | SCR-21, 09 ("View all nutrients") | UJ-03 |
| UI-CAP-01 to 03 | All food and name displays; SCR-06, 15 | all |
| FDB-01 to 06, 09, 11 | SCR-15, 14, 23, 25 | UJ-05, 11 |
| FDB-07, 08 (data setup, not user-facing) | n/a (surfaces as source badges and search tiers: SCR-13) | UJ-05 |
| FDB-10 | SCR-14, 23 | UJ-05, 11 |
| FDB-12 (Recipes, in v1 by decision Q15) | SCR-29, 30, 14, 10 (Recipes tab) | UJ-13 |
| IMP-01 to 06 | SCR-16 (merge choices), 23 | UJ-06, 11 |
| LOG-01 to 06 | SCR-09 (summary at the bottom), SCR-17 | UJ-03 |
| LOG-07 to 13 | SCR-10 (full page; SCR-13 uses the same page), SCR-28 (meal chooser) | UJ-02, 05 |
| LOG-14, 15 | SCR-12 | UJ-04 |
| LOG-16 | SCR-19 | UJ-08 |
| CAL-01 to 07 | SCR-11 (and SCR-12, 17, 19) | UJ-04 |
| LOG-SRC-01 to 05 | SCR-09, 10, 13, 14, 15, 19 | UJ-02, 05 |
| LOG-UI-01 to 14 | SCR-09, 21 (Diary columns tab, up to 7; LOG-UI-01 shows 7 nutrient columns by default, Q17; LOG-UI-14 reduced to a slim bar) | UJ-03 |
| WAT-01 to 06 | SCR-09, 08, 21, 22 | UJ-03, 12 |
| WAT-07 (COULD) | Not designed | n/a |
| ACT-01 to 05 | SCR-17, 08, 22 | UJ-07 |
| SHR-01 to 09 | SCR-18, 19, 26 | UJ-08 |
| ADM-01 to 04 | SCR-23, 25 (Bulk Upload, Duplicates, Merge, Audit log drawn) | UJ-11 |
| NFR-01, 02 | SCR-10, 13 (skeleton, partial failure) | UJ-02, 05 |
| NFR-05, 06 | Sections 7 and 8; every screen | all |
| NFR-10 | All copy is in this spec so it can move to one string file | all |
| Section 12.3 PWA / install | Install prompt and offline banner: see global rules; no dedicated screen (Q16) | all |

Not user-facing, no screen: AUTH-03 link email content (an email template, copy to be written by the product-owner), NFR-03, 04, 07, 08, 09, section 10 data model.

## 10. Usability Risks & Validation Plan

| Risk | Why | Mitigation in the design |
|------|-----|--------------------------|
| Users do not trust parsed results | Free text can match the wrong food | Review step shows what was understood and the source badge; remembered choices; easy Undo |
| Source badge text overwhelms rows (longest: "MyFitnessPal to Nutrelia - Edited") | LOG-SRC wording | Shortened form on phone with tooltip; Q3, Q9 |
| Four-tab plus More navigation hides Friends and Progress | Q2 | Badge on More for friend requests; test discoverability |
| Free-text examples teach slowly | Users type full sentences | Placeholder and hint show comma and quantity; test with 5 first-time users |
| Targets look "wrong" to Indian users | Guideline wording | Transparent "How we worked this out"; editable; Q5 |
| Import preview too technical | Flags like "per-unit values differ" | Plain wording per flag; fix-in-place; test with the owner's real exports |
| Live search feels jumpy or noisy for screen reader users | Results update on typing | 300 ms pause, previous results stay until new ones arrive, one debounced announcement; test with a screen reader (Task: find Chapathi) |
| Eight diary columns are too wide for small laptops | Single-line rule | Scroll wrapper, first column kept, user can hide columns (Q17, Q18); test at 1024 px |
| Quick-add + is too easy: users add the wrong serving without noticing | + adds at the amount shown on the row, with no confirmation | The row shows the amount and calories right next to +; toast with Undo and the "Added" state; Q21; test: 5 users add "Chapathi 2" and say what was added |
| Compact Servings and Serving size controls (28 px) are hard to hit or read | Three lines in 72 to 84 px | Visible labels, 8 px spacing, 44 px on phone; test with 5 users on a laptop |
| Users still look for a detail view | Old habit from the panel layout | The page hint says every row shows its calories and nutrients; test: "How much protein is in Dal Tadka?" without clicking |
| Privacy surprise: sharing defaults to ON | Requirement says ON | One-line notice on accept; Q12 |

**Usability test plan** (5 to 8 participants, phone first, include 2 first-time non-technical users). Tasks and success measures:

| Task | Success measure |
|------|-----------------|
| Create an account and finish onboarding | Done in under 2 minutes, no help, 0 errors that block |
| Log "Chapathi 2, Dal 1 cup" for Lunch | Done in under 30 s; 90% understand the items list and final check without help |
| Add "Chapathi" to Dinner with the + on the row, then undo it | 90% under 20 s; 100% notice the toast and Undo |
| Say the protein in Dal Tadka and Dal Makhani without opening anything | 90% read it from the rows within 10 s |
| Narrow a food search by editing the text and the Source filter | 90% see the list change without looking for a Search button |
| Resolve an ambiguous food and a not-found food | 80% complete unaided |
| Find how many calories are left today | 100% in under 5 s |
| Copy yesterday's Breakfast to today | 90% under 20 s |
| Log 30 minutes of brisk walking | 90% under 40 s |
| Invite a friend by User ID, then switch sharing off | 80% unaided; 100% can say who can see their diary |
| Import a MyFitnessPal PDF and fix one flagged row | 80% complete; no one imports blindly |
| Read-aloud check: "what does this label mean?" for source badges | 70% describe it correctly |
| Screen reader and keyboard-only run of Log in, Add food, Diary | 0 blockers |

## 11. Open Questions and Assumptions

**Open questions** (owner Santhosh, needed before G2; the same list with options is in `review-notes.md`)

| ID | Question | Needed by |
|----|----------|-----------|
| Q1 to Q23 | **Answered 2026-11-19**, see "Decisions (Santhosh, 2026-11-19)" in `review-notes.md`. Round 5 designs the changed answers: Q11 (merge confirmation), Q13 (30-day grace), Q14 (admin tools), Q15 (recipes), Q17 and Q18 (7 columns, user choice), Q19 (no header search), Q23a to Q23c (palette B, Settings in the user card, meal chooser). | Done |
| Q24 | On the Diary and Dashboard the page-level "Add food" primary and the menu "Add food" button both open the same meal chooser. Keep both, or drop the page-level button on those two screens? | G2 |
| Q25 | The decision says logging in within 30 days cancels the deletion; the brief also asks for a banner with "Cancel deletion" and "Continue". Drawn: logging in does not cancel by itself; the user chooses on the banner. Confirm, or make login cancel automatically (banner becomes "Welcome back, deletion cancelled" with Undo). | G2 |
| Q26 | Import wording and effect: "Merge with my <food>" keeps your food and fills empty nutrients from the file; "Keep both" adds "<food> (MyFitnessPal)". Confirm the effect and the names. | G2 |
| Q27 | When a food used in a recipe is edited or merged by an admin, does the recipe use the new values (drawn: yes, past diary days never change)? Alternative: recipes keep a snapshot. | G3 |
| Q28 | On phone, do the chosen diary columns appear only in the day summary (drawn, A-23), or should the user pick which two extra values show on each food row? | G3 |
| Q16 | PWA: decided read-only offline for the current day (A-06). | Done |

**Assumptions**

| ID | Assumption |
|----|-----------|
| A-01 | Persona ages and habits are illustrative, to be validated. |
| A-02 | User ID and email cannot be changed after signup (requirements do not say). |
| A-03 | The "How we worked this out" explanation uses the formulas in REQUIREMENTS 3.3 once the dietitian config exists. |
| A-04 | Numeric limits (height, weight, calories, file size 20 MB, 30 items per entry, text lengths) are placeholders to confirm with the architect and product manager. |
| A-05 | Diet preference ranks results and never hides them. |
| A-06 | Offline mode in v1 is read-only for the current diary day (PWA is required; offline writes are not specified). |
| A-07 | Undo toast timer pauses on hover or keyboard focus. |
| A-08 | Keyboard shortcuts are optional extras, never the only way. |
| A-09 | "Clear meal" uses the Undo toast rather than a dialog for consistency. |
| A-10 | Friend viewer wording and the "Shared by" card are new copy. |
| A-11 | shadcn/ui, Tailwind and Framer Motion are used per `UI_LIBRARY` and REQUIREMENTS 2.3. This spec only names components; architecture is not decided here. |
| A-12 | Accessibility target is WCAG 2.2 AA (stricter than NFR-05's 2.1 AA). |
| A-14 | Protein and fiber are minimum targets: going over is shown as "Goal met", not as a warning (the over-target colours in LOG-UI-08 apply to calories, carbs, fat and sugar). To confirm. |
| A-15 | In the sample data, target numbers (1,800 kcal etc.) are illustrative and not computed from the sample profile; they must be replaced by real formula output in build. |
| A-16 | Live search waits about 300 ms after the last keystroke; first page 20 rows with "Show more results". |
| A-17 | Wide tables keep the first column visible while scrolling sideways (sticky) in the build. |
| A-18 | Sodium goal 2,300 mg and Rohan K.'s goals in the samples are illustrative only. |
| A-19 | The meal chooser (SCR-28) pre-highlights, and the "Add to" select on Find a food defaults to, the meal that fits the time of day (before 11:00 Breakfast, 11:00 to 15:00 Lunch, 15:00 to 18:00 Snacks, after 18:00 Dinner) unless a meal is chosen; the user can change the "Add to" select. |
| A-20 | In the several-items layout, + on a row means "use this food for this item"; the actual logging happens with "Add N foods". |
| A-21 | The meal chooser applies to the day being viewed in the Diary, otherwise to today; it shows that day's per-meal calories. |
| A-22 | The meal chooser highlight does not use history (for example "you usually log lunch late"); it is the time rule only. |
| A-23 | On phone the user's chosen diary columns appear in the day summary table; the stacked food rows keep calories and Carbs, Fat, Protein (Q28). |
| A-24 | "Merge all N" in the import sets every merge row to "Merge with my <food>"; the user can still change single rows afterwards. |
| A-25 | Admin Bulk Upload limits (5 MB, 2,000 rows) and the 85% similarity cut-off for held-back rows are placeholders (A-04, Q10). |
| A-26 | Recipe servings are 0.5 to 50 in steps of 0.5; the same food added twice shows as two lines; recipe totals are recomputed from the ingredients when the recipe is opened (Q27). |
| A-27 | A reminder email is sent 3 days before a scheduled account deletion. Wording to be written by the product-owner. |
| A-13 | The sugar limit shown in the sample diary (22 g) is the ICMR "added sugar under 5% of calories" value applied to total sugar because food data only stores total sugar (Q6). |

**Issues for other roles**
- product-manager: NFR-05 says WCAG 2.1 AA; recommend 2.2 AA. Section 12.2 gradient buttons fail contrast (Q1). LOG-SRC-05 per-origin colours conflict with the single-palette direction (Q3).
- solution-architect: feasibility check for Calendar drill-down on a bottom sheet, offline diary, and the 3-second external search timeout with partial results. Round 3 adds: a live search endpoint that returns counts per source and tab for the current text (for "Showing N of M" and the Source filter counts), request cancellation for the 300 ms debounced typing, and search state in the URL.
- product-manager: round 3 changes the requirements text in places: LOG-UI-01/02 (6 default columns, up to 6) vs 7 nutrient columns shown now (Q17, Q18); LOG-UI-14 (pinned summary) reduced to a slim bar with the full summary at the bottom; LOG-07 to 13 describe the "free-text box" and review as steps, now a full page instead of a dialog or sheet; type scale 24/18/14/12 px replaces the larger scale. Please update REQUIREMENTS.md and log the change.
- solution-architect (round 4): rows need per-food nutrition for the default serving and a way to recompute a row from Servings and Serving size without a round trip (client-side from per-100 g values and unit weights), a quick-add endpoint that returns an undo token, and search results that include the macros for every row (the detail-panel fetch is gone). Please confirm feasibility within NFR-01.
- product-manager (round 4): LOG-09 and LOG-10 describe choosing a food and then setting servings; the new flow sets servings on the row and adds with one press. Please confirm the wording of those requirements and log the change.
- product-manager (round 5): REQUIREMENTS.md must reflect the 2026-11-19 decisions: LOG-UI-01/02 (7 default, maximum 7), FDB-12 now in v1 scope, AUTH-09 / PROF delete with a 30-day grace period (and what the friends see in that time), IMP-0x per-row merge confirmation, LOG-07 menu Add food asks for the meal first, palette B tokens. Please log them in the decision log.
- solution-architect (round 5): feasibility of soft-delete with a 30-day purge job and the "hidden from friends" rule, recipe nutrition recomputed from ingredients (Q27), admin merge that repoints diary entries and recipes while past diary days keep snapshots, bulk upload validation preview without writing, and the audit log before and after storage.

- business-analyst: confirm whether user ID and email are editable and what happens to friends if a User ID changes.
