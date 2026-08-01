# Product Workspace Tab Switcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the four stacked mockup rows in `#product` with a Superchat-style icon tab switcher, where clicking a tab swaps the panel below it.

**Architecture:** Progressive enhancement. The HTML ships as four stacked, headed panels — the current behaviour and the no-JS fallback. A small inline IIFE upgrades it into an ARIA tablist on load by adding a `sw-ready` class that collapses all panels into a single CSS grid cell. Each panel is a content-agnostic slot so a CSS mockup can later be swapped for a real screenshot with no JS or CSS change.

**Tech Stack:** Static HTML/CSS/vanilla JS in a single file (`index.html`). No build step, no framework, no package manager.

## Global Constraints

- **Only `index.html` is modified.** No other page is touched by this feature.
- **All four `.mock` blocks are preserved verbatim.** Their inner markup is moved, never redesigned. All `.mock*` CSS rules stay untouched.
- **No new dependencies, build step, or external assets.** Everything is inline, matching the existing single-file pattern.
- **Existing CSS custom properties only:** `--brand` `#2f6df0`, `--brand-dark` `#1f50c0`, `--brand-soft` `#e8f0fe`, `--ink`, `--ink-soft`, `--ink-faint`, `--line`, `--bg-soft`, `--radius` `14px`. Never hardcode a hex that a token already covers.
- **Breakpoint is `max-width: 860px`** — the value the section already uses.
- **`.shot-note` text stays exactly `Illustrative product view`.** The panels remain illustrations, not screenshots; the disclosure must not be dropped or softened.
- **The site is deployed by `deploy-prod.sh` syncing the repo root to a public S3 bucket.** Any new top-level directory is published unless explicitly excluded.

### Testing note — read before Task 1

This repo has no test framework, no `package.json`, and no build step. A
`pytest`/`jest` red-green cycle is not available and must not be invented.
The equivalent verification loop here is the browser preview: each task ends
by loading the page and confirming named, observable facts. Every task below
states its expected observation concretely so a reviewer can check it without
guessing.

---

### Task 1: Stop publishing internal docs, and add a preview server

This is a prerequisite, not part of the feature: the `docs/` directory added by
the spec would be published to the public bucket, and there is currently no way
to serve the site locally to verify anything.

**Files:**
- Modify: `deploy-prod.sh:37-47` (add `docs` excludes to both sync commands)
- Create: `.claude/launch.json`

**Interfaces:**
- Consumes: nothing.
- Produces: a preview server named `website` on port 4173, used by every later task's verification step.

- [ ] **Step 1: Confirm the bug is real**

Run:
```bash
grep -n 'exclude "docs' deploy-prod.sh || echo "NOT EXCLUDED — docs/ would be published"
```
Expected: prints `NOT EXCLUDED — docs/ would be published`.

- [ ] **Step 2: Add the excludes**

In `deploy-prod.sh`, the first sync command has this line (~line 38):
```
  --exclude "d/*" \
```
Change it to:
```
  --exclude "d/*" --exclude "docs/*" --exclude "*/docs/*" \
```

