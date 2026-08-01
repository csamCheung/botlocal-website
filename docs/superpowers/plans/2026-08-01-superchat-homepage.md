# Superchat-Skeleton Homepage Rework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild index.html on the Superchat homepage skeleton — centered hero, the workspace switcher promoted to hero visual with a new Live chat tab hosting the demo video, and the remaining sections reordered onto a clean alternating rhythm.

**Architecture:** Pure restructure of a single static file. The hero collapses from a two-column grid to one centered column; the `#product` switcher section moves up beneath it and gains a prepended tab/panel pair whose panel receives the hero's demo-video card verbatim; sections then reorder with backgrounds reassigned. The switcher's JS needs zero logic changes — it already iterates N tabs.

**Tech Stack:** Static HTML/CSS/vanilla JS in `index.html`. No build step, no dependencies.

## Global Constraints

- **Only `index.html` is modified.**
- **No fabricated content:** no customer logos, testimonials, counts, industries, or new product claims. Every sentence is existing copy or the exact condensations written in this plan.
- **Existing CSS custom properties only** (`--brand`, `--brand-dark`, `--brand-soft`, `--ink`, `--ink-soft`, `--ink-faint`, `--line`, `--bg-soft`, `--radius`); never hardcode a hex a token covers.
- **Layout breakpoint stays `max-width:860px`.** The 430px `.sw-line` backstop query is a separate concern and stays.
- **All section `id`s are preserved** — nav anchors must keep working.
- **The demo-video card moves verbatim** (same `<video>` attributes incl. `preload="metadata"` and poster; same demo href) except its `.duo-title` line, which is deleted.
- **The switcher initialises on the Live chat tab** (index 0 — the IIFE already selects index 0).
- **Switching tabs must never shift the page vertically** at any tested width. The `.sw-line` min-height backstops (3.2em / 4.8em@430px) are tuned to the current four strings; the new fifth string changes the set, so the backstops must be re-measured, not assumed.
- **Working tree caution:** `privacy.html`, `refund.html`, `security.html`, `terms.html`, `dpa.html` carry uncommitted user edits. Never stage or touch them; stage only `index.html`.

### Verification environment (all tasks)

No test framework exists. Verification is the browser preview: start
`python3 -m http.server 4173 --bind 127.0.0.1` in the site root (background),
open `http://127.0.0.1:4173/index.html` in the in-app browser via
`preview_start({url})` — NOT `preview_start({name:"website"})`, which does not
resolve in this environment. Known pane quirks: query-bust after every edit
(`?t=<n>`); call `resize_window` with explicit dimensions before geometric
checks; desktop screenshots come back blank when scrolled — computed-style /
`getBoundingClientRect()` / `read_page` evidence is the accepted substitute
(mobile-width screenshots do render). Kill the server when the task ends.

Line numbers below were measured at commit `e101dd2`. Verify each anchor by
content (grep) before editing — match on content, not just numbers.

---

### Task 1: Above-the-fold rework — centered hero + switcher with Live chat tab

One coherent deliverable: everything a visitor sees before scrolling. Ends
fully working; the page below the switcher is untouched.

**Files:**
- Modify: `index.html:56-72` (hero CSS), `index.html:108` and `132-134`
  (switcher tab-grid CSS), `index.html:288-313` (hero markup),
  `index.html:355-360` (product sec-head), `index.html:361` (tab row start),
  `index.html:381` (stage start), `index.html:656` (about bio — squirrel line)

**Interfaces:**
- Consumes: the shipped switcher contract — ids `sw-tabs`, `sw-line`,
  `sw-stage`, tabs `sw-tab-1..4` with `data-line`, panels `sw-panel-1..4`;
  IIFE selects index 0 on init and handles N tabs via its length guard.
- Produces: new ids `sw-tab-0` / `sw-panel-0` (Live chat, first in DOM); the
  hero markup pattern `.hero > .wrap > .hero-center`; `#product` still in its
  ORIGINAL page position (Task 2 moves it). Task 3 relies on `.hero-grid` and
  `.duo-title` being unused after this task.

- [ ] **Step 1: Hero CSS — centered column**

Replace lines 56-57:
```css
  .hero{padding:64px 0 48px;}
  .hero-grid{display:grid; grid-template-columns:1.05fr .95fr; gap:48px; align-items:center;}
```
with:
```css
  .hero{padding:64px 0 40px;}
  .hero-center{max-width:46em; margin:0 auto; text-align:center;}
  .hero-center h1{font-size:clamp(34px,5vw,54px);}
  .hero-center .subhead{margin-left:auto; margin-right:auto;}
  .hero-center .cta-row{justify-content:center;}
  .hero-center .trust{justify-content:center;}
```
Then in the 860px media query (line ~242), replace
```css
    .hero-grid{grid-template-columns:1fr; gap:32px;}
```
with
```css
    .hero-center h1{font-size:clamp(28px,8vw,34px);}
```
Do NOT delete the `.subhead`/`.sub`/`.cta-row`/`.trust` base rules — the
centered variant layers on top of them. (`.sub` becomes unused in the hero but
its rule may have other users; Task 3 audits it.)

