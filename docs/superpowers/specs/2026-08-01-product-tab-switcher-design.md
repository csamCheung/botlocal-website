# Product workspace tab switcher

**Date:** 2026-08-01
**File touched:** `index.html` (only)
**Reference:** Superchat's homepage feature switcher — an icon tab row that swaps the panel below it.

## Problem

The `#product` section stacks four workspace views vertically. Each is a
hand-built HTML/CSS mockup paired with a paragraph of copy, alternating
left/right. It works, but it costs a lot of vertical scrolling and none of the
four views gets to feel like the product's main event.

## Solution

Replace the four stacked rows with a single tab switcher. Four icon tabs across
the top; clicking one swaps the panel below.

### Structure

```
#product
  ├─ .sec-head          unchanged
  ├─ .sw-tabs           role="tablist"  — 4 buttons, emoji icon above a short label
  ├─ .sw-line           one condensed sentence, swaps with the active tab
  ├─ .sw-stage          4 × .sw-panel role="tabpanel"   ← content-agnostic slot
  └─ .shot-note         "Illustrative product view"
```

### Tabs

The existing paragraphs condense to one line each. The section is visual-first,
so the panel carries the message and the line supports it.

| Icon | Label | Line |
|------|-------|------|
| 📥 | Enquiries | Every enquiry arrives organised — customer, postcode, issue, urgency and preferred time at a glance. |
| ⚠️ | Missing details | Missing contact or job info gets flagged, so no one turns up to a job half-briefed. |
| 📅 | Scheduling | Book real slots your team controls — the AI never invents availability. |
| 👤 | Customer history | Conversations, visits, notes and photos stay attached to the same customer. |

Each panel keeps its existing `.mock` markup verbatim. No mock is redesigned.

### Visual language

Tab icons reuse the `.feat .ico` treatment already in the stylesheet: 44px
rounded square, `--brand-soft` fill, `--brand` glyph. The active tab inverts to
a solid `--brand` fill with a white glyph. This makes the switcher read as part
of the existing design rather than an import from another site.

### Behaviour

- Click or tap switches tabs. No autoplay or auto-advance.
- Panel swap is a ~180ms fade-and-rise, suppressed under
  `prefers-reduced-motion: reduce`.
- All four panels share one CSS grid cell, with inactive panels hidden. The
  stage therefore sizes to the tallest panel and the page does not jump in
  height when switching tabs.

### Accessibility

- `role="tablist"` on the tab row, `role="tab"` on each button, `role="tabpanel"`
  on each panel.
- `aria-selected` tracks the active tab. Each tab carries `aria-controls`
  pointing at its panel's id; each panel carries `aria-labelledby` pointing back
  at its tab's id.
- Roving tabindex: the active tab is `tabindex="0"`, the rest `tabindex="-1"`.
- Arrow Left / Arrow Right cycle tabs with wraparound; Home and End jump to the
  first and last.
- Hidden panels use the `hidden` attribute so they leave the accessibility tree.

This matches the accessibility level already set in `index.html`, which uses
`aria-labelledby` on every section and a `#top` skip target.

### Progressive enhancement

The HTML ships with every panel visible and stacked — the current behaviour.
A script upgrades it into a tab switcher on load. If the script fails or is
blocked, the section degrades to today's design and all four panels' content
remains present in the document for search engines.

### Responsive

At `max-width: 860px` (the breakpoint the section already uses) the tab row
becomes a 2×2 grid. With only four tabs this keeps all of them visible and
avoids a horizontally scrolling strip that hides options offscreen.

### Designed for replacement

The admin UI is still being reworked, so these mockups are temporary.
`.sw-panel` is a bare slot that makes no assumptions about its contents.
Replacing a CSS mockup with a real screenshot later means deleting the inner
`.mock` element and dropping in an `<img>` — no JavaScript, CSS, or structural
change. An HTML comment at the first slot records this.

### Cleanup

`.shot-row`, `.shot-copy`, and `.shot-row.flip` rules (`index.html` lines
104–110, including the 860px media query on line 107) become unused once the
rows are gone and are removed. Verified: those three classes appear in
`index.html` only, in no other page. All `.mock*` rules stay untouched — the
mockups still use them.

## Accepted trade-off

The visual-only layout drops roughly four paragraphs of body copy, condensed to
one line each. This loses some of the strongest register on the page (the
"boiler packs up at 11pm" voice) and thins the section's indexable text. Chosen
deliberately for the visual impact; recorded here so the trade is explicit.

`.shot-note` stays. The panels are still illustrations, not screenshots, and the
disclosure remains accurate until real screenshots replace them.

## Verification

Run the page in the browser preview and confirm:

1. Each of the four tabs swaps the panel below it.
2. Stage height does not change between tabs — no page jump.
3. Arrow keys cycle tabs; Home and End jump to the ends; focus stays visible.
4. At mobile width the tab row is a 2×2 grid with all four tabs visible.
5. With JavaScript disabled, the section renders as four stacked panels.
6. No console errors.

## Out of scope

- Real product screenshots — the admin UI is mid-rework.
- Any change to `#features`, the hero, or any other section.
- Autoplay, deep-linking a tab via URL hash, or swipe gestures.

## Implementation notes (deviations from the design above)

Recorded at implementation time — the code is the source of truth.

- Tab 1's supporting line shipped as "Customer, postcode, issue, urgency and preferred time — every enquiry arrives organised." (88 chars). The original 100-char line wrapped to two lines at desktop widths while the other three stayed on one, shifting everything below the switcher by one line-box when switching tabs.
- `.sw-line` carries `min-height:3.2em` (2 line-boxes at the site's 17px/1.6 metrics), raised to `4.8em` (3 line-boxes) under `@media(max-width:430px)`, so differing wrap counts between tabs can never shift the page. These values are tuned to the current four `data-line` strings — lengthening any of them past ~83 characters requires re-checking the wrap counts.
- `.sw-tabs[hidden]{display:none;}` exists because the author-level `display:grid` on `.sw-tabs` would otherwise defeat the UA stylesheet's `[hidden]` rule, making the tab row visible in the no-JS state.
- The contact-email change (hello@botsquirrel.com) landed on this branch for index.html and pricing.html; the legal pages carry the same change uncommitted alongside unrelated in-flight edits.
