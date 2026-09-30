# Terminus - Master Product Document

This is the driving document for finishing Terminus. Any agent picking up this project
reads, in order: CLAUDE.md (project memory and landmines), this file (what to build and
why), docs/AGENT-BRIEF.md (how to think and work), docs/AUDIT-2026-07-12.md (known defects
with exact fixes). Updated 2026-07-12.

## 1. Product idea in one paragraph

Terminus turns the estimator's slowest lookup, metal-stud limiting heights, into a live
answer with a defensible paper trail. An estimator enters the wall spec (type, height,
depth, flange, spacing, load, deflection) and instantly sees, per manufacturer, the
lightest stud that passes, with the exact SSMA source table beside it. The product's only
real asset is trust: every number is either verified against a published table or loudly
marked as an estimate. Anything that erodes that trust is a severity-1 bug regardless of
how small the code change is.

## 2. Who it is for

- JC (primary): estimator doing bid takeoffs daily. Needs speed, correct numbers, and
  provenance he can cite in an RFI or submittal.
- JC's coworkers (secondary): construction professionals, not developers. Need one-click
  launch and the Field Guide.
- Jack Morgan (reader): sees outputs on a phone. Needs clean, copyable, printable results,
  not the app itself.

## 3. Current state (honest)

Working and validated: exterior structural engine (32/32 anchors within 1 inch, 30 exact),
interior S125 ladder, EQ lines flagged as estimates, wind calculator, quick compare, source
document panel, field guide, self-test button, dark and light themes, offline single file.

Not done or not trustworthy yet, in order of harm:
- Composite math is an approximation with an unconservative strength bonus (audit 2).
- Interior data has no self-test coverage (audit 3).
- Public-facing copy misstates the engineering basis (audit 1).
- Note parser can silently pick the wrong wall height (audit 4).
- EQ heights are calibrated guesses, not transcriptions.
- No export or print path for a bid pick.
- No version control, no state persistence.

## 4. Roadmap

Work top to bottom. Each phase ends with the Validate button green at 30+ of 32 exact,
a manual spot-check against the source PDFs, and a CLAUDE.md changelog entry.

### Phase 0 - Foundation (do first, half a session)
1. git init, commit everything as-is, then one commit per fix after. Acceptance: history
   exists before any code changes.
2. Apply audit findings 1, 5, 7, 8 (copy fix, EST-flagged bid pick, ftInput blur clamp,
   launcher Python check). All are low-risk and restore trust immediately.

### Phase 1 - Data integrity (the core of "complete this project")
1. Transcribe the SSMA Interior Wall composite tables (limiting heights PDF pp.19-20) into
   a COMPOSITE table keyed like COMPOSITE_ONLY, covering the full S125 ladder. Composite
   toggle switches to table lookup when a published cell exists; the 1.08 factor survives
   only as a labeled fallback for cells the book does not publish, applied to deflection
   only (audit 2). Acceptance: new interior anchors in the harness match exactly.
2. Extend the validation harness with interior anchors (audit 3). Acceptance: Validate
   modal reports structural and interior sections separately, both green.
3. Fix the parser height selection and 20ga context mapping (audit 4 and 6), and echo every
   parsed interpretation back in the findings. Acceptance: the two built-in SAMPLES plus a
   new multi-height sample parse correctly.

### Phase 2 - EQ upgrade (kills the biggest asterisk)
1. Pull the ClarkDietrich ProSTUD and CEMCO ViperStud catalog PDFs (links in SOURCES), save
   copies into sources/, transcribe their published limiting-height tables, and switch EQ
   rows from computed estimates to table lookups. Rows with a published cell flip from EST
   to a verified-per-catalog chip citing the ESR number; anything not published stays EST.
2. Telling TRUE-STUD and Steeler stay EST until literature is sourced. Never fake it.

### Phase 3 - Output (makes the tool visible to Jack)
1. Print stylesheet: printing the page yields a clean one-page bid-pick sheet (criteria,
   pick, margin, provenance, date). No dark background, no controls.
2. Copy Summary button: plain-text block of the same content on the clipboard, phone
   friendly, formatted per the copy rules (no emojis, plain professional).
3. Persist `state` to localStorage on change, restore on load, with a reset button.

### Phase 4 - Polish (only after 0-3)
- Escape closes modals, aria-pressed on segments, remaining severity-3 audit items.
- Narrow-screen layout if phone use is confirmed wanted.
- Folder rename to Terminus (needs JC's explicit go, per guardrails).

## 5. Non-goals

No backend, no accounts, no build step, no framework, no npm. The single-file property is
a feature: it is how the app gets shared, trusted, and run on any machine. Do not split
index.html into modules unless JC asks. No new MCP servers or dependencies.

## 6. Definition of done for the whole product

- Every number on screen is either reproduced from a published table (and the harness
  proves it) or visibly marked as an estimate with a link to verify.
- A coworker with no context can launch it, use the Field Guide, and print a pick.
- The repo has history, the CLAUDE.md is current, and the Validate button is green.
