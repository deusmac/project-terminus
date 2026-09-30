# Agent Brief - How to work on Terminus

Written by Fable 5 on 2026-07-12 for whichever agent (or model) continues this project.
This is the mentality file. THINKING.md in this folder's parent is the general doctrine
and is binding; this file is the Terminus-specific application of it. If the two ever
conflict, THINKING.md wins, then CLAUDE.md guardrails, then this.

## The one idea that governs everything

This app has exactly one asset: JC can put a number from it in front of a general
contractor or an engineer of record and defend it. Every decision routes through the
question "does this make the numbers more defensible or less?" A beautiful feature that
weakens provenance is a regression. An ugly fix that strengthens provenance ships today.

Concretely, that means:
- A wrong number that LOOKS verified is the worst possible bug. Worse than a crash. A
  crash gets noticed; a wrong height gets bid, and JC eats the cost on site.
- When data and convenience conflict, data wins. If a table cell is not published, show
  N/R or EST. Never interpolate quietly, never extrapolate quietly, never let an estimate
  wear a verified chip.
- The Validate button is the contract. Any change to SSMA_STRUCTURAL, SSMA_NONSTRUCTURAL,
  COMPOSITE_ONLY, or Engine.limitingHeight is unfinished until Validate has been clicked
  and shows the same or better score than the last changelog entry (currently 30 of 32
  exact, 32 of 32 within 1 inch). Extend the harness BEFORE touching data it does not
  cover yet; you cannot protect what you do not test.

## How I actually think through a change here (imitate this)

1. Read CLAUDE.md fully, then the section of index.html you will touch, then the section
   AROUND it. This file is one organism; renderAll re-renders everything, state is global,
   and a change in one render function shows up in three panes.
2. Before editing, state the hypothesis in one sentence: "X is wrong because Y, and the
   fix is Z, verified by W." If you cannot fill in W (how you will SEE it work), you are
   not ready to edit.
3. Trace the domain, not just the code. This app encodes real steel: gross versus
   effective Ix, 33 versus 50 versus 70 ksi, the 18-mil naming trap, the 5 psf wind
   exemption. Every one of those is a place a past session almost shipped a wrong number.
   When you meet a value you do not understand, open the PDF in sources/ and find it on
   the page before assuming the code is wrong. Twice already the code was right and the
   assumption was wrong (gross Ix being the famous one).
4. Make the smallest change that fixes the root cause, then grep for siblings. The
   ftInput clamp bug in the audit is the sibling of the already-fixed windV clamp bug;
   bugs in this codebase travel in families because render patterns are copy-pasted.
5. Verify in the running app, not in your head. Launch via the preview harness or
   Start Terminus.bat, click Validate, exercise the control you touched, and spot-check
   one interior and one exterior scenario against the linked PDF. Screenshot or paste the
   result into your summary. "It should work" has already cost JC real money.
6. Never stack fixes. If your fix did not work, revert it fully before trying the next
   idea. Three failed attempts means stop, write down what you learned in CLAUDE.md, and
   regroup with a fresh isolation pass.

## Terminus-specific landmines (memorize before editing)

- Gross Ix, not effective Ixe, in SSMA_STRUCTURAL. Do not "correct" it back. The footer
  copy is what is wrong (audit finding 1), not the data.
- Composite toggle exists only for flange 125. The guards live in Engine.limitingHeight
  (m.flange==="125") and renderInputs (compRow display). Both must survive any refactor.
- S125-18 (33 ksi) and PDS125-18 or VS125-18 (70 ksi) are both 18 mil and are different
  products. Company codes 250S, 35820S, 420S, 620S belong to the EQ tier only.
- EQ rows keep the EST chip until a published catalog cell backs them, per row, with the
  catalog saved into sources/.
- The 5 psf column never gets the 0.70 wind deflection reduction.
- The sources/ folder must ship with index.html; relative links break otherwise.
- Do not rename the project folder without JC's explicit go-ahead.

## Working rules (condensed from THINKING.md, binding)

- Understand before acting; root cause before fix; plan in writing before multi-file work.
- Evidence before claims: run it, see it, show it.
- Simplest thing that works: one file, no dependencies, no build step, no new tools.
- Commit every working increment once git exists (Phase 0 makes it exist).
- Copy rules for everything including code comments and UI copy: no em dashes, no emojis,
  lists not tables in prose, plain professional tone.
- Cost discipline: front-load reading once, batch questions, do not narrate, right-size
  the model (bulk transcription of PDF tables is cheap-model work; engine changes are not).
- End every session by updating CLAUDE.md section 0 and the changelog. The session is not
  over until state is saved.

## How to proceed, concretely

1. Open docs/PRODUCT.md. Take the highest unfinished phase.
2. Phase 0 first if git does not exist yet: git init, commit as-is, then apply audit
   findings 1, 5, 7, 8 as four separate commits, verifying each in the browser.
3. For Phase 1 data work: transcribe from the PDF with the PDF open, into a scratch file
   first; write the anchors into the harness BEFORE wiring the data into the UI; only
   then switch the engine to the new table and watch Validate stay green.
4. For anything touching the parser: add the test note to SAMPLES (or a comment block of
   test cases) so the next agent can regression-check by clicking Load Sample Note.
5. When JC reports "the data is wrong": history says believe him AND verify the exact
   cell he is looking at first. Both prior data complaints were real, and one of them was
   a UI reachability problem (the 5 psf preset), not math. Reproduce his exact view
   before changing anything.
6. Summaries to JC: what shipped, what evidence (Validate score, spot-checks), what is
   next, in plain language, tight.
