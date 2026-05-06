import { createAdminClient } from "./supabase/admin";

/**
 * Valida un access token de Supabase recibido en el header Authorization.
 * Retorna el usuario si el token es válido, o null si no lo es.
 */
export async function validateToken(token: string) {
  const supabase = createAdminClient();

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser(token);

  if (error || !user) {
    return null;
  }

  return user;
}

/**
 * Extrae el Bearer token del header Authorization.
 */
export function getBearerToken(request: Request): string | null {
  const authHeader = request.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.slice(7);
}
