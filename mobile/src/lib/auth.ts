import type { Session } from '@supabase/supabase-js';

import { supabase } from '@/lib/supabase';

export async function sendLoginCode(email: string): Promise<void> {
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: { shouldCreateUser: true },
  });

  if (error) {
    throw new Error(error.message);
  }
}

export async function verifyLoginCode(email: string, code: string): Promise<Session> {
  const { data, error } = await supabase.auth.verifyOtp({
    email,
    token: code,
    type: 'email',
  });

  if (error || !data.session) {
    throw new Error(error?.message ?? '로그인에 실패했습니다.');
  }

  return data.session;
}

export async function getSession(): Promise<Session | null> {
  const { data } = await supabase.auth.getSession();
  return data.session;
}

export async function signOut(): Promise<void> {
  await supabase.auth.signOut();
}
