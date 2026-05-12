import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/users/me
 *
 * Devuelve el perfil completo del usuario autenticado,
 * combinando datos de auth.users y la tabla profiles.
 */
export async function GET(request: Request) {
  // eslint-disable-next-line no-console
  console.log("[GET /api/users/me] request received");

  const token = getBearerToken(request);

  if (!token) {
    // eslint-disable-next-line no-console
    console.log("[GET /api/users/me] no token");
    return NextResponse.json(
      { error: "Token de autorización requerido" },
      { status: 401 }
    );
  }

  const user = await validateToken(token);

  if (!user) {
    // eslint-disable-next-line no-console
    console.log("[GET /api/users/me] invalid token");
    return NextResponse.json(
      { error: "Token inválido o expirado" },
      { status: 401 }
    );
  }

  // eslint-disable-next-line no-console
  console.log("[GET /api/users/me] user:", user.id);

  const adminClient = createAdminClient();

  // Obtener perfil desde la tabla profiles
  const { data: profile, error: profileError } = await adminClient
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  // eslint-disable-next-line no-console
  console.log("[GET /api/users/me] profile:", profile, "error:", profileError);

  if (profileError && profileError.code !== "PGRST116") {
    return NextResponse.json(
      { error: profileError.message },
      { status: 500 }
    );
  }

  // Contar posts del usuario
  const { count: postsCount, error: countError } = await adminClient
    .from("post")
    .select("*", { count: "exact", head: true })
    .eq("user_id", user.id);

  if (countError) {
    // eslint-disable-next-line no-console
    console.log("[GET /api/users/me] count error:", countError.message);
  }

  const response = {
    id: user.id,
    email: user.email,
    full_name: user.user_metadata?.full_name ?? null,
    username: profile?.username ?? null,
    bio: profile?.bio ?? null,
    avatar_url: profile?.avatar_url ?? null,
    created_at: profile?.created_at ?? user.created_at,
    posts_count: postsCount ?? 0,
  };

  // eslint-disable-next-line no-console
  console.log("[GET /api/users/me] response:", response);

  return NextResponse.json(response);
}

/**
 * PATCH /api/users/me
 *
 * Actualiza el perfil del usuario autenticado.
 * Campos soportados: username, bio, avatar_url, full_name
 */
export async function PATCH(request: Request) {
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

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json(
      { error: "Cuerpo de petición inválido" },
      { status: 400 }
    );
  }

  const adminClient = createAdminClient();

  // ── 1. Actualizar auth.users (full_name en metadata) ──
  if (typeof body.full_name === "string") {
    const { error: authError } = await adminClient.auth.admin.updateUserById(
      user.id,
      { user_metadata: { full_name: body.full_name.trim() } }
    );

    if (authError) {
      return NextResponse.json(
        { error: authError.message },
        { status: 500 }
      );
    }
  }

  // ── 2. Actualizar tabla profiles ──
  const profileUpdate: Record<string, string | null> = {};

  if (typeof body.username === "string") {
    // Quitar prefijo @ si viene
    const raw = body.username.trim();
    profileUpdate.username = raw.startsWith("@") ? raw.slice(1) : raw;
  }

  if (typeof body.bio === "string") {
    profileUpdate.bio = body.bio.trim();
  }

  if (body.avatar_url === null || typeof body.avatar_url === "string") {
    profileUpdate.avatar_url = body.avatar_url as string | null;
  }

  if (Object.keys(profileUpdate).length > 0) {
    // Upsert: inserta si no existe, actualiza si existe
    const { error: upsertError } = await adminClient
      .from("profiles")
      .upsert({ id: user.id, ...profileUpdate }, { onConflict: "id" });

    if (upsertError) {
      return NextResponse.json(
        { error: upsertError.message },
        { status: 500 }
      );
    }
  }

  // ── 3. Devolver perfil actualizado ──
  const { data: profile, error: profileError } = await adminClient
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  if (profileError) {
    return NextResponse.json(
      { error: profileError.message },
      { status: 500 }
    );
  }

  return NextResponse.json({
    id: user.id,
    email: user.email,
    full_name:
      typeof body.full_name === "string"
        ? body.full_name.trim()
        : (user.user_metadata?.full_name ?? null),
    username: profile?.username ?? null,
    bio: profile?.bio ?? null,
    avatar_url: profile?.avatar_url ?? null,
    created_at: profile?.created_at ?? user.created_at,
  });
}
