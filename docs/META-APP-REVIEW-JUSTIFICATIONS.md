# App Review — usage justifications (paste-ready)

One block per requested permission. Written for a Meta reviewer who has never
seen the product: what BotSquirrel is, how the permission is used, and what the
attached videos show. Keep the first paragraph of each if the form's field is
small; the bullet list is expansion room.

Product one-liner used throughout (keep consistent):
> BotSquirrel (botsquirrel.com) is a SaaS by BotSquirrel Ltd (UK) that gives
> small service businesses — e.g. plumbing and heating companies — an AI
> assistant plus a team inbox for their WhatsApp Business number. The assistant
> answers customer enquiries using only the business's own approved
> information, collects job details (postcode, problem, photos, availability),
> and hands over to human staff who reply from our web inbox.

---

## whatsapp_business_messaging

BotSquirrel is a customer-service SaaS for small service businesses (e.g. UK
plumbing and heating companies). Each business connects its own WhatsApp
Business number to our platform. We use whatsapp_business_messaging to
(1) receive our clients' end-customer messages via webhook, (2) send the
AI-assisted first response that answers questions and collects enquiry details
(postcode, problem description, photos, availability), and (3) deliver replies
that our client's human staff write in our web inbox. Outside the 24-hour
customer-service window we send only pre-approved utility templates (e.g.
booking confirmations and enquiry follow-ups). Messages are sent exclusively
on behalf of the client business that owns the number, to end customers who
contacted that business first. The attached video shows a real end-customer
message arriving in our inbox and a staff reply delivered back to the
customer's WhatsApp.

- Inbound: webhook receipt of text/media from end customers of our clients
- Outbound: AI-assisted replies within the 24-hour window; approved UTILITY
  templates outside it (booking_confirmation, enquiry_follow_up)
- No cold outreach, no marketing blasts, no contact-list uploads: every
  conversation is initiated by the end customer

## whatsapp_business_management

We use whatsapp_business_management to operate the WhatsApp Business Accounts
our clients connect to BotSquirrel via Embedded Signup. After a client
completes Embedded Signup, our backend uses this permission to subscribe our
app to their WABA's webhooks, register their phone number for Cloud API
messaging, read the number's display name and account status, and create and
manage the message templates their account needs (e.g. booking confirmations
and enquiry follow-ups). We also use it to detect when a client revokes our
access, so we can mark the integration as disconnected in their dashboard and
prompt them to re-authorise. The attached video shows a message template being
created on a WABA via our tooling and appearing in WhatsApp Manager. Each
client's WABA remains owned by their own business portfolio; we act only on
accounts explicitly shared with our app through Embedded Signup.

- POST /{waba_id}/subscribed_apps after Embedded Signup completion
- POST /{phone_number_id}/register; read display_phone_number / status
- Create and manage UTILITY message templates for the client's account
- Detect revoked access and surface a re-authorisation flow

## business_management

We request business_management solely to support onboarding through Embedded
Signup. When a business completes the Embedded Signup flow, we exchange the
returned code for a business integration system-user token and use this
permission to identify the client's business portfolio and the WhatsApp assets
(WABA and phone number) they chose to share with our app, so we can link those
assets to the correct customer account in BotSquirrel. We do not read or
modify any other business data, do not manage ad accounts or pages, and do not
access portfolios beyond what the client explicitly grants during Embedded
Signup.

- Resolve which business portfolio / WABA / phone number the client shared
  during Embedded Signup, and bind them to their BotSquirrel account
- No ads, pages, or asset administration beyond the shared WhatsApp assets

---

## Reviewer test notes (if the form asks "how do we test this?")

- Product: https://botsquirrel.com — live customer inbox at
  https://app.botsquirrel.com (we can provide a demo login on request).
- Messaging demo: send any WhatsApp message (e.g. "Do you cover Camden?") to
  +44 7472 323783. The assistant replies using the business's approved
  information; a staff member can also reply from the web inbox — both arrive
  in the same WhatsApp thread.
- Embedded Signup is operator-assisted inside our admin console (feature is
  gated until this review is approved); the videos demonstrate the messaging
  and template-management capabilities on our own WABA (988165394049282).
