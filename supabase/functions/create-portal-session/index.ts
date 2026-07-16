import Stripe from 'npm:stripe@17.7.0';
import { corsHeaders } from '../_shared/billing.ts';
import { createAdminClient, createUserClient } from '../_shared/supabase_admin.ts';

type PortalBody = {
  returnUrl: string;
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

    const body = (await req.json()) as PortalBody;
    if (!body.returnUrl) {
      return new Response(JSON.stringify({ error: 'Missing returnUrl' }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const admin = createAdminClient();
    const { data: entitlement, error: loadError } = await admin
      .from('billing_entitlements')
      .select('stripe_customer_id')
      .eq('user_id', userData.user.id)
      .maybeSingle();

    if (loadError) throw loadError;

    const customerId = entitlement?.stripe_customer_id as string | undefined;
    if (!customerId) {
      return new Response(
        JSON.stringify({ error: 'No Stripe customer for this account' }),
        {
          status: 404,
          headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
        },
      );
    }

    const stripeSecret = Deno.env.get('STRIPE_SECRET_KEY');
    if (!stripeSecret) throw new Error('Missing STRIPE_SECRET_KEY');

    const stripe = new Stripe(stripeSecret, {
      apiVersion: '2024-11-20.acacia',
    });

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: body.returnUrl,
    });

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