- [ ] **Step 2: Hero markup — one centered column, video card removed**

Replace the hero's inner markup (lines 289-312: from `<div class="wrap hero-grid">`
through the `</a>` closing the chatcard and its wrapping `</div>`) with:

```html
    <div class="wrap">
      <div class="hero-center">
        <span class="eyebrow">Built for UK plumbing &amp; heating businesses</span>
        <h1 id="hero-h">From missed enquiry to booked job — without stopping work</h1>
        <p class="subhead">Never miss a job while you're on the tools. BotSquirrel answers WhatsApp and website enquiries from your approved business information — collects the postcode, problem, photos and availability, and hands anything uncertain to your team instead of guessing.</p>
        <div class="cta-row">
          <a class="btn btn-brand" href="https://app.botsquirrel.com/demo/trades" target="_blank" rel="noopener"><span aria-hidden="true">💬</span><span>Try the plumbing demo</span></a>
          <a class="btn btn-wa wa-link" href="#" target="_blank" rel="noopener"><span class="wa-ico" aria-hidden="true">🟢</span><span>Book a 15-minute walkthrough</span></a>
        </div>
        <div class="trust"><span class="star" aria-hidden="true">★</span><span>Enquiries · customer records · scheduling · follow-ups, in one workspace</span></div>
      </div>
    </div>
```

The chatcard block (lines 302-311) is being MOVED, not deleted — hold its
content for Step 4. Both CTAs keep their exact classes and hrefs (`wa-link` is
wired by existing JS).

- [ ] **Step 3: Switcher sec-head slims down**

In `#product` (line ~355), replace the sec-head block:
```html
      <div class="sec-head">
        <h2 id="product-h">One workspace for every job enquiry</h2>
        <p>What your team sees once the AI has done the collecting.</p>
      </div>
```
with:
```html
      <div class="sec-head" style="margin-bottom:24px">
        <h2 id="product-h" style="font-size:22px">One workspace for every job enquiry</h2>
      </div>
```
(The h2 survives for the `aria-labelledby` and the `#product` anchor; it
shrinks because the hero h1 above now carries the weight. Inline styles are
acceptable here — the page already uses them for one-off cases, e.g. the
chatcard.)

- [ ] **Step 4: Prepend the Live chat tab and panel**

In the tab row (`#sw-tabs`), insert BEFORE the `sw-tab-1` button:
```html
        <button class="sw-tab" type="button" role="tab" id="sw-tab-0" aria-controls="sw-panel-0" aria-selected="true" tabindex="0"
                data-line="Try it live — the assistant answers from your own prices and policies, never guessing.">
          <span class="ico" aria-hidden="true">💬</span>Live chat
        </button>
```
and change `sw-tab-1`'s attributes from `aria-selected="true" tabindex="0"` to
`aria-selected="false" tabindex="-1"` (there must be exactly one selected tab
in the served HTML, and it is now tab 0).

In the stage (`#sw-stage`), insert BEFORE the `sw-panel-1` div (keep the
existing slot-comment above `sw-panel-1` where it is):
```html
        <div class="sw-panel" id="sw-panel-0" role="tabpanel" aria-labelledby="sw-tab-0" tabindex="0">
          <h3 class="sw-panel-h">See it answer a real enquiry</h3>
          <a class="chatcard" href="https://app.botsquirrel.com/demo/trades" target="_blank" rel="noopener" style="display:block;cursor:pointer;max-width:520px;margin:0 auto" aria-label="Try the live BotSquirrel demo">
            <div class="video-wrap">
              <video class="hero-video" autoplay muted loop playsinline preload="metadata" poster="demo-poster-en.jpg" aria-hidden="true">
                <source src="botsquirrel-demo-en.mp4" type="video/mp4">
              </video>
            </div>
            <div class="chat-input"><span>💬 Try the live demo — see how it answers</span><span class="send">➤</span></div>
          </a>
        </div>
```
This is the hero chatcard verbatim MINUS the `.duo-title` div, PLUS
`max-width:520px;margin:0 auto` appended to its existing inline style so the
card doesn't stretch to the full stage width.

- [ ] **Step 5: Tab-grid CSS for five tabs**

