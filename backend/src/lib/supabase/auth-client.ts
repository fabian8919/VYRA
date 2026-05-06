import { createClient } from "@supabase/supabase-js";

/**
 * Cliente Supabase simple (no SSR) para operaciones de auth
 * desde API Routes del backend.
 *
 * Este cliente se usa directamente en el servidor para llamar
 * a Supabase Auth (signIn, signUp, etc.) y devolver la sesión
 * al frontend Flutter.
 */
export function createAuthClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}
