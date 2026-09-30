# CLAUDE.md - Terminus (Limiting Heights Workbench)

> Persistent project memory and the EXECUTION FILE for this project. Read this file FULLY
> before doing anything else. It reflects the complete current state of the project, not
> the original plan. You should be able to work at full quality from this file alone.
> Reading order after this file: docs/PRODUCT.md (roadmap you will execute),
> docs/AGENT-BRIEF.md (mentality), docs/AUDIT-2026-07-12.md (defect list with exact fixes).
> Companion doctrine: THINKING.md sits in this same folder (a copy also lives at
> C:\Users\User\Desktop\CLAUDE CONTEXT\CLAUDE CODE\THINKING.md). If you cannot access it,
> the condensed rules in section 2 below are binding on their own.

---

## 0. COLD-START BRIEFING (keep this section current, newest truth wins)

- **Project:** Terminus is a single-file, offline-first web app that digitizes an estimator's
  metal-stud limiting-heights lookup. Pick wall type/depth/flange/spacing/load/deflection and
  it computes the lightest passing stud per manufacturer live, with a source-document audit
  trail and an AI note-parser. Formerly called "Brightline App" (the folder name is still
  `Desktop\Brightline App`, not yet renamed on disk; only in-app branding was renamed).
- **The one idea that governs everything:** this app has exactly one asset. JC can put a
  number from it in front of a GC or an engineer of record and defend it. A wrong number
  that LOOKS verified is the worst possible bug, worse than a crash. Every decision routes
  through "does this make the numbers more defensible or less?"
