# Meta Tech Provider enrolment — paste-ready checklist

Everything machine-checkable is done and verified live. What remains needs your
Facebook login, so it has to be you clicking. Work top to bottom.

**Entity of record (must match everywhere):**

| Field | Value |
| --- | --- |
| Legal name | BotSquirrel Ltd |
| Company number | 17364331 |
| Incorporated | 27 July 2026, England & Wales |
| Registered office | 71–75 Shelton Street, Covent Garden, London, WC2H 9JQ, United Kingdom |
| Website | https://botsquirrel.com |
| Contact email | hello@botsquirrel.com |
| Contact WhatsApp | +44 7472 323783 |
| Existing WABA | 988165394049282 |

**URLs Meta asks for — all verified live 2026-08-04:**

| Meta field | URL |
| --- | --- |
| Privacy Policy URL | https://botsquirrel.com/privacy.html |
| Terms of Service URL | https://botsquirrel.com/terms.html |
| User Data Deletion (Instructions URL) | https://botsquirrel.com/data-deletion.html |
| Data Processing Addendum (if asked) | https://botsquirrel.com/dpa.html |
| Security overview (if asked) | https://botsquirrel.com/security.html |

---

## Step 0 — Fix the app you're about to submit (30 min, do FIRST)

Audited via the Graph API 2026-08-04. **There are three Meta apps**, and the
one that owns the live number is not in a submittable state:

| App | ID | Owns |
| --- | --- | --- |
| **Chatbot** | **1730934398098392** | **WABA 988165394049282 + the live number — THIS is the one to enrol** |
| BotSquirrel Dev | 1010180585256848 | dev number 1191297624067005 |
| BotSquirrel Dev B | 1083116494039742 | dev number 1237988176066284 |

App **1730934398098392** currently reports:

| Field | Now | Change to |
| --- | --- | --- |
| Name | `Chatbot` | `BotSquirrel` — **customer-facing**: this is the name in the Embedded Signup consent dialog ("Chatbot wants to manage your WhatsApp Business Account" reads like phishing) |
| Privacy Policy URL | `csamcheung.github.io/botlocal-website/privacy.html` | `https://botsquirrel.com/privacy.html` — a github.io URL will not match the verified business domain |
| Terms of Service URL | `https://www.facebook.com/` | `https://botsquirrel.com/terms.html` — currently a placeholder pointing at Facebook itself |
| User Data Deletion | not set | `https://botsquirrel.com/data-deletion.html` |
| App Domains | not set | `botsquirrel.com` |
| Category | unset (its `link` resolves under `/games/`) | **Business and Pages** |
| Icon | none | `website/app-icon-1024.png` (in this repo) |

Also worth renaming while you are there: WABA 988165394049282 is still named
**"BotLocal"**.

All of these live in App Dashboard → **Settings → Basic**, are editable at any
time, and none require re-review to change later.

## Step 1 — Open the onboarding tracker (2 min)

developers.facebook.com/apps → app **1730934398098392** → **Use cases →
Customize** → left menu → **Tech Provider onboarding**.

> Enrol the app that already owns WABA 988165394049282 and the live number. A
> new app means re-pointing webhooks and redoing working setup.

Meta shows a live checklist there; it supersedes this file if they disagree.

## Step 2 — Business Verification (start today; days-to-weeks)

business.facebook.com → **Settings → Security Centre → Business verification**,
for the Business Portfolio that owns the app.

Paste the entity table above. When it asks for supporting documents, the
**Certificate of Incorporation** for 17364331 is the cleanest single document —
it carries the exact name, number and registered office that are now on the
website footer and privacy policy.

Confirmation method: prefer an email on a domain you control
(hello@botsquirrel.com) over a personal Gmail — Meta weights domain match.

**Nothing else can start until this clears.**

## Step 3 — App settings hygiene (do while waiting, ~30 min)

App Dashboard → **Settings → Basic**:

- App icon (1024×1024, the 🐿️ mark)
- Category: **Business and Pages**
- Privacy Policy URL, Terms of Service URL, User Data Deletion → from the table above
- Business use: **Yourself or your own business** (BotSquirrel Ltd)

## Step 4 — App Review for Advanced Access (after Step 2 clears)

Request **Advanced Access** for exactly:

- `whatsapp_business_messaging` — send messages on behalf of clients
- `whatsapp_business_management` — access clients' WABAs

Two screencasts required:

1. **Message send + receipt** — a message created and sent from BotSquirrel,
   arriving in the WhatsApp client. Record against dev: the platform inbox →
   staff reply → the message landing on the test handset.
2. **Template creation** — Meta explicitly accepts **API Setup cURL scripts or a
   WhatsApp Manager screen recording** as an alternative to an in-product
   template UI. Use that: BotSquirrel registers templates via the Graph API, so
   record the cURL call plus the template appearing in WhatsApp Manager. **No
   template-creation UI needs to be built for review.**

## Step 5 — Embedded Signup config (only after review approves)

App Dashboard → **Facebook Login for Business → Configurations → Create
configuration** → WhatsApp Embedded Signup type. It mints a **config_id**.

Then, and only then, flip the switches — the code is already deployed and waiting:

| Where | Variable | Value |
| --- | --- | --- |
| App Runner (admin, dev then live) | `NEXT_PUBLIC_META_APP_ID` | the app id |
| App Runner (admin, dev then live) | `NEXT_PUBLIC_ES_CONFIG_ID` | the new config_id |
| Secrets Manager `botlocal-engine/<env>/env` + task-def `secrets` | `META_APP_ID` | the app id |
| Secrets Manager `botlocal-engine/<env>/env` + task-def `secrets` | `META_APP_SECRET` | the app secret |

The ES button appears in the 渠道 WhatsApp tab with no code change. Verified
2026-08-04 on dev: with the vars unset the endpoint refuses cleanly with
`META_APP_ID / META_APP_SECRET unset — ES exchange unavailable`.

---

## Open items not blocking Meta

- **ICO registration** — BotSquirrel Ltd processes UK personal data and should
  register (~£52/yr, ~10 min, needs company number 17364331) at
  https://ico.org.uk/registration/. `TODO` markers are in `privacy.html` and
  `dpa.html` where the number slots in.
- **CloudFront soft-404** — distribution EP4TSVD5YUCV7 maps both 403 and 404 to
  `/index.html` with **HTTP 200**, so any mistyped URL silently serves the
  homepage. Not a Meta blocker now that every required page exists, but it masks
  real breakage and is bad for SEO. Fix = a `404.html` plus remapping the 404
  rule to it with response code 404 (leave the 403 rule alone unless tested —
  S3+OAC returns 403 for missing keys, so that rule may be load-bearing).
