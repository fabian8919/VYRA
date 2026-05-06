import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

/**
 * Cliente Supabase para el servidor.
 * Compatible con Server Components, Server Actions y API Routes.
 *
 * ⚠️ Nota sobre cookies:
 * - En API Routes (Route Handlers) las cookies pueden mutarse para
 *   refrescar la sesión.
 * - En Server Components las cookies son read-only; el try-catch
 *   evita errores y el middleware se encarga del refresco.
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // En Server Components no se pueden mutar cookies.
            // El middleware (middleware.ts) ya refresca la sesión
            // antes de llegar aquí.
          }
        },
      },
    }
  );
}