- **Current phase:** Functional and in daily use by JC for bid takeoffs. Engine math and
  exterior data are validated (30/32 exact, 32/32 within 1"). There ARE known open defects,
  fully cataloged in docs/AUDIT-2026-07-12.md and summarized in section 8 below. None are
  crash-level; the worst are trust and silent-wrong-answer issues. The audited state of the
  code is index.html as of 2026-07-12; audit line numbers drift as edits land, so re-locate
  by searching the quoted code, not by line alone.
- **Where the work lives:** No git repo yet, this is a plain folder. Creating one is the
  first task of Phase 0 (section 8). `index.html` is the ENTIRE app: 1339 lines, ~90 KB,
  CSS + data + engine + UI all inline. No build step, no dependencies, no npm.
- **How to run it:** Double-click `index.html` (works offline), OR `Start Terminus.bat`
  which starts `python -m http.server 8321` and opens http://localhost:8321 (needed so the
  "open source PDF" links resolve; file:// PDF links are flaky in some browsers). The
  Claude Code preview harness config is `.claude/launch.json`, server name `brightline`,
  same port; use the preview tools to drive and screenshot the app.
- **How to verify changes:** section 6 is the full playbook and definition of done. Short
  version: click "✓ Validate" in the header, require 30+/32 exact and 32/32 within 1", and
  exercise the control you touched in the browser.
- **Last session did:** Added 2-1/2" (S250) and 3" (S300) flanges across 2-1/2" to 12" webs
  (session 6, 2026-09-30). Every value was parsed from the SSMA Product Technical Guide
  section-property tables (pp.8-13). SSMA publishes no wall height table for these flanges,
  so they carry the amber CALC chip. See section 9, session 6.
- **Next up:** Execute section 8 top to bottom (it mirrors docs/PRODUCT.md). Phase 0 first:
  git init (still not done, and the file is much bigger now — this is overdue), then audit
  findings 1, 5, 7, 8. Finding 5 is now partly addressed: the BID PICK banner flags CALC
  and END STIFF, but still not `est`. Open question for JC: he described "a lot of things
  frankly not working", but the audit found no crash-level defects. Ask him for his
  specific list. Do not block Phase 0 on the answer. Also unbuilt: the AI note parser
  knows nothing about ceilings, so a note describing a ceiling still parses as a wall.
- **Landmines (memorize before editing anything):**
  - The `sources/` folder (SSMA PDFs) MUST ship alongside `index.html` or the in-app
    "verify against source" links break. If sharing the app, zip the whole folder.
  - `SSMA_STRUCTURAL` values are **gross** Ix, not effective Ixe. This is unusual and
    non-obvious: SSMA's own section-property footnote says "use effective for deflection"
    but the published limiting-height tables actually use gross, verified by exact
    reproduction of the book. Do NOT "fix" this back to effective. The footer copy that
    says Ixe is the bug (audit finding 1), not the data.
  - Composite toggle must stay hidden and no-op for any flange other than `"125"`. It has
    no SSMA data backing for structural (S137/S162/S200) studs. Guarded in two places that
    must both survive any refactor: `Engine.limitingHeight` checks `m.flange==="125"` and
    `renderInputs` hides `compRow` when `state.flange!=="125"`.
  - EQ studs (ProSTUD/ViperStud/TRUE-STUD) are calibrated estimates, not published data.
    Always flagged `est:true` plus the amber "EST" chip. Never silently upgrade to verified.
  - The 18-mil naming trap: `S125-18` (33 ksi, conventional 25ga) and `PDS125-18`/`VS125-18`
    (70 ksi, 20ga EQ) are BOTH 18 mil but different products with different heights. JC's
    dept company codes `250S`/`35820S`/`420S`/`620S` belong to the EQ tier ONLY, wired in
    `COMPANY_ALIAS_20EQ` and applied only where `eq:true`. Never on the plain SSMA row.
  - The 5 psf load case NEVER gets the 0.70 wind-deflection reduction (SSMA footnote).
    The guard is `c.psf > 5` in `Engine.limitingHeight`.
  - **S250 (2-1/2") and S300 (3") flanges have NO published SSMA wall height table.** The
    Curtain Wall tables cover S137/S162/S200 only. Section properties are SSMA-published, the
    heights are engine-computed, flagged CALC via `CALC_ONLY_FLANGES`. Ma is NOT monotonic in
    flange width (distortional buckling), so `runSectionChecks` enforces Ix only across flanges.
    Gross Ix runs up to about 7 percent above Ixe on the lightest S300-54 rows (about 2 percent
    of height where deflection governs); nothing published lets us check that against a book.
  - **10" and 12" have NO published SSMA height table.** The Curtain Wall tables stop at
    800S200-118 (guide p.27) and the ceiling tables stop at 800S. SSMA publishes section
    properties for 1000S/1200S (pp.12-13) and nothing else. So those depths are computed
    by the engine and MUST keep the amber `CALC` chip and stay out of `verified:true`.
    Never promote them to the green SSMA chip. Guarded by `CALC_ONLY_DEPTHS`.
  - Ceiling/soffit spans are **pure table lookup, never computed**. `Engine.ceilingSpan`
    indexes the transcribed arrays; a combination SSMA does not publish returns `nr:true`
    and renders N/R. Do not add a computed fallback: the published spans account for
    unbraced-flange moment, web crippling and shear, which this engine does not model.
  - The ceiling data was produced by **parsing the PDF, not typing it**. If it ever needs
    regenerating, the scripts pattern is in section 9 session 5: extract with PyMuPDF,
    assert 18 cells per S row, then check monotonicity. Do not hand-edit cells.
  - `SSMA_NONSTRUCTURAL` (the S125 drywall ladder) stops at 800. `rebuildFlangeSeg` and
    `reconcileWall` both depend on that to hide the 125 button at 10"/12"; keep them in
    sync or the matrix renders empty.
  - Do not rename the project folder without JC's explicit go-ahead (paths reference it).

## 1. Who you are working for

John Carlo Tiempo (JC), engr.jctiempo@gmail.com. Estimator and pre-construction manager at
Brightline Contracting, a commercial drywall, metal framing, and painting subcontractor in
Greenville, South Carolina. He works remotely from the Philippines (Asia/Manila). Strong
Python developer, pragmatic, ships tools for real construction workflows. His boss Jack
Morgan often reads the outputs on a phone. Full people-and-vendor context lives in
`C:\Users\User\Desktop\CLAUDE CONTEXT\CLAUDE.md`; read it when the task touches emails,
invoices, GCs, or company data.

Note: the company is "Brightline Contracting" and that name stays. Only this app was
renamed to "Terminus" (Roman god of boundary stones; the meaning "limit" is the point,
and JC has chosen the name).

**Style: act first, explain after.** JC grants initiative. Fix bugs and build improvements
without asking, within section 5 guardrails. No planning theater. Tight summaries: what
shipped, what evidence, what is next.

## 2. The rules (condensed doctrine, binding for any model)

1. Understand before acting. Read this file fully. Read files before editing them.
2. Root cause before fix. Reproduce, isolate, prove the hypothesis, THEN fix. Before any
   edit, be able to say "X is wrong because Y, the fix is Z, verified by W". If you cannot
   fill in W, you are not ready to edit. Never stack failed fixes; revert each failed
   attempt fully before trying the next. Three strikes on a bug means write down what you
   learned here and regroup.
3. Plan before code for anything beyond a one-file change. Write the plan down.
4. Evidence before claims. Never say done or fixed without having run it and seen it work.
   Verify against real data (the PDFs in sources/) when it exists.
5. Simplest thing that works. No speculative abstraction, dependencies, or config.
6. Git from minute one. Commit every working increment with a clear message. (Repo does
   not exist yet; creating it is Phase 0 task 1 in section 8.)
7. Security ships with the feature. (N/A so far: static, client-side, no backend, no auth
   surface, no secrets. Keep it that way; see section 5.)
8. Instant UI feedback. Every user-facing control reacts immediately. Inputs must never
   fight the user while typing: apply freely on input, clamp and normalize on blur only.
   This has burned JC twice (windV, then ftInput); the windV handler is the reference
   implementation of the correct pattern.
9. Cost discipline. Do not re-read what this file already summarizes. Batch questions,
   parallel-run independent commands. No new MCP servers, plugins, or dependencies unless
   the task is impossible without them. Bulk PDF transcription is cheap-model or subagent
   work; engine and data changes deserve the strong model.
10. Output conventions, everywhere, including code comments, commit messages, and product
    copy: no em dashes, no emojis, lists not tables in prose (tables inside the app UI are
    fine), phone numbers without a leading plus sign, plain professional tone in anything
    boss- or customer-facing.

## 3. Session protocol (this is how sessions get saved, do not skip)

**On start:**
1. Read this entire file.
2. If resume, memory, or checkpoint skills are available, use them. Otherwise section 0
   and section 9 ARE the memory.
3. State in one line what you are about to do, then do it.

**On end (mandatory, the session is not over until this is done):**
1. Update section 0 (cold-start briefing) to the new truth.
2. Add an entry to section 9 (changelog): date, what shipped, what broke, what is next.
3. Mark finished roadmap items done in section 8 AND in docs/PRODUCT.md; note fix dates
   next to resolved findings in docs/AUDIT-2026-07-12.md (do not delete findings).
4. Commit everything, including this file (once the repo exists).
5. Auto-memory is active at `C:\Users\User\.claude\projects\C--Users-User-Desktop-
   Brightline-App\memory\` - keep `brightline-limiting-heights-app.md` in sync with this
   file; they must never contradict each other.

## 4. Project specifics

- **Stack:** Zero-dependency single-file web app. Plain HTML + CSS (custom properties,
  dark default + `body.light` theme) + vanilla JS. Google Fonts (Barlow Condensed, Barlow,
  JetBrains Mono) via CDN link tags is the ONLY external dependency and degrades gracefully
  offline. No React, no build tool, no package.json. This is a feature, not a gap.

- **Map of index.html** (one file, one organism; positions are as of 2026-07-12, drift
  expected, search by name):
  1. CSS theme + layout, lines ~10-323.
  2. Static HTML skeleton: header, three-pane grid (inputs / matrix / doc viewer), modals,
     footer, lines ~325-487.
  3. DATA: `SSMA_STRUCTURAL` (depth -> flange -> mil -> [gross Ix, Ma, Fy]),
     `SSMA_NONSTRUCTURAL` (S125 ladder), `COMPOSITE_ONLY` (600S125-18 published composite
     table), `EQ_LINES` (four proprietary EQ families, est:true), `MANUFACTURERS`, `DB`
     (presets and labels), `SOURCES`, lines ~505-633.
  4. Member builders: `structuralMembers`, `nonstructuralMembers`, `eqMembers`,
     `COMPANY_ALIAS_20EQ`, lines ~636-661.
  5. ENGINE: `Engine.limitingHeight` (AISI S100: deflection L = cbrt(384 E Ix / (5 w n)),
     strength L = sqrt(8 Ma / w), lesser governs, rounded to nearest inch to match the
     book; 0.7W deflection-only reduction for exterior wind when psf > 5; composite factor
     for interior 125 only; direct table lookup for members carrying `.table`) and
     `Engine.windPsf` (simplified ASCE 7 C&C, labeled an approximation), lines ~669-698.
  6. Global `state` object + `fmtFtIn`, lines ~699-711. Everything renders from `state`.
  7. VALIDATION: `SSMA_ANCHORS` (32 hand-transcribed exterior cells) + `runValidation()`,
     lines ~720-749.
  8. Query layer: `familiesFor` (which manufacturer blocks to show for current criteria),
     `evaluateMatrix`, `globalBestPick` (lightest passing by mil, then tallest), ~758-817.
  9. Render: `renderInputs`, `renderMatrix` (+ BID PICK banner), `renderQuickCompare`,
     `renderDoc` (source facsimile + audit trail), `renderAll` re-renders everything,
     lines ~822-1108.
  10. `SpecParser` + `aiAnalyze` (the "AI Estimator Assistant" is regex parsing, fully
      local, NOT an LLM call) + `SAMPLES`, lines ~1113-1242.
  11. `GUIDE` content + `openGuide`, `renderValidation`, `renderSources`, boot,
      lines ~1247-1336.

- **Data sources:**
  - `sources/SSMA_Product_Technical_Guide.pdf` - section properties pp.7-12, transcribed
    into `SSMA_STRUCTURAL` and `SSMA_NONSTRUCTURAL`.
  - `sources/SSMA_LIMITING_HEIGHTS_official.pdf` - same guide, different focus: "Curtain
    Wall Limiting Heights - Single Span" pp.25-30 (validation anchors come from here) and
    "Interior Wall Heights - Composite" pp.19-20 (NOT yet transcribed; Phase 1 work).
  - `sources/SteelCon_362S162-43_Submittal.pdf` - independent third-party cross-check.
  - EQ data is NOT from a primary source: calibrated to one verified anchor (ProSTUD 25 @
    5psf/16"oc/L240 = 12'-4", matches ClarkDietrich published). Stays EST until Phase 2.

- **Conventions in this codebase (implicit things made explicit):**
  - Heights live in inches internally; format to feet-inches ONLY at render time via
    `fmtFtIn()`. Never store formatted strings.
  - Every member object carries `desig, depth, flange, mil, ix (gross, in^4), ma (lb-in),
    fy (ksi), ga` plus optional flags `verified / est / eq / compOnly / alias / table`.
    The flags drive the provenance chips: green SSMA = verified, amber EST = estimate,
    blue EQ = proprietary line, blue COMP ONLY = composite-rated only. New data must fit
    this shape; a new provenance state needs a new chip, never a repurposed one.
  - `depth` and `flange` keys are strings ("362", "125"); `mil`, `spacing`, `defl`, `psf`
    are numbers. Comparisons like `m.flange==="125"` depend on this; keep types stable.
  - Adding UI state means: add to `state`, wire the control in `initControls`, reflect it
    in `renderInputs`, and let `renderAll()` fan out. Render functions rebuild innerHTML
    wholesale and re-attach listeners each pass; there is no virtual DOM, do not attach
    listeners outside the render cycle or they leak.
  - `renderAll(false)` means "do not rewrite the ft/in number fields" (used while the user
    is typing in them). Respect this pattern when adding inputs.
  - E = 29,500,000 psi. Book rounding is to the nearest inch; the engine matches it.
  - Code comments follow the copy rules (section 2 item 10) and state constraints, not
    narration.

- **External services and keys:** None. No API calls, no keys, no accounts, no telemetry.
  Keep it so.

## 5. Guardrails (do not cross without JC's explicit go-ahead)

- Never present EQ-line heights as verified/published. They keep the EST chip and the
  catalog-verify links until a published catalog cell backs them, per row, with the
  catalog PDF saved into sources/.
- Never change `SSMA_STRUCTURAL`, `SSMA_NONSTRUCTURAL`, `COMPOSITE_ONLY`, or
  `Engine.limitingHeight` without re-running Validate and matching or beating the current
  score. Extend the harness BEFORE touching data it does not cover; you cannot protect
  what you do not test.
- Never interpolate or extrapolate a missing table cell quietly. Not published means N/R
  or EST on screen.
- Never re-enable the composite toggle for non-125 flanges.
- Never add a backend, account system, build step, framework, or npm to this project.
- Do not rename the project folder (`Desktop\Brightline App`) without confirming with JC.

## 6. Verification playbook and DEFINITION OF DONE

A change to this project is DONE only when all of these hold. Run them before claiming
anything is finished; paste the evidence into your summary.

1. The app opens with zero console errors (browser preview or Start Terminus.bat).
2. "✓ Validate" shows 30+/32 exact and 32/32 within 1". In the console,
   `runValidation().filter(x=>!x.ok)` returns `[]`. Required after ANY change to engine
   math, section-property data, or anchors. If the score regresses, stop and root-cause;
   never rationalize a lower score.
3. The specific control or path you changed was exercised by hand in the browser and you
   watched it do the right thing. For parser changes: click "Load Sample Note" through all
   SAMPLES and confirm each parses correctly; add a sample covering your change.
4. One interior and one exterior scenario spot-checked against the linked source PDFs
   (the doc panel's facsimile table exists specifically to lay beside the real page).
5. Data changes: values transcribed with the PDF open, into a scratch file first, anchors
   added to the harness BEFORE the data was wired into the UI.
6. Copy rules hold in everything you wrote (no em dashes, no emojis, plain tone).
7. Section 0 and section 9 of this file updated; docs/ updated per section 3; committed
   (once the repo exists) with one commit per working increment.
8. Your summary to JC states what shipped, the Validate score, what was spot-checked, and
   what is next. Failures reported plainly with output, no spin.

## 7. Shipping for colleagues

- `Start Terminus.bat` is the one-click launcher (needs Python); plain double-click on
  `index.html` works for anyone, no Python needed.
- To share with a coworker: zip the ENTIRE `Brightline App` folder so `sources/` travels
  with it and the verify-against-source links keep working.
- The in-app "Field Guide" button is the plain-English one-pager for anyone unfamiliar
  with psf loads, deflection limits, EQ studs, or flange sizes. Point new users there.

## 8. ROADMAP (execute top to bottom; mirrors docs/PRODUCT.md, full detail there)

Every phase ends with the full section 6 checklist plus a changelog entry. Finding
numbers refer to docs/AUDIT-2026-07-12.md.

**Phase 0 - Foundation (half a session, do first):**
1. `git init`, commit everything as-is BEFORE any code change, then one commit per fix.
2. Finding 1: the footer (search "effective section properties") and renderSources
   (search "were transcribed") claim effective Ixe; the data is intentionally gross Ix.
   Fix the copy to say gross Ix for deflection, Ma for strength. Copy only; the Validate
   score must not move.
3. Finding 5: the BID PICK banner does not flag when `best.member.est` is true, so an EQ
   estimate can wear "OPTIMAL BID PICK" with no EST marker. Add the amber EST chip plus
   "estimate - verify in catalog" to the banner when the pick is an estimate.
4. Finding 7: `ftInput` clamps while typing (typing the "1" of "14" snaps to 8 ft). Apply
   the windV pattern: free typing on input, clamp on blur.
5. Finding 8: `Start Terminus.bat` prints "Server may already be running" when Python is
   missing. Add a `where python` check that tells the user to double-click index.html
   instead.

**Phase 1 - Data integrity (the core of finishing this product):**
1. Finding 3 FIRST: interior data currently has ZERO self-test coverage. Add 8-12
   interior anchors to the harness (362S125-18, 362S125-30, 600S125-43 non-composite;
   600S125-18 composite at all three spacings; one 800 row), transcribed from the
   limiting heights PDF, routed through `nonstructuralMembers` with correct
   wallType/composite flags.
2. Transcribe the SSMA Interior Wall composite tables (limiting heights PDF pp.19-20)
   into a table keyed like `COMPOSITE_ONLY`, covering the full S125 ladder. The composite
   toggle switches to table lookup where a published cell exists. The 1.08
   `compositeFactor` survives only as a labeled fallback and applies to DEFLECTION ONLY
   (finding 2: the current code also multiplies strength by 1.08, which is unconservative
   and has no published basis).
3. Finding 4 (most dangerous known defect): the parser height regex takes the FIRST
   feet-value in a note, so "ceiling at 9'-0", deck at 24'-0"" targets 9 ft and blesses a
   failing stud. Fix: matchAll, filter to the 8-40 ft window, take the MAXIMUM, and echo
   the interpretation in the findings ("Height read as 24'-0", tallest of ..."). Also
   finding 6: map "20ga" to 30 mil in interior context (33 stays for structural). Add
   regression samples to SAMPLES for both.

**Phase 2 - EQ upgrade:** pull the ClarkDietrich ProSTUD and CEMCO ViperStud catalog PDFs
(links live in the `SOURCES` array), save copies into sources/, transcribe their published
limiting-height tables, and switch EQ rows to table lookups. Published cells flip EST to a
verified-per-catalog chip citing the ESR number; unpublished cells stay EST. Telling and
Steeler stay EST until literature is sourced. Never fake it.

**Phase 3 - Output:** print stylesheet (one-page bid-pick sheet: criteria, pick, margin,
provenance, date; light background, no controls), a Copy Summary button (plain-text
clipboard block, phone friendly, copy rules apply), and `state` persistence to
localStorage with restore on load and a reset button.

**Phase 4 - Polish (only after 0-3):** Escape closes modals, aria-pressed on segment
buttons, remaining severity-3 audit items (null-guard for the selected row in renderDoc,
Number() normalization in the COMPOSITE_ONLY psf lookup, Math.round guard in fmtFtIn,
local copies of the rot-prone EQ catalog URLs, DB.version bump discipline), narrow-screen
layout if JC confirms phone use, folder rename only with JC's explicit go.

**Standing question for JC:** his list of what is "frankly not working", one line each.
Anything he names jumps the queue.

---

## 9. SESSION CHANGELOG (newest first; never delete old entries)

### 2026-09-30 - Session 6 (2-1/2" and 3" flanges)
- JC needed lighter gauges than 14ga/12ga for a tall wall and asked for 2-1/2" and 3" flanges.
- Added `SSMA_STRUCTURAL` rows: S250 at 2-1/2", 3-5/8", 4", 6" webs (800/1000/1200 already
  existed) and S300 at 3-5/8" through 12" webs. Source: SSMA guide pp.8-13, parsed with
  PyMuPDF. Method proven first: the same parser reproduced 91 existing app rows with 0
  differences (Ix gross, Ma = min(Mal, Mad), Fy 33 for 33/43 mil else 50), and the existing
  800/1000/1200 S250 values matched the PDF exactly. Three rows with a footnote marker split
  from Mal (600S250-97, 600S250-118, 600S300-118) were read by hand from the page.
- New flag set `CALC_ONLY_FLANGES`; the existing 800S250 rows are now CALC too (they had been
  marked verified although no book table covers them). Doc panel no longer claims a CALC row
  "matches the SSMA table". Parser learned "2-1/2 flange" and "3 flange", and "2-1/2 flange"
  no longer reads as a 2-1/2 inch stud or a 2 inch flange.
- Validate unchanged at 30/32 exact, 32/32 within 1". New section checks: 146 members consistent.
  Sweep of 207 depth/flange/spacing combinations, 0 empty matrices, no script errors.
- 1200S300-54 added to `WEB_STIFFENER_REQ` (SSMA footnote 1 on that row).
- Next: Phase 0 of section 8 is still open (git, audit findings).

### 2026-08-27 - Session 5 (10"/12" studs + ceiling & soffit span mode)
- JC asked for the 10" and 12" studs plus "studs we can use for ceiling spans".
- **10" and 12":** added `SSMA_STRUCTURAL["1000"]` and `["1200"]` (flanges 162/200/250,
  mils 43-118 and 54-118), added `800S250` while in the same table, added the 2-1/2"
  flange to `DB.flanges`, and added 118 mil = 10ga to `DB.gaugeName`.
- **Key finding, recorded as a landmine in section 0:** SSMA publishes NO wall limiting
  height table for these depths. Verified by reading p.27 - the Curtain Wall Single Span
  table ends at 800S200-118 - and the ceiling tables end at 800S too. So these heights are
  engine-computed. Added a `calc:true` flag, a new amber `CALC` chip, a warning line in the
  criteria trace, a banner tag, a footer paragraph and a Validate-modal section explaining
  exactly what is and is not backed by the book. They are deliberately NOT `verified:true`.
- Added `WEB_STIFFENER_REQ` and an `END STIFF` chip for sections whose web h/t exceeds 200
  (guide footnote 1, all the lightest 10"/12" gauges). Web stiffeners at every support are
  a real labour line on the bid, so it is surfaced rather than buried.
- **Ceiling mode:** new third `wallType` = `ceiling`, with sub-controls for location
  (interior 4/6/13 psf vs exterior soffit 20-50 psf), framing system (S-joist / hat furring
  F-section / cold-rolled U-channel), and the bracing condition (S: unbraced vs braced at
  midspan; F and U: single vs multiple continuous span). Spacing set swaps to 24-72" for
  U-channels. Deflection limited to L/240 and L/360, which is all SSMA publishes.
  `Engine.ceilingSpan` is a pure table lookup wired in at the top of `limitingHeight`, so
  the matrix, Quick Compare, bid pick and doc panel all work unchanged. New
  `renderCeilingDoc` draws the facsimile grid (ceiling members have no Ix, so the existing
  facsimile path would have produced NaN).
- **How the data got in, and why it is trustworthy:** ~7,600 published cells across guide
  pp.62-69 were far too many to hand-type, so they were extracted programmatically with
  PyMuPDF (scratchpad scripts parse_ceiling.py / parse_rest.py / verify.py / emit_js.py),
  asserting exactly 18 cells per S-section row. Verified three ways: (1) spot-checks
  against cells read by eye off the pages, (2) section-modulus arithmetic - all 92 rows on
  pp.12-13 satisfy Sx = Ix/(d/2), which catches digit slips, (3) monotonicity invariants
  over all 6,948 S-section cells - span must fall as spacing widens, fall as load rises,
  never be shorter when braced at midspan, never be longer at L/360 than L/240. All pass.
  Invariant check (2) and (3) are wired into the in-app Validate modal permanently.
- **Bug found and fixed during testing:** leaving ceiling mode stranded `depth`/`flange` on
  U-channel values ("75"/"050"), emptying the flange selector and the matrix. Added
  `reconcileWall()` as the mirror of `reconcileCeiling()`. A sweep of 1,163 control
  combinations then produced zero empty matrices. Also suppressed the S125 flange button at
  10"/12" (the drywall ladder stops at 8") rather than showing an empty result, and added a
  null guard for a stale selected row in `renderDoc` (audit severity-3 item, fixed in
  passing because ceiling mode makes stale selections far more likely).
- Field Guide gained `ceiling` and `deepstud` sections, wired to new "?" icons.
- Verification: Validate still reads 30/32 exact and 32/32 within 1" (unchanged - the new
  data does not touch any existing anchor); 6,948 ceiling cells, 0 consistency failures;
  6 book spot-checks across all four ceiling table families exact; zero console errors.
  1200S162-54 hand-checked against the AISI S100 expressions independently (644" both ways).
- `index.html.bak-before-ceiling` left in the folder as a safety net since there is still
  no git repo. Delete it once Phase 0 task 1 is done.
- Next: git init is overdue. AI parser still has no ceiling awareness.

### 2026-07-12 - Session 4 (CLAUDE.md rewrite for agent self-sufficiency)
- Rewrote this file so any agent (Opus or Sonnet included) can execute from it alone.
  Corrected stale facts: index.html is 1339 lines not ~2000, and "no known open bugs"
  replaced with the honest audit state. Made implicit conventions explicit (member object
  shape and flags, string vs number key types, render cycle and listener rules,
  inches-internal convention, clamp-on-blur input pattern, renderAll(false) meaning).
  Added section 6 definition of done with the exact checks to run. Inlined the full
  roadmap as section 8 with audit finding numbers and search anchors instead of bare line
  numbers. Folded the docs/ reading order and the trust-first governing idea into the
  header and section 0. Reordered Phase 1 so harness anchors land before the composite
  data they protect. No app code changed.

### 2026-07-12 - Session 3 (full audit + docs/ product documents)
- Full end-to-end audit of the codebase: every line of index.html, the launcher, configs.
  No code changed; this was deliberately a read-and-document session per JC's request.
- Engine independently re-verified: replicated the math and transcribed section properties
  in Python against all 32 SSMA anchors (30/32 exact, 32/32 within 1"), and confirmed the
  identical result from in-app runValidation() via the browser preview. Data and math are
  sound as shipped.
- Created `docs/` folder: AUDIT-2026-07-12.md (findings ranked by severity with exact
  fixes; top items: footer claims effective Ixe while data is intentionally gross Ix,
  composite factor unconservatively boosts strength, interior data has no validation
  anchors, AI parser height regex takes the first feet-value in a note), PRODUCT.md
  (master product document with phased roadmap and acceptance criteria), AGENT-BRIEF.md
  (thinking and mentality instructions for future agents), README.md (reading order).
- Section 0 cold-start briefing rewritten to point at docs/PRODUCT.md as the driver.
- Open question for JC: he described "a lot of things frankly not working" — the audit
  found no crash-level defects, so his specific list is needed to reconcile.
- Next: Phase 0 of docs/PRODUCT.md (git init + four low-risk trust fixes).

### 2026-07-08 - Session 2 (branding + CLAUDE.md)
- Renamed the app from "Brightline" to "Terminus" throughout: `<title>`, header `<h1>`,
  header comment, `localStorage` theme key (`bl-theme` -> `terminus-theme`), and the
  launcher batch file (`Start Brightline.bat` -> `Start Terminus.bat`, content updated,
  old file deleted).
- Added a custom SVG icon (boundary-stone / terminus-marker shape crossed by the orange
  "limit line") replacing the old plain CSS square, used both as the header logo mark and
  as an inline-SVG favicon.
- Filled in this CLAUDE.md from the blank template using the claude-md-improver skill —
  first time this file has been completed for this project.
- The project folder itself (`Desktop\Brightline App`) was intentionally NOT renamed —
  scope was in-app branding only, per what was actually asked.

### 2026-07-08 - Session 1 (data accuracy, feature build-out)
- Built the initial app: interactive limiting-heights matrix, source-document audit trail,
  AI note-parser assistant, multi-manufacturer comparison.
- JC reported the numbers didn't match his own reference data ("I hate inaccurate data").
  Root-caused: exterior-mode load presets were `[10,15,20,25,30]` psf, which made the
  book's 5 psf column (where JC's comparison value lived) unreachable in the UI — the math
  was already correct, the UI just couldn't reach the column being checked. Fixed load
  presets to `[5,10,15,20,25,30,40,50]` and corrected the 0.70-wind-deflection-reduction
  rule to exempt 5 psf (matches SSMA table footnote: "5 psf pressure has not been reduced
  for deflection checks").
- Added interior/exterior wall type toggle, full gauge range (20ga-12ga / 33-97 mil),
  8" stud depth, flange size selector (S125/S137/S162/S200 - this was specifically
  requested after JC noticed only 125 flange was available), exterior finish selector
  (brick/stucco/ACM/stone with auto-set deflection limits), wind-speed-to-pressure
  calculator, Quick Compare depth-x-spacing grid, dark/light theme toggle.
- Added 3 more manufacturers (CEMCO, Steeler, confirmed Telling Industries TRUE-STUD) after
  JC asked "where are the others" - was originally ClarkDietrich/MarinoWARE/Telling only,
  had been over-consolidated into generic "SSMA standard" blocks; restored full per-
  manufacturer gauge ladders (25ga EQ through 14ga) per manufacturer, with a standalone
  SSMA-standard reference block kept alongside (JC explicitly asked to keep this, not
  remove it, after a prior pass replaced it with per-manufacturer-only view).
  - Explained the 18-mil naming trap to JC: `S125-18` (33 ksi conventional 25ga) and the
    20ga EQ studs (70 ksi, `PDS125-18`/`VS125-18`) are both 18 mil but different products
    with different rated heights. JC's department uses codes `250S`/`35820S`/`420S`/`620S`
    for the EQ tier specifically - added these as display aliases and taught the AI note
    parser to recognize them, but explicitly did NOT apply them to the plain SSMA row
    (confirmed via SSMA section-property table that they are genuinely different steel
    grades, not just a naming difference).
  - Confirmed JC's 6" 25ga/20ga-EQ studs he's used before ARE in the dataset (composite-
    only: SSMA does not rate 600S125-18 outside composite walls per the guide's own
    footnote; added `COMPOSITE_ONLY` table with real published composite-table values).
- Found and fixed a real engine bug during a full validation pass (JC: "make sure that it
  applies to every single one of them"): SSMA's limiting-height tables use GROSS Ix for
  deflection, not effective Ixe as the section-property table's own footnote implies.
  This only affected deep 8" sections and a few heavy gauges (light sections have
  gross ~= effective). Corrected `SSMA_STRUCTURAL` values to gross Ix. Built a permanent
  32-cell validation harness (`SSMA_ANCHORS` / `runValidation()`) spanning every depth,
  flange, gauge, load case, and spacing, exposed via a "✓ Validate" header button so JC
  can re-verify at any time without asking. Result: 30/32 exact, 32/32 within 1" (book
  rounding).
- Fixed the Composite Assembly toggle incorrectly applying its ~8% bonus to structural
  (S137/S162/S200) studs when it should only ever apply to S125 drywall studs (SSMA has
  no composite table for structural studs at all). Toggle now hides entirely for non-125
  flanges and has zero effect on the math for them.
- Fixed the wind-speed input fighting the user while typing (JC: "so hard to type the wind
  speed") - it was clamping and rewriting the field on every keystroke. Now types freely
  and only clamps/validates on blur.
- Next up going into session 2: branding rename (see above) and this CLAUDE.md fill-in.