Replace line 108:
```css
  .sw-tabs{display:grid; grid-template-columns:repeat(4,1fr); gap:12px; max-width:720px; margin:0 auto 24px;}
```
with:
```css
  .sw-tabs{display:grid; grid-template-columns:repeat(5,1fr); gap:12px; max-width:900px; margin:0 auto 24px;}
```
In the 860px media query (line ~132), replace:
```css
    .sw-tabs{grid-template-columns:repeat(2,1fr); gap:10px; max-width:420px;}
```
with:
```css
    .sw-tabs{grid-template-columns:repeat(2,1fr); gap:10px; max-width:420px;}
    .sw-tabs .sw-tab:first-child{grid-column:1/-1;}
```
(Live chat spans the top row full-width; the four workspace tabs sit 2×2
beneath it.)

- [ ] **Step 6: Squirrel line moves to #about**

In the about bio paragraph (line ~656), change the end of:
```
...and keep supporting it after it goes live. Before you commit, reach me anytime on LinkedIn or WhatsApp.
```
to:
```
...and keep supporting it after it goes live. And like a squirrel with its winter store, every enquiry is kept safe and organised until you're ready for it. Before you commit, reach me anytime on LinkedIn or WhatsApp.
```

- [ ] **Step 7: Verify in the browser**

Start the server, open the page (query-busted). Expected:
- Hero: eyebrow, h1, ONE paragraph, two CTAs, trust line — all centered; no
  video in the hero.
- Directly below: the slim "One workspace…" line, then FIVE tabs with Live
  chat first and active (solid blue tile), the supporting line
  "Try it live — the assistant answers from your own prices and policies, never guessing.",
  and the demo video playing inside a centered card. Clicking the other four
  tabs swaps to their mocks; clicking back restores the video.
- `#product` is still in its original position relative to `#how` (the MOVE
  happens in Task 2) — that is expected at this stage.
- At 375px: Live chat tab full-width on top, 2×2 grid below, no overflow.
- No console errors. `#about` contains the squirrel sentence (grep).

- [ ] **Step 8: Commit**

```bash
git add index.html
git commit -m "feat(site): centered hero + Live chat tab — switcher becomes the hero visual"
```

---

### Task 2: Section reorder and background rhythm

**Files:**
- Modify: `index.html` — `<main>` children order and `section`/`section alt`
  classes only. No content edits.

**Interfaces:**
- Consumes: Task 1's final markup (switcher owns the video panel).
- Produces: the final page order Task 3 and 4 verify against.

- [ ] **Step 1: Reorder sections inside `<main>`**

Cut and paste whole `<section>…</section>` blocks (each is self-contained)
into this order after the hero:

1. `#product` (switcher — moves up from below `#how`)
2. `#who`
3. `#how`
4. `#features`
5. `#platforms`
6. `#start`
7. `#pricing`
8. `#faq`
9. `#about`
10. `#contact`
11. final CTA section (the id-less `<section class="section">` before the footer)

Move blocks verbatim — the HTML comments above each section (`<!-- PRODUCT
SCREENS -->` etc.) move with their sections.

- [ ] **Step 2: Reassign `alt` for clean alternation**

