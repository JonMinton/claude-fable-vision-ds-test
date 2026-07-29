# TidyTuesday with Claude — project instructions

This repo is not a portfolio. It is a **small, repeatable experiment** in how Claude does
exploratory data analysis, published as a Quarto site so the output can be judged the way
a reader would judge it.

Each page is one TidyTuesday session. Sessions vary along two axes, and every page records
where it sits on both:

| Axis | Values |
|---|---|
| **Mode** | *co-developed* (live, turn-by-turn with Jon) · *autonomous* (Claude unsteered) |
| **Model** | whichever Claude model ran the session (Fable 5, Opus 5, …) |

The point of keeping these separate and labelled is that a page's provenance is part of
what it is. Never blur the arms: don't retro-edit an older session's pages to match a newer
session's ideas, and don't let one model's session silently absorb another's.

## The standing brief

**Autonomous session.** *"Keep making things like the existing pages, but apply your own
judgement."* In full, as it should be handed to any model:

> Look at the existing pages on this site. Make some more, choosing everything yourself:
> which TidyTuesday datasets, what question to ask of each, what to show and how, and the
> words. Differentiate what you make from what's already here — by leaning into statistical
> inference, or substantive depth, or visuals unlike anything on the site. Render each page
> and **look at it** before you call it done. No one will steer you during the session.

*(The Session 2 wording above is reconstructed from `reflection.qmd`, written at the time by
the model that ran it. Treat this file's version as canonical for future sessions.)*

**Co-developed session.** Jon sets direction and reacts to each plot; Claude explores,
drafts and edits. See "Working with Jon's live R session" below — the division of labour is
strict and deliberate.

## The vision loop — the thing actually under test

An autonomous session is not "generate a page." It is **make → look → revise**:

1. Write the `.qmd` and render it.
2. **Open the rendered page and look at the figures** — in the browser via the Chrome
   tools, or by reading the PNGs under `_freeze/<page>/figure-html/`.
3. Fix what you can only catch by looking: text colliding with a legend, a title that
   contradicts the bars beneath it, a density estimator that has silently collapsed on
   heaped data, a number in the prose that doesn't match the number in the chart.
4. Repeat until the page reads as a reader would read it.

Session 2 logged four such catches; that record is the useful output. **Log yours** — in
the session's commit messages and, if you write one, in the reflection page. A session that
reports no catches is reporting a result, so say that too rather than staying silent.

## Page conventions

Front matter, then the provenance badge, then the piece:

```yaml
---
title: "Sentence-case title, an argument not a topic"
subtitle: "TidyTuesday YYYY-MM-DD · What the dataset is"
date: <session date>
---
```

Badge — `callout-tip` for co-developed, `callout-note` for autonomous, always
`icon=false`, always naming session, mode **and model**:

```markdown
::: {.callout-note icon=false}
## Session N · autonomously developed · Claude <Model>
Dataset choice, analytical angle, figures and prose are Claude <Model>'s, produced working
autonomously with no human steering during the session. [How the sessions differ](index.qmd).
:::
```

Then:

- **One argument per page**, built across roughly four to six figures toward a single
  closing idea. Not a tour of a dataset.
- **Say what the data can't say.** Every page earns a short limits passage — a
  `callout-note` or a closing section — naming the confounder, the censoring, or the too-short
  record. This is where an unsupervised session buys back its credibility.
- **Cache the data.** Write the raw pull to `data/<slug>.csv` (or `.json`) and read from
  there, so the page re-renders years later. Cite the source with a real link.
- Code chunks are folded by default (`code-fold: true` site-wide) — write them to be read.
- Add the new page to the right section of `index.qmd` with a one- or two-sentence hook.

## Toolchain

- **R:** use framework R 4.5.2 at
  `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/bin`. This is the only
  install with the full tidyverse. The laptop's default `Rscript` on `PATH` is a stale
  anaconda R 4.1.1, and homebrew R 4.5.2 (which Quarto picks by default) has no tidyverse.
  `_environment` sets `QUARTO_R` for renders; ad-hoc R needs the full path.
- **Available:** tidyverse, `ggridges`, `ggdist`, `patchwork`, leaflet.
  **Not installed:** `gganimate`, `ggrepel`, `BradleyTerry2` (Session 2 hand-rolled
  Bradley–Terry as a no-intercept logistic regression rather than install it).
- **Render gotcha:** rendering several files in one `quarto render a.qmd b.qmd …` command
  can leak the wrong `<title>`/h1 into a page and skip updating others. **Render each changed
  page individually**, then verify with `grep '<title>' docs/<page>.html`.
- **Publishing:** GitHub Pages serves from `docs/` on `main`, so `docs/` and `_freeze/` are
  **committed, not ignored**. A change isn't live until the rendered HTML is committed.
  Site: https://jonminton.github.io/claude-fable-vision-ds-test/

## Working with Jon's live R session

When co-developing, use **pure separation** — do not mirror or reconstruct Jon's live
Positron R session.

- Jon drives interactive EDA in the Positron console; the Variables and Plots panes are his.
- Claude does authoring, refactoring, multi-file edits, shell and git on the files.
- Handoff is **pull-based**: Jon pastes an output when he wants input on it.

No seed-sync, shadow-R, or `show_dev()`-style bridges. Claude's Bash R is a different
process from the live session, so any mirroring scheme diverges the moment Jon does ad-hoc
console work — which is the entire point of interactive EDA.

## Session log

| Session | Date | Mode | Model | Pages |
|---|---|---|---|---|
| 1 | 2026-06-09 – 06-10 | co-developed | Claude Fable 5 | parenting leave · game films · edible plants · twinned cities · oldest people · US births |
| 2 | 2026-06-12 | autonomous | Claude Fable 5 | probability phrases · tortoise island · pi digits · ocean temperature · reflection |

Append a row when a session ends.
