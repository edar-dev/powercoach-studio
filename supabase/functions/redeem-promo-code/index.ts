import {
  corsHeaders,
  type BillingEntitlementRow,
  effectivePlan,
} from '../_shared/billing.ts';
import { normalizePromoCode, validatePromoCode } from '../_shared/promo.ts';
import { createAdminClient, createUserClient } from '../_shared/supabase_admin.ts';

type RedeemBody = {
  code: string;
};

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const userClient = createUserClient(authHeader);
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const body = (await req.json()) as RedeemBody;
    const normalized = normalizePromoCode(body.code ?? '');
    if (!normalized) {
      return new Response(JSON.stringify({ error: 'Enter a promo code' }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const admin = createAdminClient();
    const userId = userData.user.id;

    const { data: existingEntitlement } = await admin
      .from('billing_entitlements')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    const current = existingEntitlement as BillingEntitlementRow | null;
    if (current && effectivePlan(current) === 'pro') {
      return new Response(
        JSON.stringify({
          ok: true,
          alreadyPro: true,
          plan: 'pro',
          entitlementSource: current.entitlement_source ?? 'none',
        }),
        {
          status: 200,
          headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
        },
      );
    }

    const { data: promoRows, error: promoError } = await admin
      .from('promo_codes')
      .select('*')
      .eq('code_normalized', normalized)
      .eq('active', true)
      .maybeSingle();

    if (promoError) throw promoError;

    const promo = promoRows;

    const validationError = validatePromoCode(promo ?? null);
    if (validationError) {
      return new Response(JSON.stringify({ error: validationError }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const promoId = promo!.id as string;

    const { data: priorRedemption } = await admin
      .from('promo_redemptions')
      .select('id')
      .eq('promo_code_id', promoId)
      .eq('user_id', userId)
      .maybeSingle();

    if (priorRedemption) {
      return new Response(JSON.stringify({ error: 'You already used this code' }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const nowIso = new Date().toISOString();

    const { error: upsertError } = await admin.from('billing_entitlements').upsert({
      user_id: userId,
      plan: 'pro',
      status: 'active',
      entitlement_source: 'promo',
      promo_code_id: promoId,
      pro_until: null,
      current_period_end: null,
      billing_interval: null,
      price_amount_cents: null,
      updated_at: nowIso,
    });

    if (upsertError) throw upsertError;

    const { error: redemptionError } = await admin.from('promo_redemptions').insert({
      promo_code_id: promoId,
      user_id: userId,
      redeemed_at: nowIso,
    });

    if (redemptionError) throw redemptionError;

    const { error: incrementError } = await admin
      .from('promo_codes')
      .update({ redemption_count: (promo!.redemption_count as number) + 1 })
      .eq('id', promoId);

    if (incrementError) throw incrementError;

    return new Response(
      JSON.stringify({
        ok: true,
        plan: 'pro',
        entitlementSource: 'promo',
      }),
      {
        status: 200,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    });
  }
});
