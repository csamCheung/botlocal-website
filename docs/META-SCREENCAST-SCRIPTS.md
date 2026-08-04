# App Review screencasts — run sheets

Two videos, both short. Record the whole screen, no editing needed.

**Before you hit record, on both:** close anything showing a token, secret, or
another customer's data. Meta reviewers watch the whole frame.

---

## Video 1 — a message sent from the product arrives in WhatsApp

Meta's ask: *"the first video must show a message created and sent from your app
and received in the WhatsApp client."*

Record on the laptop with your phone visible in frame (or screen-mirror the
phone — either is accepted).

1. Open the inbox: `https://app.botsquirrel.com/inbox` (live) — log in on camera
   is fine, just don't show the password field contents.
2. From your phone, WhatsApp **+44 7472 323783** with something plain like
   `Hi, do you cover Camden?` — this opens the 24-hour window so a free-form
   reply will deliver.
3. In the inbox, open that conversation, type a reply, press send.
4. Hold on the phone until the reply lands. Let it sit ~3 seconds.

That's the whole video. 60–90 seconds is normal.

> Why the inbound message first: outside the 24-hour customer-service window
> Meta rejects free-form sends (error 131047) and the reviewer sees nothing
> arrive. Starting from a real inbound avoids that entirely.

---

## Video 2 — creating a message template

Meta's ask: *"the second video must show your app being used to create a message
template"* — and they explicitly accept **API Setup cURL scripts or WhatsApp
Manager screen recordings** as an alternative to an in-product template UI. Take
that route; nothing needs building.

**Step 1 — before recording**, in a terminal you will NOT show:

```bash
export WA_TOKEN=$(aws secretsmanager get-secret-value --region eu-west-2 \
  --secret-id botlocal-engine/live/env --query SecretString --output text \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['WHATSAPP_TOKEN'])")
```

The token now lives in an env var, so it never appears on screen.

**Step 2 — start recording**, then run this in that same terminal:

```bash
curl -X POST "https://graph.facebook.com/v21.0/988165394049282/message_templates" \
  -H "Authorization: Bearer $WA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "booking_confirmation",
    "language": "en",
    "category": "UTILITY",
    "components": [
      { "type": "BODY",
        "text": "Hi {{1}}, your booking with {{2}} is confirmed for {{3}}. Reply here if you need to change it.",
        "example": { "body_text": [["Sam", "BotSquirrel", "Tuesday 9am"]] } }
    ]
  }'
```

It returns an `id` and `status: PENDING`. Say out loud (or caption) that this is
BotSquirrel creating a template on the customer's WABA.

**Step 3 — still recording**, open WhatsApp Manager →
[Message templates](https://business.facebook.com/wa/manage/message-templates/?waba_id=988165394049282)
and show `booking_confirmation` in the list. Stop recording.

`booking_confirmation` is a fresh name — the WABA currently holds
`appointment_reminder`, `web_lead_first_contact`, `enquiry_follow_up` and
`hello_world`, so there is no collision. Verified 2026-08-04.
