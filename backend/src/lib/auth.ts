import { createAuthClient } from "./supabase/auth-client";

/**
 * Valida un access token de Supabase recibido en el header Authorization.
 * Retorna el usuario si el token es válido, o null si no lo es.
 *
 * Usa el cliente auth (anon key) porque validar un token no requiere
 * privilegios de admin.
 */
export async function validateToken(token: string) {
  // eslint-disable-next-line no-console
  console.log("[validateToken] token length:", token.length, "prefix:", token.slice(0, 20) + "...");

  const supabase = createAuthClient();

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser(token);

  if (error) {
    // eslint-disable-next-line no-console
    console.log("[validateToken] error:", error.message);
    return null;
  }

  if (!user) {
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
