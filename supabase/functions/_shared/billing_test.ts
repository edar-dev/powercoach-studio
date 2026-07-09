import {
  assertEquals,
} from 'jsr:@std/assert@1';
import {
  effectivePlan,
  type BillingEntitlementRow,
  addGraceDays,
} from './billing.ts';

function row(
  partial: Partial<BillingEntitlementRow> & Pick<BillingEntitlementRow, 'plan'>,
): BillingEntitlementRow {
  return {
    user_id: 'user-1',
    stripe_customer_id: null,
    stripe_subscription_id: null,
    status: 'none',
    current_period_end: null,
    pro_until: null,
    updated_at: new Date().toISOString(),
    ...partial,
  };
}

Deno.test('effectivePlan returns free for free tier', () => {
  assertEquals(effectivePlan(row({ plan: 'free' })), 'free');
});

Deno.test('effectivePlan returns pro for active subscription', () => {
  assertEquals(
    effectivePlan(row({ plan: 'pro', status: 'active' })),
    'pro',
  );
});

Deno.test('effectivePlan returns pro during grace window', () => {
  const future = addGraceDays(new Date()).toISOString();
  assertEquals(
    effectivePlan(row({ plan: 'pro', status: 'canceled', pro_until: future })),
    'pro',
  );
});

Deno.test('effectivePlan returns free after grace expires', () => {
  const past = new Date(Date.now() - 86_400_000).toISOString();
  assertEquals(
    effectivePlan(row({ plan: 'pro', status: 'canceled', pro_until: past })),
    'free',
  );
});
