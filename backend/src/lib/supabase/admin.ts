import { createClient } from "@supabase/supabase-js";

/**
 * Cliente Supabase con privilegios de admin (service_role).
 * ⚠️ Usar SOLO en API Routes o Server Actions que requieran
 *    operaciones elevadas (bypass RLS, admin tasks, etc.).
 * NUNCA exponer al cliente.
 */
export function createAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}
