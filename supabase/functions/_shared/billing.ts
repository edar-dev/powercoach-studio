export const GRACE_PERIOD_DAYS = 7;

export type BillingPlan = 'free' | 'pro';
export type BillingStatus =
  | 'none'
  | 'active'
  | 'trialing'
  | 'past_due'
  | 'canceled';

export type BillingEntitlementRow = {
  user_id: string;
  plan: BillingPlan;
  stripe_customer_id: string | null;
  stripe_subscription_id: string | null;
  status: BillingStatus;
  current_period_end: string | null;
  pro_until: string | null;
  billing_interval: 'monthly' | 'yearly' | null;
  price_amount_cents: number | null;
  currency: string;
  updated_at: string;
};

export function effectivePlan(row: BillingEntitlementRow): BillingPlan {
  if (row.plan !== 'pro') return 'free';

  if (row.status === 'active' || row.status === 'trialing') {
    return 'pro';
  }

  if (row.pro_until) {
    const until = Date.parse(row.pro_until);
    if (!Number.isNaN(until) && until > Date.now()) {
      return 'pro';
    }
  }

  return 'free';
}

export function addGraceDays(from: Date, days = GRACE_PERIOD_DAYS): Date {
  const result = new Date(from);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}

export function corsHeaders(origin: string | null): HeadersInit {
  return {
    'Access-Control-Allow-Origin': origin ?? '*',
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
  };
}

/** Reads Edge Function secrets, trimming whitespace and trailing dots from copy-paste. */
export function readBillingEnv(name: string): string {
  const raw = Deno.env.get(name);
  if (!raw) throw new Error(`Missing ${name}`);
  const value = raw.trim().replace(/\.+$/, '');
  if (!value) throw new Error(`Missing ${name}`);
  return value;
}
