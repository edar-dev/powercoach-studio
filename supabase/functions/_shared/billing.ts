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
