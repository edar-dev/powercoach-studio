import {
  corsHeaders,
  type BillingEntitlementRow,
  effectivePlan,
} from '../_shared/billing.ts';
import { createAdminClient, createUserClient } from '../_shared/supabase_admin.ts';

async function loadOrCreateEntitlement(
  userId: string,
): Promise<BillingEntitlementRow> {
  const admin = createAdminClient();
  const { data, error } = await admin
    .from('billing_entitlements')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw error;
  if (data) return data as BillingEntitlementRow;

  const { data: inserted, error: insertError } = await admin
    .from('billing_entitlements')
    .insert({ user_id: userId })
    .select('*')
    .single();

  if (insertError) throw insertError;
  return inserted as BillingEntitlementRow;
}

type EntitlementResponse = {
  plan: 'free' | 'pro';
  subscriptionPlan: 'free' | 'pro';
  status: string;
  currentPeriodEnd: string | null;
  proUntil: string | null;
  billingInterval: 'monthly' | 'yearly' | null;
  priceAmountCents: number | null;
  currency: string | null;
  entitlementSource: 'none' | 'stripe' | 'promo' | 'manual';
  hasPendingCouponRequest: boolean;
};

function toResponse(
  row: BillingEntitlementRow,
  hasPendingCouponRequest: boolean,
): EntitlementResponse {
  return {
    plan: effectivePlan(row),
    subscriptionPlan: row.plan,
    status: row.status,
    currentPeriodEnd: row.current_period_end,
    proUntil: row.pro_until,
    billingInterval: row.billing_interval,
    priceAmountCents: row.price_amount_cents,
    currency: row.currency,
    entitlementSource: row.entitlement_source ?? 'none',
    hasPendingCouponRequest,
  };
}

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) });
  }

  if (req.method !== 'GET' && req.method !== 'POST') {
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

    const row = await loadOrCreateEntitlement(userData.user.id);

    const admin = createAdminClient();
    const { data: pendingRequest } = await admin
      .from('coupon_requests')
      .select('id')
      .eq('user_id', userData.user.id)
      .eq('status', 'pending')
      .maybeSingle();

    return new Response(
      JSON.stringify(toResponse(row, Boolean(pendingRequest))),
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
