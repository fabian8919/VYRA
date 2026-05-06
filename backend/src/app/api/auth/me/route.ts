import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";

/**
 * GET /api/auth/me
 *
 * Valida el access token recibido en el header Authorization
 * y devuelve la información del usuario.
 */
export async function GET(request: Request) {
  const token = getBearerToken(request);

  if (!token) {
    return NextResponse.json(
      { error: "Token de autorización requerido" },
      { status: 401 }
    );
  }

  const user = await validateToken(token);

  if (!user) {
    return NextResponse.json(
      { error: "Token inválido o expirado" },
      { status: 401 }
    );
  }

  return NextResponse.json({ user });
}
