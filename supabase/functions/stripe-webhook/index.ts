import Stripe from 'npm:stripe@17.7.0';
import {
  addGraceDays,
  type BillingStatus,
  corsHeaders,
} from '../_shared/billing.ts';
import { createAdminClient } from '../_shared/supabase_admin.ts';

function mapStripeStatus(status: Stripe.Subscription.Status): BillingStatus {
  switch (status) {
    case 'active':
      return 'active';
    case 'trialing':
      return 'trialing';
    case 'past_due':
      return 'past_due';
    case 'canceled':
    case 'unpaid':
    case 'incomplete':
    case 'incomplete_expired':
    case 'paused':
      return 'canceled';
    default:
      return 'none';
  }
}

async function upsertFromSubscription(
  subscription: Stripe.Subscription,
  userId: string,
) {
  const admin = createAdminClient();
  const status = mapStripeStatus(subscription.status);
  const isPro = status === 'active' || status === 'trialing';
  const price = subscription.items.data[0]?.price;
  const recurringInterval = price?.recurring?.interval;
  const billingInterval = recurringInterval === 'year'
    ? 'yearly'
    : recurringInterval === 'month'
    ? 'monthly'
    : null;

  const payload: Record<string, unknown> = {
    user_id: userId,
    plan: isPro ? 'pro' : 'free',
    stripe_subscription_id: subscription.id,
    status,
    current_period_end: subscription.current_period_end
      ? new Date(subscription.current_period_end * 1000).toISOString()
      : null,
    pro_until: null,
    billing_interval: billingInterval,
    price_amount_cents: price?.unit_amount ?? null,
    currency: price?.currency ?? 'eur',
    updated_at: new Date().toISOString(),
  };

  const customerId = typeof subscription.customer === 'string'
    ? subscription.customer
    : subscription.customer.id;
  payload.stripe_customer_id = customerId;

  const { error } = await admin.from('billing_entitlements').upsert(payload);
  if (error) throw error;
}

async function applyGraceCancellation(userId: string) {
  const admin = createAdminClient();
  const proUntil = addGraceDays(new Date()).toISOString();

  const { error } = await admin
    .from('billing_entitlements')
    .update({
      plan: 'pro',
      status: 'canceled',
      pro_until: proUntil,
      stripe_subscription_id: null,
      updated_at: new Date().toISOString(),
    })
    .eq('user_id', userId);

  if (error) throw error;
}

async function resolveUserIdFromSubscription(
  subscription: Stripe.Subscription,
): Promise<string | null> {
  const fromMetadata = subscription.metadata?.supabase_user_id;
  if (fromMetadata) return fromMetadata;

  const admin = createAdminClient();
  const customerId = typeof subscription.customer === 'string'
    ? subscription.customer
    : subscription.customer.id;

  const { data } = await admin
    .from('billing_entitlements')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .maybeSingle();

  return (data?.user_id as string | undefined) ?? null;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const stripeSecret = Deno.env.get('STRIPE_SECRET_KEY');
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
  if (!stripeSecret || !webhookSecret) {
    return new Response('Missing Stripe secrets', { status: 500 });
  }

  const stripe = new Stripe(stripeSecret, {
    apiVersion: '2024-11-20.acacia',
  });

  const signature = req.headers.get('stripe-signature');
  if (!signature) {
    return new Response('Missing stripe-signature', { status: 400 });
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Invalid signature';
    return new Response(message, { status: 400 });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.client_reference_id ??
          session.metadata?.supabase_user_id;
        if (!userId || !session.subscription) break;

        const subscription = await stripe.subscriptions.retrieve(
          session.subscription as string,
        );
        await upsertFromSubscription(subscription, userId);
        break;
      }
      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = await resolveUserIdFromSubscription(subscription);
        if (!userId) break;

        if (subscription.status === 'canceled') {
          await applyGraceCancellation(userId);
        } else {
          await upsertFromSubscription(subscription, userId);
        }
        break;
      }
      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = await resolveUserIdFromSubscription(subscription);
        if (!userId) break;
        await applyGraceCancellation(userId);
        break;
      }
      case 'invoice.payment_failed': {
        const invoice = event.data.object as Stripe.Invoice;
        if (!invoice.subscription) break;
        const subscription = await stripe.subscriptions.retrieve(
          invoice.subscription as string,
        );
        const userId = await resolveUserIdFromSubscription(subscription);
        if (!userId) break;
        await upsertFromSubscription(subscription, userId);
        break;
      }
      default:
        break;
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Webhook handler failed';
    console.error(message);
    return new Response(message, { status: 500 });
  }
});
