export function normalizePromoCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/\s+/g, '');
}

export type PromoCodeRow = {
  id: string;
  code: string;
  plan: 'pro';
  max_redemptions: number | null;
  redemption_count: number;
  expires_at: string | null;
  active: boolean;
};

export function validatePromoCode(
  row: PromoCodeRow | null,
  now = Date.now(),
): string | null {
  if (!row || !row.active) {
    return 'Invalid or inactive promo code';
  }

  if (row.expires_at) {
    const expires = Date.parse(row.expires_at);
    if (!Number.isNaN(expires) && expires <= now) {
      return 'This promo code has expired';
    }
  }

  if (
    row.max_redemptions != null &&
    row.redemption_count >= row.max_redemptions
  ) {
    return 'This promo code has reached its redemption limit';
  }

  return null;
}
