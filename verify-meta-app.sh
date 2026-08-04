#!/usr/bin/env bash
# Check the live Meta app's settings against what App Review needs.
#
# Run it after saving changes in App Dashboard -> Settings -> Basic. It reads
# the app secret out of Secrets Manager, so nothing secret is typed or printed.
#
#   ./verify-meta-app.sh
#
# Every line prints OK or the value that still needs fixing. Exits non-zero if
# anything is still wrong, so you can re-run until it is clean.
set -euo pipefail

APP=1730934398098392
WABA=988165394049282
REGION=eu-west-2

SECRET=$(aws secretsmanager get-secret-value --region "$REGION" \
  --secret-id botlocal-engine/live/env --query SecretString --output text)
APP_SECRET=$(printf '%s' "$SECRET" | python3 -c "import json,sys; print(json.load(sys.stdin)['META_APP_SECRET'])")
WA_TOKEN=$(printf '%s' "$SECRET" | python3 -c "import json,sys; print(json.load(sys.stdin)['WHATSAPP_TOKEN'])")
AT="${APP}|${APP_SECRET}"

APP_JSON=$(curl -s --max-time 25 \
  "https://graph.facebook.com/v21.0/${APP}?fields=name,category,privacy_policy_url,terms_of_service_url,app_domains&access_token=${AT}")
WABA_JSON=$(curl -s --max-time 25 \
  "https://graph.facebook.com/v21.0/${WABA}?fields=name&access_token=${WA_TOKEN}")

APP_JSON="$APP_JSON" WABA_JSON="$WABA_JSON" python3 <<'PY'
import json, os, sys

app = json.loads(os.environ["APP_JSON"])
waba = json.loads(os.environ["WABA_JSON"])
if "error" in app:
    sys.exit(f"could not read the app: {app['error'].get('message')}")

fails = []

def check(label, actual, want, contains=False):
    actual = actual if actual is not None else "(not set)"
    ok = (want.lower() in str(actual).lower()) if contains else (str(actual) == want)
    print(f"  {'OK  ' if ok else 'FIX '} {label:<22} {actual}")
    if not ok:
        fails.append(f"{label} -> {want}")

print("App", os.environ.get("APP", ""), "settings:")
check("name", app.get("name"), "BotSquirrel")
check("privacy_policy_url", app.get("privacy_policy_url"), "https://botsquirrel.com/privacy.html")
check("terms_of_service_url", app.get("terms_of_service_url"), "https://botsquirrel.com/terms.html")
check("app_domains", ", ".join(app.get("app_domains") or []) or None, "botsquirrel.com", contains=True)
check("category", app.get("category"), "Business", contains=True)
print("WABA:")
check("waba name", waba.get("name"), "BotSquirrel")

print()
if fails:
    print(f"{len(fails)} still to fix in the dashboard:")
    for f in fails:
        print("   -", f)
    sys.exit(1)
print("All green. Data-deletion URL and app icon are not exposed by the API —")
print("confirm those two by eye in Settings > Basic, then submit.")
PY
