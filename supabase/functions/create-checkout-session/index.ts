import Stripe from 'npm:stripe@17.7.0';
import { corsHeaders, readBillingEnv } from '../_shared/billing.ts';
import { createAdminClient, createUserClient } from '../_shared/supabase_admin.ts';

type CheckoutBody = {
  priceId?: string;
  billingInterval?: 'monthly' | 'yearly';
  successUrl: string;
  cancelUrl: string;
};

function resolvePriceId(body: CheckoutBody): string {
  if (body.priceId) return body.priceId;

  const interval = body.billingInterval ?? 'monthly';
  if (interval === 'yearly') {
    return readBillingEnv('STRIPE_PRICE_ID_YEARLY');
  }

  return readBillingEnv('STRIPE_PRICE_ID_MONTHLY');
}

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

    const body = (await req.json()) as CheckoutBody;
    if (!body.successUrl || !body.cancelUrl) {
      return new Response(JSON.stringify({ error: 'Missing redirect URLs' }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const stripeSecret = readBillingEnv('STRIPE_SECRET_KEY');

    const stripe = new Stripe(stripeSecret, {
      apiVersion: '2024-11-20.acacia',
    });

    const admin = createAdminClient();
    const userId = userData.user.id;
    const email = userData.user.email ?? undefined;

    const { data: entitlement } = await admin
      .from('billing_entitlements')
      .select('stripe_customer_id')
      .eq('user_id', userId)
      .maybeSingle();

    let customerId = entitlement?.stripe_customer_id as string | undefined;
    if (!customerId) {
      const customer = await stripe.customers.create({
        email,
        metadata: { supabase_user_id: userId },
      });
      customerId = customer.id;
      await admin.from('billing_entitlements').upsert({
        user_id: userId,
        stripe_customer_id: customerId,
        updated_at: new Date().toISOString(),
      });
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      allow_promotion_codes: true,
      line_items: [{ price: resolvePriceId(body), quantity: 1 }],
      success_url: body.successUrl,
      cancel_url: body.cancelUrl,
      client_reference_id: userId,
      metadata: { supabase_user_id: userId },
      subscription_data: {
        metadata: { supabase_user_id: userId },
      },
    });

    if (!session.url) {
      throw new Error('Stripe did not return a checkout URL');
    }

    return new Response(JSON.stringify({ url: session.url }), {
      status: 200,
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
    });
  }
});