The second sync command has the same `--exclude "d/*" \` line (~line 46).
Apply the identical change there too.

Both are required: the first sync uploads non-HTML files (which is what `.md`
is), the second uploads HTML. The `*/docs/*` half follows the PATTERN RULE
already documented at line 28 of the script — `--exclude` matches the whole
relative key, so a nested path needs its own glob.

- [ ] **Step 3: Verify both syncs now exclude docs**

Run:
```bash
grep -c 'exclude "docs/\*"' deploy-prod.sh
```
Expected: `2`

- [ ] **Step 4: Create the preview server config**

Create `.claude/launch.json`:
```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "website",
      "runtimeExecutable": "python3",
      "runtimeArgs": ["-m", "http.server", "4173"],
      "port": 4173
    }
  ]
}
```

`.claude/` is already in `.gitignore` and already excluded from both deploy
syncs, so this file is local-only and will never be committed or published.
Confirm with:
```bash
git check-ignore -q .claude/launch.json && echo "ignored ✓"
```
Expected: `ignored ✓`

- [ ] **Step 5: Start the preview and confirm the page loads**

Start the `website` preview server and load `http://localhost:4173/index.html`.
Expected: the current site renders, `#product` shows four stacked mockup rows
with copy alternating left and right. Console has no errors.

- [ ] **Step 6: Commit**

```bash
git add deploy-prod.sh
git commit -m "fix(deploy): stop publishing docs/ to the public bucket"
```

---

### Task 2: Replace the stacked rows with the switcher markup and CSS

Produces the no-JS baseline: four stacked, headed panels. No JavaScript yet.
This state IS the progressive-enhancement fallback, so it must look correct on
its own.

**Files:**
- Modify: `index.html:104-110` (CSS — remove dead rules, add `.sw-*` rules)
- Modify: `index.html:328-395` (markup — the four `.shot-row` blocks)

**Interfaces:**
- Consumes: preview server `website` from Task 1.
- Produces: DOM ids consumed by Task 3's script — `sw-tabs`, `sw-line`, `sw-stage`; tabs `sw-tab-1`..`sw-tab-4` each carrying a `data-line` attribute; panels `sw-panel-1`..`sw-panel-4`. Classes `.sw-tab`, `.sw-panel`, and the `.sw-ready` state class on `#sw-stage`.

- [ ] **Step 1: Replace the CSS block**

In `index.html`, replace lines 104–110 — this block:
```css
  .shot-row{display:grid; grid-template-columns:1fr 1fr; gap:40px; align-items:center; margin-bottom:64px;}
  .shot-row:last-child{margin-bottom:0;}
  .shot-row.flip .shot-copy{order:2;}
  @media(max-width:860px){ .shot-row, .shot-row.flip{grid-template-columns:1fr;} .shot-row.flip .shot-copy{order:0;} }
  .shot-copy h3{font-size:24px; margin:0 0 10px; letter-spacing:-.01em;}
  .shot-copy p{font-size:16px; color:var(--ink-soft); margin:0;}
  .shot-note{font-size:12px; color:var(--ink-faint); margin-top:10px;}
```
with this:
```css
  .shot-note{font-size:12px; color:var(--ink-faint); margin-top:10px;}
  .sw-note{text-align:center; margin-top:16px;}

  /* tab row */
  .sw-tabs{display:grid; grid-template-columns:repeat(4,1fr); gap:12px; max-width:720px; margin:0 auto 24px;}
  .sw-tab{display:flex; flex-direction:column; align-items:center; gap:9px; background:transparent; border:1px solid transparent; border-radius:var(--radius); padding:14px 8px 12px; cursor:pointer; font:inherit; font-size:13.5px; font-weight:600; line-height:1.25; color:var(--ink-soft); text-align:center; transition:background .15s ease, color .15s ease, border-color .15s ease;}
  .sw-tab .ico{width:44px; height:44px; border-radius:11px; background:var(--brand-soft); color:var(--brand); display:grid; place-items:center; font-size:22px; transition:background .15s ease, color .15s ease;}
  .sw-tab:hover{color:var(--ink); background:var(--bg-soft); border-color:var(--line);}
  .sw-tab[aria-selected="true"]{color:var(--brand-dark); background:var(--brand-soft); border-color:transparent;}
  .sw-tab[aria-selected="true"] .ico{background:var(--brand); color:#fff;}

  /* supporting line */
  .sw-line{text-align:center; font-size:17px; color:var(--ink-soft); margin:0 auto 24px; max-width:44em;}

  /* panel stage — no-JS: rows. sw-ready: all panels share one cell */
  .sw-stage{display:grid; gap:40px;}
  .sw-stage.sw-ready{gap:0;}
  .sw-stage.sw-ready .sw-panel{grid-area:1/1;}
  .sw-stage.sw-ready .sw-panel[hidden]{display:block; visibility:hidden;}
  .sw-panel{min-width:0;}
  .sw-panel-h{font-size:24px; margin:0 0 12px; letter-spacing:-.01em;}
  .sw-stage.sw-ready .sw-panel-h{display:none;}
  .sw-stage.sw-ready .sw-panel:not([hidden]){animation:swIn .18s ease-out;}
  @keyframes swIn{from{opacity:0; transform:translateY(6px);} to{opacity:1; transform:none;}}

  @media(max-width:860px){
    .sw-tabs{grid-template-columns:repeat(2,1fr); gap:10px; max-width:420px;}
    .sw-panel-h{font-size:20px;}
  }
  @media(prefers-reduced-motion:reduce){
    .sw-stage.sw-ready .sw-panel:not([hidden]){animation:none;}
    .sw-tab, .sw-tab .ico{transition:none;}
  }
```

Why `visibility:hidden` rather than the default `display:none` for hidden
panels: all panels occupy grid cell `1/1`, so the stage sizes to the tallest
one. A hidden panel must keep contributing its height or the page would jump
when switching tabs. `visibility:hidden` also removes the panel from the
accessibility tree and the tab order, which is the behaviour we want.

`.shot-row`, `.shot-copy`, and `.shot-row.flip` are now unused. They appear in
`index.html` only — no other page references them — so removing them is safe.

- [ ] **Step 2: Replace the markup**

In `index.html`, replace lines **328–395** — the four `<div class="shot-row">`
blocks, starting at the first `<div class="shot-row">` (line 328) and ending at
the `</div>` that closes the last `shot-row flip` (line 395) — with the markup
below.

Be precise about the end of the range. Line 396 is the `</div>` that closes
`.wrap` and line 397 is `</section>`; both must survive. After the edit, the
section must still close with `</div>` then `</section>`.

Each `.mock` element below is copied verbatim from the block it replaces —
do not restyle, reorder, or reword any of them.

```html
      <div class="sw-tabs" id="sw-tabs" role="tablist" aria-label="Workspace views" hidden>
        <button class="sw-tab" type="button" role="tab" id="sw-tab-1" aria-controls="sw-panel-1" aria-selected="true" tabindex="0"
                data-line="Every enquiry arrives organised — customer, postcode, issue, urgency and preferred time at a glance.">
          <span class="ico" aria-hidden="true">📥</span>Enquiries
        </button>
        <button class="sw-tab" type="button" role="tab" id="sw-tab-2" aria-controls="sw-panel-2" aria-selected="false" tabindex="-1"
                data-line="Missing contact or job info gets flagged, so no one turns up to a job half-briefed.">
          <span class="ico" aria-hidden="true">⚠️</span>Missing details
        </button>
        <button class="sw-tab" type="button" role="tab" id="sw-tab-3" aria-controls="sw-panel-3" aria-selected="false" tabindex="-1"
                data-line="Book real slots your team controls — the AI never invents availability.">
          <span class="ico" aria-hidden="true">📅</span>Scheduling
        </button>
        <button class="sw-tab" type="button" role="tab" id="sw-tab-4" aria-controls="sw-panel-4" aria-selected="false" tabindex="-1"
                data-line="Conversations, visits, notes and photos stay attached to the same customer.">
          <span class="ico" aria-hidden="true">👤</span>Customer history
        </button>
      </div>

      <p class="sw-line" id="sw-line" hidden></p>

      <div class="sw-stage" id="sw-stage">

        <!-- Each .sw-panel is a content-agnostic slot. To use a real product
             screenshot later, delete the .mock element inside the panel and
             drop in <img src="..." alt="..."> — no CSS or JS change needed. -->
        <div class="sw-panel" id="sw-panel-1" role="tabpanel" aria-labelledby="sw-tab-1" tabindex="0">
          <h3 class="sw-panel-h">Every enquiry arrives organised</h3>
          <div class="mock" role="img" aria-label="Illustration of the enquiry inbox">
            <div class="mock-bar"><i></i><i></i><i></i><span>Enquiries</span></div>
            <div class="mock-body">
              <div class="m-row"><div><div class="who">Sarah W. · SW11 4EX</div><div class="meta">Boiler losing pressure · photos ×2 · prefers Thu AM</div></div><span class="m-pill new">New</span></div>
              <div class="m-row"><div><div class="who">Tom H. · CR0 2RD</div><div class="meta">Leak under kitchen sink · urgent</div></div><span class="m-pill warn">Needs details</span></div>
              <div class="m-row"><div><div class="who">Priya N. · SE15 3AB</div><div class="meta">Annual boiler service · flexible</div></div><span class="m-pill ok">Booked</span></div>
            </div>
          </div>
        </div>

        <div class="sw-panel" id="sw-panel-2" role="tabpanel" aria-labelledby="sw-tab-2" tabindex="0">
          <h3 class="sw-panel-h">Know what's missing</h3>
          <div class="mock" role="img" aria-label="Illustration of an enquiry detail view">
            <div class="mock-bar"><i></i><i></i><i></i><span>Enquiry · Tom H.</span></div>
            <div class="mock-body">
              <div class="m-field"><span class="k">Issue</span><span class="v">Leak under kitchen sink</span></div>
              <div class="m-field"><span class="k">Postcode</span><span class="v">CR0 2RD</span></div>
              <div class="m-field"><span class="k">Urgency</span><span class="v">Today if possible</span></div>
              <div class="m-field"><span class="k">Phone</span><span class="v" style="color:var(--warn)">Missing — ask customer</span></div>
              <div class="m-field"><span class="k">Photos</span><span class="v" style="color:var(--warn)">Missing — ask customer</span></div>
            </div>
          </div>
        </div>

        <div class="sw-panel" id="sw-panel-3" role="tabpanel" aria-labelledby="sw-tab-3" tabindex="0">
          <h3 class="sw-panel-h">Schedule the right engineer</h3>
          <div class="mock" role="img" aria-label="Illustration of the engineer calendar">
            <div class="mock-bar"><i></i><i></i><i></i><span>Thursday · Engineers</span></div>
            <div class="mock-body">
              <div class="m-cal">
                <div class="t">09:00</div><div><div class="m-slot a">Dave — Boiler service, SE15</div></div>
                <div class="t">11:00</div><div><div class="m-slot free">Available</div></div>
                <div class="t">13:30</div><div><div class="m-slot b">Aiden — Leak repair, CR0</div></div>
                <div class="t">16:00</div><div><div class="m-slot free">Available</div></div>
              </div>
            </div>
          </div>
        </div>

        <div class="sw-panel" id="sw-panel-4" role="tabpanel" aria-labelledby="sw-tab-4" tabindex="0">
          <h3 class="sw-panel-h">Keep the full customer history</h3>
          <div class="mock" role="img" aria-label="Illustration of a customer record">
            <div class="mock-bar"><i></i><i></i><i></i><span>Customer · Sarah W.</span></div>
            <div class="mock-body">
              <div class="m-log"><span class="d">Today</span><span>Enquiry: boiler losing pressure · photos attached</span></div>
              <div class="m-log"><span class="d">Mar 2026</span><span>Job completed: radiator valve replacement</span></div>
              <div class="m-log"><span class="d">Nov 2025</span><span>Annual boiler service · reminder scheduled</span></div>
            </div>
          </div>
        </div>

      </div>

      <p class="shot-note sw-note">Illustrative product view</p>
```

- [ ] **Step 3: Verify no dead classes remain**

Run:
```bash
grep -c 'shot-row\|shot-copy' index.html
```
Expected: `0`

- [ ] **Step 4: Verify the no-JS baseline in the browser**

Reload `http://localhost:4173/index.html`.

Expected, all of which must hold:
- `#product` shows **four stacked panels**, each with a visible `<h3>` heading above its mockup.
- The tab row is **not visible** (it carries `hidden`, and no script has revealed it yet).
- The supporting line is **not visible**.
- One `Illustrative product view` note sits centred at the bottom of the section.
- No console errors.

This is exactly what a visitor with JavaScript disabled will see. It must look
deliberate, not broken.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat(site): switcher markup and styles for the product section"
```

---

### Task 3: Add the JavaScript that upgrades it into a tab switcher

**Files:**
- Modify: `index.html` (add the IIFE to the existing inline `<script>` near the end of the file, alongside the existing `#year` script)

**Interfaces:**
- Consumes: ids `sw-tabs`, `sw-line`, `sw-stage`; `.sw-tab` buttons with `data-line` and `aria-controls`; `.sw-panel` elements — all from Task 2.
- Produces: the running switcher. No exported names; the IIFE leaks nothing into global scope.

- [ ] **Step 1: Add the script**

Append this inside the existing inline `<script>` block near the bottom of
`index.html` (the one that sets `#year`):

```js
  /* product workspace switcher — upgrades the stacked panels into tabs */
  (function(){
    var tablist = document.getElementById('sw-tabs');
    var stage   = document.getElementById('sw-stage');
    var line    = document.getElementById('sw-line');
    if(!tablist || !stage) return;

    var tabs   = Array.prototype.slice.call(tablist.querySelectorAll('.sw-tab'));
    var panels = Array.prototype.slice.call(stage.querySelectorAll('.sw-panel'));
    if(!tabs.length || tabs.length !== panels.length) return;

    function select(i, moveFocus){
      for(var n = 0; n < tabs.length; n++){
        var on = (n === i);
        tabs[n].setAttribute('aria-selected', on ? 'true' : 'false');
        tabs[n].tabIndex = on ? 0 : -1;
        panels[n].hidden = !on;
      }
      if(line) line.textContent = tabs[i].getAttribute('data-line') || '';
      if(moveFocus) tabs[i].focus();
    }

    tabs.forEach(function(tab, i){
      tab.addEventListener('click', function(){ select(i, false); });
    });

    stage.classList.add('sw-ready');
    tablist.hidden = false;
    if(line) line.hidden = false;
    select(0, false);
  })();
```

The `tabs.length !== panels.length` guard matters: if someone later adds a tab
but forgets its panel, the switcher disables itself and the page falls back to
the stacked layout rather than throwing on every click.

- [ ] **Step 2: Verify switching works**

Reload the page. Expected:
- The tab row is now visible: four tabs, `Enquiries` active with a solid blue
  icon tile, the other three with pale blue tiles.
- One line of supporting text sits under the tabs, reading
  `Every enquiry arrives organised — customer, postcode, issue, urgency and preferred time at a glance.`
- Exactly **one** panel is visible, and no `<h3>` headings are visible.
- Clicking `Scheduling` swaps the panel to the engineer calendar and the line to
  `Book real slots your team controls — the AI never invents availability.`
- Clicking each of the four tabs shows its matching mockup.
- No console errors.

- [ ] **Step 3: Verify the stage does not jump height**

With the browser at desktop width, click through all four tabs and watch the
`Illustrative product view` note and the section below it.

Expected: the note does **not** move vertically as you switch tabs. All panels
share one grid cell, so the stage is always as tall as the tallest panel.

If it does move, `.sw-stage.sw-ready .sw-panel[hidden]{display:block; visibility:hidden;}`
from Task 2 is missing or being overridden.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat(site): tab switching for the product workspace views"
```

---

### Task 4: Add keyboard navigation

Mouse users can already switch tabs. This makes the switcher usable from the
keyboard, matching the ARIA authoring practices for a tablist.

**Files:**
- Modify: `index.html` (extend the IIFE added in Task 3)

**Interfaces:**
- Consumes: the `tabs` array and `select(i, moveFocus)` function defined in Task 3.
- Produces: no new names.

- [ ] **Step 1: Add the keydown handler**

In the IIFE from Task 3, replace this block:
```js
    tabs.forEach(function(tab, i){
      tab.addEventListener('click', function(){ select(i, false); });
    });
```
with:
```js
    tabs.forEach(function(tab, i){
      tab.addEventListener('click', function(){ select(i, false); });
      tab.addEventListener('keydown', function(e){
        var next = null;
        if(e.key === 'ArrowRight')     next = (i + 1) % tabs.length;
        else if(e.key === 'ArrowLeft') next = (i - 1 + tabs.length) % tabs.length;
        else if(e.key === 'Home')      next = 0;
        else if(e.key === 'End')       next = tabs.length - 1;
        if(next === null) return;
        e.preventDefault();
        select(next, true);
      });
    });
```

`select()` already maintains the roving tabindex — the active tab is `0`, the
rest `-1` — so Tab enters the tab row once and arrow keys move within it. That
is the expected tablist behaviour, not a bug.

- [ ] **Step 2: Verify keyboard behaviour**

Reload. Press Tab repeatedly until the `Enquiries` tab has a visible focus ring.
Then:

| Key | Expected |
|-----|----------|
| Arrow Right | `Missing details` becomes active, is focused, and its panel shows |
| Arrow Right ×3 more | wraps from `Customer history` back to `Enquiries` |
| Arrow Left | moves backwards, wrapping the other way |
| `End` | jumps to `Customer history` |
| `Home` | jumps back to `Enquiries` |
| Tab (from an active tab) | leaves the tab row entirely — does not step through the other three tabs |

The focus ring must be clearly visible at every step; the site defines
`:focus-visible{outline:2px solid var(--brand); outline-offset:2px;}`.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat(site): keyboard navigation for the workspace switcher"
```

---

### Task 5: Full verification sweep

No code changes unless a check fails. This is the gate before the branch is
considered done, and it walks the spec's six-point verification list.

**Files:**
- Modify: `index.html` only if a check fails.

**Interfaces:**
- Consumes: everything from Tasks 1–4.
- Produces: a verified branch.

- [ ] **Step 1: Desktop pass**

At desktop width, confirm (numbers refer to the spec's verification list):
- **(1)** Each of the four tabs swaps the panel below it.
- **(2)** The stage height does not change between tabs.
- **(3)** Arrow keys cycle; `Home`/`End` jump to the ends; focus ring stays visible.
- **(6)** Console is clean — no errors or warnings.

- [ ] **Step 2: Mobile pass**

Resize the viewport to 375×812. Confirm:
- **(4)** The tab row is a **2×2 grid** with all four tabs visible — no
  horizontal scrolling, no tabs cut off, no overlap between icon and label.
- The mockups fit within the viewport without horizontal page scroll.
- Switching tabs still works by tap.

- [ ] **Step 3: No-JS pass**

Disable JavaScript for the page and reload. Confirm:
- **(5)** `#product` renders as four stacked panels, each with its `<h3>`
  heading, the tab row and supporting line both hidden, and the
  `Illustrative product view` note at the bottom.

Re-enable JavaScript afterwards.

- [ ] **Step 4: Reduced-motion pass**

Set the OS or browser to "reduce motion" and reload. Confirm switching tabs
swaps the panel **instantly**, with no fade or slide.

- [ ] **Step 5: Regression check on the rest of the page**

Scroll the whole page top to bottom. Confirm nothing outside `#product` shifted
— in particular that `#how` above it and `#features` below it are unchanged, and
that removing the `.shot-row` CSS broke no other section.

Run:
```bash
grep -c 'shot-row\|shot-copy' index.html
```
Expected: `0`

Run:
```bash
grep -c 'Illustrative product view' index.html
```
Expected: `1`

- [ ] **Step 6: Commit any fixes**

If Steps 1–5 required changes:
```bash
git add index.html
git commit -m "fix(site): address switcher verification findings"
```
If nothing failed, skip this step — do not create an empty commit.

---

## Out of scope

- Real product screenshots. The admin UI is mid-rework; the slots are built to
  receive them later.
- Any change to `#features`, the hero, or any other section.
- Autoplay, URL-hash deep-linking to a tab, or swipe gestures.
- The `hello@botsquirrel.com` change already made across the site — that is
  unrelated to this feature and is uncommitted in the working tree alongside
  pre-existing edits to the legal pages.
