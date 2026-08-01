# Superchat-skeleton homepage rework

**Date:** 2026-08-01
**File touched:** `index.html` (only)
**Reference:** superchat.com's homepage structure — centered hero, icon feature
row driving a switcher panel directly beneath, then a clean section rhythm.
Structure and interaction patterns only; no Superchat copy, imagery, or code.

## Problem

The current page sells well but reads as a conventional two-column SaaS page:
hero copy left, video right, then eight stacked sections. The product switcher
(shipped 2026-08-01) sits mid-page where many visitors never reach it. The
user wants the Superchat pattern: the switcher IS the hero visual, and the
whole page follows that centered, product-first rhythm.

## Honesty constraints (non-negotiable)

Superchat's page leans on assets BotSquirrel does not have. This design does
NOT fabricate substitutes:

- No customer-logo strip, no invented customer counts.
- No testimonials until real ones exist.
- No industry grid — BotSquirrel sells one vertical, and says so proudly.
- No new product claims anywhere; every sentence on the reworked page is
  either existing copy, a condensation of existing copy, or layout-neutral.

## The new page order

```
nav                      unchanged
hero                     centered (reworked)
switcher                 moved up from #product, +1 tab (reworked)
#who    positioning band restyled slim (replaces the social-proof slot)
#how    workflow         content unchanged
#features 6-card grid    content unchanged
#platforms               content unchanged
#start                   content unchanged
#pricing                 content unchanged
#faq                     content unchanged
#about                   content unchanged + receives the squirrel line
#contact                 content unchanged
final CTA + footer       unchanged
```

Sections keep their ids (nav anchors and any external links keep working) and
keep alternating `section` / `section alt` backgrounds in their NEW order —
alternation is reassigned after the move so no two adjacent sections share a
background.

## Section designs

### Hero (centered)

- `.hero-grid` two-column layout is replaced by a single centered column
  (max-width ~46em).
- Eyebrow: unchanged text.
- H1: unchanged text, sized up slightly (clamp to ~44-56px) since it no longer
  shares width with the video card.
- Subhead: ONE paragraph, a condensation of the current two:
  "Never miss a job while you're on the tools. BotSquirrel answers WhatsApp
  and website enquiries from your approved business information — collects
  the postcode, problem, photos and availability, and hands anything
  uncertain to your team instead of guessing."
- The dropped sentence "And like a squirrel with its winter store, every
  enquiry is kept safe and organised until you're ready for it." moves to
  `#about`, appended to the existing founder paragraph block.
- CTA row: both existing buttons, centered. Unchanged labels, hrefs, and the
  `wa-link` class (the WhatsApp link is wired up by existing JS).
- Trust line: unchanged text, centered beneath the CTAs — the "No credit card
  required" slot.

### Switcher (moved + fifth tab)

- The whole `#product` section moves to directly under the hero and keeps its
  id. Its `sec-head` shrinks to a single intro line (the h2 stays for anchor
  and a11y but is restyled smaller): "One workspace for every job enquiry".
- A fifth tab is PREPENDED: 💬 "Live chat", `id="sw-tab-0"`,
  `aria-controls="sw-panel-0"`, with
  `data-line="Try it live — the assistant answers from your own prices and policies, never guessing."`
- Its panel `#sw-panel-0` holds the existing chatcard block (video +
  chat-input footer + demo link) moved verbatim from the hero. The
  `duo-title` line inside the card is removed (its message now lives in the
  tab's data-line); everything else moves unchanged, including autoplay
  attributes and the poster.
- The switcher initialises on the Live chat tab (index 0). The existing IIFE
  already selects index 0 and handles N tabs; no JS logic change is needed —
  only the markup gains a tab/panel pair.
- Panel heading for no-JS state: `<h3 class="sw-panel-h">See it answer a real
  enquiry</h3>`.
- The `.sw-line` wrap backstop: the new data-line is 97 chars — longer than
  the ~83-char budget recorded in the previous spec's implementation notes.
  The min-heights (3.2em desktop / 4.8em under 430px) must be re-verified
  with the five real strings at 1280, 431, 430, 390, 375, and 332px widths;
  if the 97-char line needs 2 lines at desktop widths where others need 1,
  either shorten it below the budget or raise the base min-height — measured,
  not guessed, at implementation time.
- Mobile: five tabs no longer fit 2×2. Below 860px the tab row becomes a
  2-column grid with the fifth tab spanning both columns on its own row
  (`.sw-tab:first-child{grid-column:1/-1}` inside the media query) — Live
  chat reads as the featured tab, which matches its role.
- The video keeps `preload="metadata"` and its poster so the move above the
  fold does not add meaningful page weight beyond what the hero already
  loaded today.

### #who as the credibility band

- Moves to directly under the switcher (the Superchat social-proof slot).
- Keeps h2 + intro + the three trade cards exactly as they are — the section
  merely moves. (A compressed "logo-strip-like" variant was considered and
  rejected: it would weaken a strong section to chase a cosmetic slot.)

### Everything else

- `#how`, `#features`, `#platforms`, `#start`, `#pricing`, `#faq`, `#about`,
  `#contact`, final CTA: markup unchanged except (a) their order per the
  table above, (b) `alt` class reassignment for background alternation,
  (c) nothing for headers — `.sec-head` is already centered globally
  (`index.html:77`), so no CSS change is needed there.
- `#about` gains the squirrel sentence at the end of its existing paragraph.
- Nav links: `#product` still exists; nav order stays as-is (Product,
  How it works, Pricing, Security, FAQ, About) — nav labels don't promise a
  page order.

## CSS approach

- New: `.hero` centered variant (replace `.hero-grid` usage; the class and
  its rules are removed if nothing else uses them — verify with grep).
- The chatcard/video rules (`.chatcard`, `.video-wrap`, `.hero-video`,
  `.chat-input`, `.duo-title`) survive — the card now lives in `sw-panel-0`.
  `.duo-title` becomes unused when the line is removed: delete its rule.
- `.sw-tabs` desktop grid becomes `repeat(5,1fr)` (max-width widens to
  ~900px); the 860px media query gets the fifth-tab spanning rule.
- No hardcoded hexes; existing custom properties only. Breakpoint stays 860px
  (the 430px line-height backstop from the previous feature is orthogonal and
  stays).

## Progressive enhancement & a11y

Unchanged model from the shipped switcher: no-JS renders all five panels
stacked with headings; the IIFE upgrades. All ARIA wiring follows the
existing exact pattern for the new pair. Keyboard nav needs no change (it
iterates the live tabs array).

## Verification

1. Hero renders centered at 1280 and 375; both CTAs work; trust line under
   CTAs.
2. Switcher sits directly under the hero, opens on Live chat with the video
   playing; all five tabs swap correctly; no vertical page shift on any
   switch at 1280/431/430/390/375/332 (re-measured with the new 5-string set).
3. Mobile: 2-col tab grid with Live chat spanning the top row; no overflow.
4. No-JS: five stacked panels with headings; video panel first.
5. Section order matches the table; backgrounds alternate cleanly; every nav
   anchor lands on its section.
6. #about contains the squirrel sentence; hero contains exactly one
   paragraph between h1 and CTAs.
7. No console errors; no horizontal overflow at 332px.
8. grep: no `hero-grid` or `duo-title` references remain if their rules were
   removed.

## Out of scope

- Any other page (pricing.html, chat.html, legal pages).
- New sections (testimonials, logos, industries) — revisit when real assets
  exist.
- Nav changes, chat-widget changes, JS logic changes beyond none.
- Copy rewrites beyond the specified hero condensation and squirrel-line move.
