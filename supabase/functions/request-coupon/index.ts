import { corsHeaders } from '../_shared/billing.ts';
import { createAdminClient, createUserClient } from '../_shared/supabase_admin.ts';

type RequestBody = {
  message?: string;
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

    const body = (await req.json()) as RequestBody;
    const message = body.message?.trim().slice(0, 500) ?? null;
    const email = userData.user.email;
    if (!email) {
      return new Response(JSON.stringify({ error: 'Account email is required' }), {
        status: 400,
        headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
      });
    }

    const admin = createAdminClient();
    const userId = userData.user.id;

    const { data: pending } = await admin
      .from('coupon_requests')
      .select('id')
      .eq('user_id', userId)
      .eq('status', 'pending')
      .maybeSingle();

    if (pending) {
      return new Response(
        JSON.stringify({
          ok: true,
          alreadyPending: true,
        }),
        {
          status: 200,
          headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
        },
      );
    }

    const nowIso = new Date().toISOString();
    const { error: insertError } = await admin.from('coupon_requests').insert({
      user_id: userId,
      email,
      message,
      status: 'pending',
      created_at: nowIso,
      updated_at: nowIso,
    });

    if (insertError) throw insertError;

    return new Response(JSON.stringify({ ok: true }), {
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
