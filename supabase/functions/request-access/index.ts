import { corsHeaders } from '../_shared/billing.ts';
import { createAdminClient } from '../_shared/supabase_admin.ts';

type RequestBody = {
  email?: string;
  name?: string;
  note?: string;
};

const EMAIL_RE = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
const RATE_LIMIT_WINDOW_MS = 60_000;

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

function jsonResponse(
  origin: string | null,
  status: number,
  body: Record<string, unknown>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) });
  }

  if (req.method !== 'POST') {
    return jsonResponse(origin, 405, { error: 'Method not allowed' });
  }

  try {
    let body: RequestBody;
    try {
      body = (await req.json()) as RequestBody;
    } catch {
      return jsonResponse(origin, 400, { error: 'Invalid JSON body' });
    }

    const emailRaw = typeof body.email === 'string' ? body.email.trim() : '';
    if (!emailRaw || !EMAIL_RE.test(emailRaw)) {
      return jsonResponse(origin, 400, { error: 'Valid email is required' });
    }

    const emailNormalized = normalizeEmail(emailRaw);
    const name =
      typeof body.name === 'string' && body.name.trim().length > 0
        ? body.name.trim().slice(0, 120)
        : null;
    const note =
      typeof body.note === 'string' && body.note.trim().length > 0
        ? body.note.trim().slice(0, 500)
        : null;

    const admin = createAdminClient();

    const { data: pending } = await admin
      .from('access_waitlist')
      .select('id')
      .eq('email_normalized', emailNormalized)
      .eq('status', 'pending')
      .maybeSingle();

    if (pending) {
      return jsonResponse(origin, 200, { ok: true, alreadyPending: true });
    }

    const sinceIso = new Date(Date.now() - RATE_LIMIT_WINDOW_MS).toISOString();
    const { count: recentCount, error: recentError } = await admin
      .from('access_waitlist')
      .select('id', { count: 'exact', head: true })
      .eq('email_normalized', emailNormalized)
      .gte('created_at', sinceIso);

    if (recentError) {
      console.error('access_waitlist rate check failed', recentError);
      return jsonResponse(origin, 500, { error: 'Request failed' });
    }

    if ((recentCount ?? 0) > 0) {
      return jsonResponse(origin, 429, { error: 'Too many requests. Try again later.' });
    }

    const nowIso = new Date().toISOString();
    const { error: insertError } = await admin.from('access_waitlist').insert({
      email: emailRaw,
      name,
      note,
      status: 'pending',
      created_at: nowIso,
      updated_at: nowIso,
    });

    if (insertError) {
      // Unique pending index race → treat as already pending.
      if (insertError.code === '23505') {
        return jsonResponse(origin, 200, { ok: true, alreadyPending: true });
      }
      console.error('access_waitlist insert failed', insertError);
      return jsonResponse(origin, 500, { error: 'Request failed' });
    }

    return jsonResponse(origin, 200, { ok: true, alreadyPending: false });
  } catch (error) {
    console.error('request-access unexpected error', error);
    return jsonResponse(origin, 500, { error: 'Request failed' });
  }
});
