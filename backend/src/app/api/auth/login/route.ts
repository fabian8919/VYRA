import { NextResponse } from "next/server";
import { createAuthClient } from "@/lib/supabase/auth-client";

/**
 * POST /api/auth/login
 *
 * Recibe email y password, autentica contra Supabase Auth
 * y devuelve la sesión completa (access_token, refresh_token, user).
 */
export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => null);

    if (!body?.email || !body?.password) {
      return NextResponse.json(
        { error: "Email y contraseña son requeridos" },
        { status: 400 }
      );
    }

    const supabase = createAuthClient();

    const { data, error } = await supabase.auth.signInWithPassword({
      email: body.email,
      password: body.password,
    });

    if (error) {
      return NextResponse.json(
        { error: error.message },
        { status: 401 }
      );
    }

    if (!data.session) {
      return NextResponse.json(
        { error: "No se pudo crear la sesión" },
        { status: 500 }
      );
    }

    return NextResponse.json({
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      expires_at: data.session.expires_at,
      user: data.user,
    });
  } catch (e) {
    return NextResponse.json(
      { error: "Error interno del servidor" },
      { status: 500 }
    );
  }
}
