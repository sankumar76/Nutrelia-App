# UX Review Notes for Santhosh

Open `docs/03-ux/wireframes/nutrelia-screens.html` in a browser (it follows your device's light or dark setting). Tags like Q3 in the page match the numbers below. Full detail is in `docs/03-ux/ux-spec.md`.

## Design-system decisions (from your latest direction)

- Four text sizes only (24 / 18 / 14 / 12 px, reduced in round 3), one font (Inter), three weights. Body is 14 px, line height 1.5; headings 1.25.
- One spacing scale (4, 8, 12, 16, 24, 32, 48, 64). Card padding, field gaps and card gaps are the same on every screen.
- Four button types only (primary, secondary, ghost, destructive), one size: 40 px tall on the website, 44 px on phone. One primary button per screen.
- One palette with light and dark values. Macro colours are fixed: carbs blue, fat orange, protein purple, fiber teal, always with the name written next to them.
- One 12 px corner radius, one shadow, one subtle glass card style, one icon style.
- Plain-language labels, example hints ("Chapathi 2, Dal 1 cup"), friendly empty states, step progress bars in onboarding and import, bottom navigation with icons and labels on phones.
- A "0. Design system" section at the top of the HTML shows all of this.

## Review order and responsive decision (recorded)

- **Review order:** website (desktop) screens first. Every section of the HTML now shows its desktop frames first, labelled "Website: ...". The phone frames are kept, collapsed under each section as "Mobile version (for later review)".
- **Decision (Santhosh): the site must be responsive on any device.** No separate tablet mock-ups. Rules (full text in `ux-spec.md` section 4.1): layouts stretch smoothly; below 768 px phone layout with bottom bar; from 768 px a collapsible left-hand menu; from 1024 px the full desktop layout. Test widths: 360, 768, 1024 and 1440 px. The phone bottom bar stays as proposed in Q2 unless he says otherwise.
- Sample numbers (1,800 kcal etc.) are illustrative, not computed from the sample profile.
- Protein and fiber are treated as minimum targets: going over shows "Goal met" (assumption A-14).

## Decisions to confirm or choose

1. **Button colour (Q1).** Requirements ask for gradient primary buttons, but white text on the green end fails accessibility contrast. Proposal: solid green primary buttons; keep the green-blue gradient for the logo, progress rings, selected calendar day and glow. Alternative: gradient with dark text (looks less premium).
2. **Phone navigation (Q2).** Requirements list 7 tabs; a phone bar fits 5. Proposal: Home, Diary, Activity, Foods, More (Friends, Progress, Settings inside More). Alternative: swap Foods for Friends.
3. **Source badge colours (Q3).** Requirements want a different colour per source (7 colours). Proposal: one neutral badge style with the source always in text (Nutrelia gets a green tint), to keep one palette. Alternative: keep 7 colours.
4. **Targets screen (Q4).** Step 4 shows targets in grams by default with a Grams/Percent switch, and "Reset to recommended". Confirm grams as the default, and that water (2.2 L) appears there.
5. **Target wording (Q5).** The screen says "Indian (ICMR-NIN) guidelines" with a "How we worked this out" link. Confirm you want the formula explained to users, and whether to use the Indian BMR equations (open in the requirements).
6. **Sugar limit (Q6).** The requirement is "added sugar under 5% of calories" but food data stores total sugar only, so the diary compares total sugar to 22 g and shows "1 g over". Confirm that, or show sugar without a limit.
7. **Add food check (Q7).** On the new Add food page the "Add N foods" button waits until every typed item is resolved, with a ghost button "Add only the matched foods". Alternative: save matched items immediately and resolve the rest later.
8. **Date of birth at sign-up (Q8).** Asked on the register screen (so under-18s are blocked before anything is saved, PROF-04). Alternative: ask it in onboarding step 1 (shorter register form, but data is stored first).
9. **Badge length on phones (Q9).** Long source paths ("MyFitnessPal to Nutrelia - Edited") get shortened with a tap-for-detail tooltip. Also confirm 3 seconds as the wait for external databases before showing partial results (the Add food page shows what it has and a notice).
10. **Food editor rules (Q10).** Calorie check warns when numbers differ by more than 15% (user can still save); admins must merge or rename on a 85%+ similar match, as per FDB-05/06. Confirm.
11. **MyFitnessPal import (Q11).** Foods already in My Foods merge automatically (shown in the preview); unclear servings must be typed or the row is skipped. Confirm automatic merge is acceptable for users (admin merge uses the same rules).
12. **Sharing default (Q12).** Sharing is ON when a request is accepted (your decision). I added one line on the accept screen: "Sharing is on for this friend. You can switch it off any time." Confirm the notice, or ask for a one-time choice instead.
13. **Delete account (Q13).** Requires typing the User ID, with a reminder to download data first. Confirm, and whether deletion is immediate or has a grace period (not in the requirements).
14. **Admin area (Q14).** Admin is a separate sidebar group inside the same app (not a separate site). Bulk Upload, Duplicates, Merge and Audit log are written in the spec but not drawn in the HTML.
15. **Recipes (Q15).** FDB-12 (SHOULD) is not drawn; only an entry point is reserved. Include in v1 design?
16. **PWA (Q16).** Install prompt and offline behaviour are not drawn. Is read-only offline for the current day enough for v1?

## Other things to look at
- Is "calories left" the right big number on Home and Diary?
- Does the items list on the Add food page (matched, please choose, not found) feel clear to a first-time user?
- Is 14 px body text (12 px small text) now the right size?
- Are the eight diary columns (Food plus seven nutrients) too wide at 1024 px? (Q17)
- Accessibility target is WCAG 2.2 AA (the requirements say 2.1 AA).
17. **Diary columns by default (Q17).** The diary now shows Food plus Calories, Carbs, Fat, Protein, Fiber, Sugar and Sodium (7 nutrient columns, your list). The requirements say 6 by default and at most 6 (LOG-UI-01, LOG-UI-02). Confirm 7 as the default and the maximum.
18. **Choose columns (Q18).** Can users switch columns on and off in Settings, Diary (LOG-UI-02)? Proposal: yes, Calories fixed, the rest optional, maximum as decided in Q17.
19. **Live search details (Q19).** Assumed: the list updates about 300 ms after the last keystroke, 20 rows at a time with "Show more results". Confirm, and say whether the header should also get a quick food search box.
20. **Dashboard summary (Q20).** The Dashboard has no food list, so its calories ring and nutrient bars stay where they are. Only screens with a list (Diary, Activity, friend's diary) moved the summary to the bottom. Confirm.

## Round 3 changes (Santhosh review, 2026-11-18)

1. **Smaller text.** Type scale is now 24 / 18 / 14 / 12 px (was 28 / 20 / 16 / 14), body line height 1.5, headings 1.25. Website buttons and inputs are 40 px tall; phone frames keep 44 px. Section 0 of the HTML and the spec section 7 are updated; no old pixel values remain in the HTML (see the hand-off for what was replaced).
2. **Every table on one line.** No cell or header wraps; numbers right-aligned; long food names end in "..." with the full name on hover; every table sits in its own scroll box so only the table scrolls, never the page. Headers shortened ("Carbs (g)", "Protein (g)", "Sodium (mg)"). Written as a global rule in the spec.
3. **Summary at the bottom.** Diary: the "Today so far" column is gone; Totals, Your Daily Goal, Exercise and Remaining now sit under the same columns below the meals, followed by ring, donut, water and notes. The header keeps one slim "742 kcal left" line. Same for Activity (total row plus Burned today and This week below the list) and the friend's diary. Phone: slim bar on top, summary table at the bottom. Remaining is green under, amber up to 10% over, red beyond, always with words (LOG-UI-08; you asked for green and red, I kept the existing amber step, say if you want only two colours).
4. **Add food is a full page.** No pop-up or bottom sheet. Back link, title "Add food to Dinner - Wed, 18 Nov 2026", a pre-filled editable search that filters live (no Search button, count line, highlighted matches, clear button), tabs All / Recent / Frequent / My Foods / Meals, an Excel-style Source filter, a filter-applied state and an empty-filter state. Several typed items show as a left list (matched, please choose, not found) with the live search for the selected item on the right. The amount (servings, serving size, nutrition preview) is on the page, then "Add to Dinner". Website and phone frames updated (type, check, choose, not found, final check). Other dialogs (delete, copy day) stay dialogs. Q7 and Q9 now refer to this page.
5. **Familiar food-list look (structure only).** Search rows: bold name, then "source · serving · calories" in small muted text, calories on the right, small Verified badge, hover and selected states. Diary meals are tables: Food, Calories, Carbs, Fat, Protein, Fiber, Sugar, Sodium, with an Add food link and a subtotal row under each meal. Macro colours are a thin line on the column headers. Same row style in My Foods, Find a food and the friend's diary. Nutrelia colours, type and badges only; nothing from any other brand.
6. **New questions:** Q17 default columns, Q18 user-chosen columns, Q19 live-search details, Q20 Dashboard unchanged.

## Round 4 changes (Santhosh review, 2026-11-18)

1. **Side menu redesigned (every website frame, user and admin).** Solid deep-green surface with a soft top-to-bottom gradient, white text and 20 px icons, 40 px items. Small-caps group labels: Track (Home, Diary, Activity, Progress), Foods (My Foods), Social (Friends); the admin menu keeps its Admin group. The active item is a white pill with green text, a green edge bar and aria-current. Hover is a light fill. A prominent "Add food" button sits under the logo (the secondary button in its on-dark style, not a fifth button type, so the one-primary-button rule holds). A user card at the bottom shows "PS", Priya S., Settings and Log out. The phone bottom bar keeps its five tabs; the active tab now has a green-tinted pill behind its icon. Spec: section 4.2 and section 7 (new nav tokens, light and dark).
2. **Every table header is now unmistakable.** Solid slate header band with white semibold 12 px text; macro columns carry a coloured dot and a 3 px line with the name written out. Diary meal tables have a meal band above the header (meal name left, meal calories right). Rows have a subtle zebra tint, hover tint and 1 px dividers; numbers are right-aligned; total rows are bold on a tint with a stronger top line; "Remaining" still says left or over in green, amber or red. Applied to all tables, website and phone (on phone the meal card title bar is the meal band). Spec: global rule "Table style".
3. **Add food (section 8) and Find a food (section 11): no more right-hand panel.** Results are full width. Each food is one self-contained row with three lines: name with Verified badge and a round + quick-add button; source, serving and calories; then calories and the four macros for your amount, with Servings and Serving size controls on the same line, changing the numbers live. Nothing needs a click to see the information. Pressing + shows the toast "Added Chapathi (whole wheat) x1 to Dinner. Undo" and the row shows "Added". With several typed items the page is a left item list plus full-width results (no third column); the "how many grams in 1 katori" question opens inline on the row that needs it. "Select several" (tick boxes and one "Add 3 foods to Dinner" button) is included as a new frame. Same row design on phone (line 3 wraps, the controls move to a 4th line). Find a food gets an "Add to" meal select in the header. Spec: SCR-10 and SCR-13 rewritten.
4. **Mobile Diary fixed.** Lunch now lists all four foods (Chapathi 208, Dal Tadka 198, Rice 206, Curd 98 = 710 kcal) and Snacks both foods (Masala Chai 90, Almonds 70 = 160 kcal), so every list matches its total.
5. **Version** badge and footer now read "v0.4 (round 4)" (HTML); the spec is version 0.5.
6. **New questions:** Q21 to Q23 below.

21. **Quick add without confirmation (Q21).** Pressing + adds the food at the amount shown on the row (default 1 serving) straight away and shows a toast with Undo and an "Added" state on the row. Alternative: a one-step confirmation the first time each day. Confirm the no-confirmation version.
22. **Select several (Q22).** Included as an optional mode: a "Select several" button swaps each + for a tick box and one primary button adds all ticked foods. Do you want it in version 1, or should we keep only the + on each row?
23. **Side menu direction (Q23).** (Answered 2026-11-19, see below.) Is the green menu with the Add food button and the user card the final direction? Settings moved from the list into the user card at the bottom (next to Log out). Also confirm that the Add food button should open the meal that fits the time of day (assumption A-19).

## Decisions (Santhosh, 2026-11-19)

| Q | Decision |
|---|----------|
| Q1 | Solid colour primary buttons; gradient only for logo, rings and highlights. |
| Q2 | Phone bar: Home, Diary, Activity, Foods, More (Friends, Progress, Settings inside More). |
| Q3 | One neutral source badge style, source always in text; Nutrelia gets a brand tint. |
| Q4 | Targets in grams by default with Grams/Percent switch, Reset to recommended, water included. |
| Q5 | Mifflin-St Jeor for BMR, ICMR-NIN macro split; "How we worked this out" link stays. |
| Q6 | Compare total sugar to 22 g, with a note that it is total sugar. |
| Q7 | "Add N foods" waits until all items are resolved; "Add only the matched foods" stays. |
| Q8 | Date of birth on the register form. |
| Q9 | Long badges shortened on phone with tap-for-detail; 3-second wait, then partial results. |
| Q10 | 15% calorie check is a warning only; admin 85% similarity stop. |
| Q11 | **Changed:** import asks the user to confirm each merge in the preview (no automatic merge). |
| Q12 | Sharing on when a request is accepted, with the notice line. |
| Q13 | Delete account: hidden at once, fully deleted after a 30-day grace period; logging in within 30 days cancels. |
| Q14 | **Changed:** admin stays in the same site; draw Bulk Upload, Duplicates, Merge and Audit log now. |
| Q15 | **Changed:** recipes (FDB-12) are in v1; design the recipe builder. |
| Q16 | PWA: read-only offline for the current day. |
| Q17 | Diary shows 7 nutrient columns by default, maximum 7 (requirements LOG-UI-01/02 to be updated by product-manager). |
| Q18 | Users can choose columns in Settings > Diary; Calories fixed. |
| Q19 | No header search box (Option 1); search stays on Add food and Find a food. Decided 2026-11-19 after the picture comparison (wireframes/q19-header-search.html). |
| Q20 | Dashboard keeps its summary at the top. |
| Q21 | + adds straight away, with toast and Undo. |
| Q22 | "Select several" is in v1. |
| Q23a | **Changed:** palette B "Calm Teal" chosen from wireframes/palette-options.html (light slate menu, deep teal brand #0f766e, slate table headers, new status colours; protein #3b1a85, fiber #c026d3). |
| Q23b | Settings stays in the user card at the bottom of the menu. |
| Q23c | **Changed:** the menu "Add food" button first asks which meal (Breakfast, Lunch, Snacks, Dinner). |
| Remaining colours | Delegated to the designer with the new palette; keep a gentle "slightly over" step between "under" and "well over". |
| Branch | `master` (REQUIREMENTS.md updated). |
| MyFitnessPal PDFs | Ignored by git (`MyFitnessPal_*.pdf` in .gitignore). |

## Round 5 changes (applying the decisions of 2026-11-19)

Version is now "v0.5 (round 5)" in the HTML; the spec is version 0.6.

1. **Palette B "Calm Teal" everywhere** (Q23a). New light and dark tokens, including `--brand-ink`, `--field-border`, the `--nav-*` set, `--th-*`, `--band-bg`, `--zebra`, `--foot-bg`, `--row-hover`, `--logo-*`, the darker status colours (`--success` #14703a, `--warning` #8a5a00, `--error` #a8102a) and the new macro colours (protein #3b1a85, fiber #c026d3). The green gradient and the "on-dark" button style are gone. Side menu is light slate with a solid teal "Add food" button, a white-teal active pill with a teal edge bar, slate group labels and the user card at the bottom. Table headers are a slate band with a teal underline; meal bands are teal-tinted. Macro colours appear only as dots, bars and header underlines (no macro-coloured text). Logo mark, progress ring, calendar selected day, focus ring (brand ink), input borders (field border) and the Nutrelia badge tint follow the new tokens. Section 0 (swatches, token list, side-menu demo, buttons, contrast notes) is updated. The menu button and the one-primary rule: the rule counts the page content area; the menu button is app chrome that opens the same meal chooser as a page-level Add food (see Q24).
2. **Remaining states** keep their words with the new colours: green under, amber up to 10% over, crimson beyond.
3. **Meal chooser** (Q23c): new frame (website and phone) at the start of section 8. Menu "Add food" and the page-level "Add food" ask Breakfast, Lunch, Snacks or Dinner first, show each meal's kcal, highlight the time-of-day meal without choosing it, and close with Esc or the X. "Add food" links on a diary meal still go straight to that meal.
4. **MyFitnessPal import** (Q11): the preview asks for a choice per food that is already in My Foods ("Merge with my <food>" or "Keep both", nothing chosen at first), has "Merge all 9", and Import stays off until all 9 are chosen. Website preview redrawn (it also gets the side menu it lacked), phone preview added, result counts changed (58 added, 7 merged, 2 skipped).
5. **Delete account** (Q13): dialog explains hidden now, deleted after 30 days, log in to cancel; new "Deletion scheduled" banner frame (website and phone) with Cancel deletion and Continue.
6. **Admin** (Q14): five new frames in section 18 (Bulk Upload, Duplicates, Merge, Merge confirmation, Audit log) and an updated admin menu (Import logs, Audit log added).
7. **Recipes** (Q15): new section 19 with the builder, empty state, saved recipe detail, and the Add food "Recipes" tab (website and phone). "Meals" keeps meaning saved groups; "Recipes" is a new tab after it. My Foods gets "Create recipe" and a Recipes tab.
8. **Diary columns** (Q17, Q18): the diary still shows Food plus 7 nutrient columns; new Settings, Diary frame "Choose columns" (Calories fixed, up to 7; website at 6 of 7 with Potassium available, phone at 7 of 7).
9. **No header search** (Q19): confirmed; no frame has a header search box.

### New questions (round 5)

24. **Two Add food buttons (Q24).** On the Diary and Dashboard the page-level "Add food" and the menu "Add food" both open the meal chooser. Keep both, or remove the page-level button on those two screens?
25. **Login and deletion (Q25).** The decision says logging in within 30 days cancels the deletion, and you also asked for a banner with Cancel deletion / Continue. I drew it so that logging in does not cancel by itself: you choose on the banner. Confirm, or make login cancel automatically.
26. **Merge wording (Q26).** "Merge with my Tomato" keeps your food and fills any empty nutrient from the file; "Keep both" adds "Tomato (MyFitnessPal)". Confirm the effect and the name.
27. **Recipes and changed foods (Q27).** If an ingredient food is edited or merged, does the recipe use the new values (drawn: yes; past diary days never change), or keep a snapshot?
28. **Phone diary columns (Q28).** On phone, chosen columns show in the day summary and food rows keep calories plus Carbs, Fat, Protein. OK, or should the user pick the extra values per row?

### Round 5 decisions (Santhosh, 2026-11-19)

| Q | Decision |
| --- | --- |
| Q24 | Keep both "Add food" buttons on Dashboard and Diary (page-level and menu); both open the meal chooser. |
| Q25 | Logging in during the 30 days does not cancel deletion by itself; the banner asks Cancel deletion or Continue. |
| Q26 | "Merge with my X" keeps the user's food and only fills empty nutrients from the file; "Keep both" adds "X (MyFitnessPal)". |
| Q27 | Recipes use the new values when an ingredient food is edited or merged; past diary days never change. |
| Q28 | Phone food rows show Calories, Carbs, Fat and Protein; all chosen columns (up to 7) appear in the Day summary. |

Round 5 browser check (orchestrator): fixed clipped buttons in Duplicates and Audit log, clipped import/bulk/recipe cells, "Back to app" wrapping, a duplicated Recipes tab on the Add food Recipes tab screens (website and phone), and two recipe tooltips that showed markup. Published as preview Version 5.
