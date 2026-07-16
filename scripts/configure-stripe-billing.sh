#!/usr/bin/env bash
# Configure Stripe webhook + Customer Portal and print Supabase Edge Function secrets.
# Requires: curl, jq (optional), STRIPE_SECRET_KEY (sk_test_... or sk_live_...)
#
# Usage:
#   STRIPE_SECRET_KEY=sk_test_... bash scripts/configure-stripe-billing.sh
#
# After running, set the printed secrets in Supabase Dashboard → Edge Functions → Secrets
# or: supabase secrets set --project-ref owtkzvphhapjdfibmebl ...

set -euo pipefail

STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:?Export STRIPE_SECRET_KEY (sk_test_... or sk_live_...)}"
PROJECT_REF="${SUPABASE_PROJECT_REF:-owtkzvphhapjdfibmebl}"
WEBHOOK_URL="https://${PROJECT_REF}.supabase.co/functions/v1/stripe-webhook"
RETURN_URL="${BILLING_RETURN_URL:-https://powercoach-studio.vercel.app/settings/subscription}"

# Created in Stripe test mode (2026-07-09). Override if you recreate products/prices.
STRIPE_PRICE_ID_MONTHLY="${STRIPE_PRICE_ID_MONTHLY:-price_1TrOOs2Ls7JojLJZijEv3TUK}"
STRIPE_PRICE_ID_YEARLY="${STRIPE_PRICE_ID_YEARLY:-price_1TrOOr2Ls7JojLJZok7d6j7l}"
STRIPE_PRODUCT_ID="${STRIPE_PRODUCT_ID:-prod_Ur6bQo6Vqyz1Gt}"

stripe_api() {
  local method="$1"
  local path="$2"
  shift 2
  curl -sS -X "$method" "https://api.stripe.com/v1/${path}" \
    -u "${STRIPE_SECRET_KEY}:" \
    "$@"
}

echo "==> Stripe account (verify test vs live mode)"
stripe_api GET account | { command -v jq >/dev/null && jq '{id, livemode}' || cat; }

echo ""
echo "==> Webhook endpoint → ${WEBHOOK_URL}"
WEBHOOK_JSON="$(stripe_api POST webhook_endpoints \
  -d "url=${WEBHOOK_URL}" \
  -d "description=PowerCoach Studio billing (Supabase)" \
  -d "enabled_events[]=checkout.session.completed" \
  -d "enabled_events[]=customer.subscription.updated" \
  -d "enabled_events[]=customer.subscription.deleted" \
  -d "enabled_events[]=invoice.payment_failed")"

if command -v jq >/dev/null; then
  WEBHOOK_ID="$(echo "$WEBHOOK_JSON" | jq -r '.id // empty')"
  WEBHOOK_SECRET="$(echo "$WEBHOOK_JSON" | jq -r '.secret // empty')"
  if [[ -z "$WEBHOOK_ID" ]]; then
    echo "$WEBHOOK_JSON" | jq .
    echo "Webhook creation failed (endpoint may already exist — check Stripe Dashboard → Webhooks)."
    WEBHOOK_SECRET=""
  else
    echo "Created webhook: ${WEBHOOK_ID}"
  fi
else
  echo "$WEBHOOK_JSON"
  WEBHOOK_SECRET="$(echo "$WEBHOOK_JSON" | sed -n 's/.*"secret"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

echo ""
echo "==> Customer Portal configuration"
PORTAL_JSON="$(stripe_api POST billing_portal/configurations \
  -d "default_return_url=${RETURN_URL}" \
  -d "features[subscription_cancel][enabled]=true" \
  -d "features[subscription_cancel][mode]=at_period_end" \
  -d "features[subscription_cancel][cancellation_reason][enabled]=true" \
  -d "features[subscription_cancel][cancellation_reason][options][]=too_expensive" \
  -d "features[subscription_cancel][cancellation_reason][options][]=missing_features" \
  -d "features[subscription_cancel][cancellation_reason][options][]=switched_service" \
  -d "features[subscription_cancel][cancellation_reason][options][]=unused" \
  -d "features[subscription_cancel][cancellation_reason][options][]=other" \
  -d "features[payment_method_update][enabled]=true" \
  -d "features[invoice_history][enabled]=true" \
  -d "features[customer_update][enabled]=true" \
  -d "features[customer_update][allowed_updates][]=email" \
  -d "features[subscription_update][enabled]=true" \
  -d "features[subscription_update][default_allowed_updates][]=price" \
  -d "features[subscription_update][products][0][product]=${STRIPE_PRODUCT_ID}" \
  -d "features[subscription_update][products][0][prices][]=${STRIPE_PRICE_ID_MONTHLY}" \
  -d "features[subscription_update][products][0][prices][]=${STRIPE_PRICE_ID_YEARLY}")"

if command -v jq >/dev/null; then
  PORTAL_ID="$(echo "$PORTAL_JSON" | jq -r '.id // empty')"
  if [[ -n "$PORTAL_ID" ]]; then
    echo "Created portal config: ${PORTAL_ID}"
  else
    echo "$PORTAL_JSON" | jq .
  fi
else
  echo "$PORTAL_JSON"
fi

echo ""
echo "=========================================="
echo "Supabase Edge Function secrets to set:"
echo "=========================================="
echo "STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}"
echo "STRIPE_PRICE_ID_MONTHLY=${STRIPE_PRICE_ID_MONTHLY}"
echo "STRIPE_PRICE_ID_YEARLY=${STRIPE_PRICE_ID_YEARLY}"
if [[ -n "${WEBHOOK_SECRET:-}" ]]; then
  echo "STRIPE_WEBHOOK_SECRET=${WEBHOOK_SECRET}"
else
  echo "STRIPE_WEBHOOK_SECRET=whsec_...  # from Stripe Dashboard → Webhooks → signing secret"
fi
echo ""
echo "Supabase CLI (after supabase login + link):"
echo "  supabase secrets set --project-ref ${PROJECT_REF} \\"
echo "    STRIPE_SECRET_KEY=\"\${STRIPE_SECRET_KEY}\" \\"
echo "    STRIPE_WEBHOOK_SECRET=\"\${STRIPE_WEBHOOK_SECRET}\" \\"
echo "    STRIPE_PRICE_ID_MONTHLY=\"${STRIPE_PRICE_ID_MONTHLY}\" \\"
echo "    STRIPE_PRICE_ID_YEARLY=\"${STRIPE_PRICE_ID_YEARLY}\""
