import { NextResponse } from "next/server";
import { createAuthClient } from "@/lib/supabase/auth-client";

/**
 * POST /api/auth/register
 *
 * Crea un nuevo usuario en Supabase Auth y devuelve la sesión.
 * Opcionalmente crea el perfil en public.profiles.
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

    const { data, error } = await supabase.auth.signUp({
      email: body.email,
      password: body.password,
      options: {
        data: {
          full_name: body.name ?? null,
        },
      },
    });

    if (error) {
      return NextResponse.json(
        { error: error.message },
        { status: 400 }
      );
    }

    // Si la confirmación de email está desactivada, signUp inicia sesión automáticamente
    if (data.session) {
      return NextResponse.json(
        {
          access_token: data.session.access_token,
          refresh_token: data.session.refresh_token,
          expires_at: data.session.expires_at,
          user: data.user,
        },
        { status: 201 }
      );
    }

    // Si requiere confirmación de email
    return NextResponse.json(
      {
        message: "Registro exitoso. Revisa tu correo para confirmar tu cuenta.",
        user: data.user,
      },
      { status: 201 }
    );
  } catch (e) {
    return NextResponse.json(
      { error: "Error interno del servidor" },
      { status: 500 }
    );
  }
}