`#product` stays PLAIN — it must read as a continuation of the hero
(Superchat's pattern), and `.sw-tab:hover` uses `--bg-soft`, which would
vanish on an alt background. Alternation starts at `#who`:

| Section | Class |
|---|---|
| #product | `section` |
| #who | `section alt` |
| #how | `section` |
| #features | `section alt` |
| #platforms | `section` |
| #start | `section alt` |
| #pricing | `section` |
| #faq | `section alt` |
| #about | `section` |
| #contact | `section alt` |
| final CTA | `section` |

(This also fixes the pre-existing double-plain at contact→final-CTA.)
`.price.popular` keeps its white card on the now-plain `#pricing` — fine,
cards carry their own `#fff` background.

- [ ] **Step 3: Verify**

- `grep -n '<section class="section' index.html` — order and classes match
  the table exactly.
- In the browser: scroll the whole page; backgrounds alternate
  white/soft/white… from `#who` down with no two adjacent sections sharing a
  background; every nav link (`Product`, `How it works`, `Pricing`,
  `Security`→security.html, `FAQ`, `About`) lands correctly; nothing below
  the fold looks broken.
- No console errors.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat(site): reorder sections onto the Superchat rhythm"
```

---

### Task 3: Backstop re-measure and CSS cleanup

**Files:**
- Modify: `index.html` — `.sw-line` min-heights only if measurement demands;
  removal of now-dead CSS rules.

**Interfaces:**
- Consumes: the five shipped `data-line` strings; the `.sw-line` backstop
  rules at lines ~117 and ~139 and their comments.
- Produces: verified page-stability numbers Task 4 re-checks, and a file with
  no dead hero rules.

- [ ] **Step 1: Measure the five-string wrap behaviour**

With the server running, at each of 1280, 431, 430, 390, 375, 332 px widths:
read `getBoundingClientRect().top` of `#sw-stage` and of the `.sw-note`
element while selecting each of the five tabs in turn (via
`javascript_tool`). Record the numbers. PASS = tops identical across all five
tabs at every width. Measure rendered line counts of `#sw-line` per tab via
`Range.getClientRects()` (offsetHeight cannot distinguish under min-height).

- [ ] **Step 2: Fix only if a width fails**

If the new fifth string wraps past the reserved boxes at some width: first
try shortening the Live chat `data-line` to
`"Try it live — it answers from your prices and policies, never guessing."`
(74 chars, inside the ~83-char budget recorded in the previous feature's
spec notes); re-measure. Only if a shortfall remains, raise the affected
`min-height` by exactly one line-box (3.2em→4.8em, or 4.8em→6.4em under
430px) and update both CSS comments' rationale. Do not change anything if
Step 1 passed everywhere.

- [ ] **Step 3: Remove dead CSS**

Task 1 already removed the `.hero-grid` rules (both the base rule and its
860px media-query line) — verify with `grep -c 'hero-grid' index.html` → 0,
and if any straggler remains, delete it. Then remove these, verifying each
with grep first (zero markup hits outside the CSS itself):
- `.duo-title` rule (old line 70) — its only markup user was the deleted
  chatcard title line.
- `.sub` rule (old line 61) — ONLY if `grep -c 'class="sub"' index.html`
  shows no remaining users; the hero's second paragraph was its only user at
  plan time, but verify.

`.chatcard`, `.video-wrap`, `.hero-video`, `.chat-input` all still have users
(the Live chat panel) — keep.

- [ ] **Step 4: Verify + commit**

`grep -c 'hero-grid\|duo-title' index.html` → 0. Page still renders
identically in the browser (query-busted reload, console clean).

```bash
git add index.html
git commit -m "chore(site): re-measure switcher backstops for five tabs, drop dead hero CSS"
```
(If Step 2 changed values, use
`fix(site): re-tune the supporting-line backstop for the five-tab set` instead.)

---

### Task 4: Full verification sweep

No code changes unless a check fails.

**Files:**
- Modify: `index.html` only if a check fails.

- [ ] **Step 1: Desktop pass (1280×900)**

- Hero centered; exactly one `<p>` between h1 and the CTA row; both CTAs
  present with original hrefs; trust line beneath.
- Switcher directly under hero, Live chat active on load, video present
  (poster loads; element exists with `autoplay muted loop playsinline`).
- All five tabs swap; stage top/note top identical across all five;
  arrow keys cycle through all five with wraparound; Home/End reach
  tabs 0 and 4; modifier chords (e.g. metaKey+ArrowLeft) do NOT switch tabs.
- Console clean.

- [ ] **Step 2: Mobile pass (375×812)**

- Live chat tab spans the top row; 2×2 beneath; no horizontal overflow
  (`scrollWidth === innerWidth`).
- Video card fits the viewport; tap-switching works; stage stable across
  all five tabs.

- [ ] **Step 3: Served-document (no-JS) pass**

Fetch `index.html` fresh and DOMParse: `#sw-tabs` and `#sw-line` carry
`hidden`; `#sw-stage` lacks `sw-ready`; FIVE `.sw-panel` elements all
un-hidden, five `.sw-panel-h` headings present, video panel first; exactly
one `aria-selected="true"` tab (sw-tab-0).

- [ ] **Step 4: Structure pass**

- Section order + alt classes match Task 2's table (grep).
- Every `aria-labelledby` target exists; DOMParser reports no errors; 11
  `section` elements inside `<main>` plus hero.
- `grep -c 'Illustrative product view' index.html` → 1 (still under the
  stage, still accurate — the mocks remain illustrations; the video panel is
  NOT a real recording but a stylised re-render of a demo-tenant conversation
  (real bot answers, scripted enquiry, edited for length — see
  `render-demo-video.js`, which screenshots `demo-video-source.html` frame by
  frame), so it needs its own accurate caption rather than the mock note. But
  confirm the note visually reads as belonging to the mock panels, not the
  video. If it reads wrong on the video tab, move the note INTO the four mock
  panels as a per-panel caption and delete the shared one — then re-verify
  stage stability, since panel heights change).
- `#about` contains "like a squirrel with its winter store" once; the hero
  does not contain it.

- [ ] **Step 5: Commit only if fixes were needed**

```bash
git add index.html
git commit -m "fix(site): address homepage-rework verification findings"
```

---

## Out of scope

- pricing.html, chat.html, demo.html, legal pages.
- Testimonials/logos/industry sections.
- Any JS logic change (markup-only tab addition).
- The uncommitted legal-page edits in the working tree.
