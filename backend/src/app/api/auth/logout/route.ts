import { NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { getBearerToken } from "@/lib/auth";

/**
 * POST /api/auth/logout
 *
 * Revoca la sesión del usuario en Supabase Auth.
 */
export async function POST(request: Request) {
  const token = getBearerToken(request);

  if (!token) {
    return NextResponse.json(
      { error: "Token de autorización requerido" },
      { status: 401 }
    );
  }

  try {
    const supabase = createAdminClient();

    const { error } = await supabase.auth.admin.signOut(token);

    if (error) {
      return NextResponse.json(
        { error: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({ message: "Sesión cerrada correctamente" });
  } catch (e) {
    return NextResponse.json(
      { error: "Error interno del servidor" },
      { status: 500 }
    );
  }
}
