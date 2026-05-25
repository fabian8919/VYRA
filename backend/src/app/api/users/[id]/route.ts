import { NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

// Forzar runtime Node.js para evitar 404 en rutas dinámicas en Vercel
export const runtime = "nodejs";

/**
 * GET /api/users/[id]
 *
 * Devuelve el perfil público de un usuario por su ID.
 * No requiere autenticación.
 */
export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;

  if (!id) {
    return NextResponse.json(
      { error: "ID de usuario requerido" },
      { status: 400 }
    );
  }

  const adminClient = createAdminClient();

  // 1. Obtener perfil desde la tabla profiles
  const { data: profile, error: profileError } = await adminClient
    .from("profiles")
    .select("*")
    .eq("id", id)
    .single();

  if (profileError && profileError.code !== "PGRST116") {
    return NextResponse.json(
      { error: profileError.message },
      { status: 500 }
    );
  }

  // 2. Obtener datos de auth.users (email, full_name, created_at)
  const { data: authUser, error: authError } = await adminClient.auth.admin.getUserById(id);

  if (authError) {
    // eslint-disable-next-line no-console
    console.log("[GET /api/users/:id] auth error:", authError.message);
  }

  const user = authUser?.user;

  // 3. Contar posts del usuario
  const { count: postsCount, error: countError } = await adminClient
    .from("post")
    .select("*", { count: "exact", head: true })
    .eq("user_id", id);

  if (countError) {
    // eslint-disable-next-line no-console
    console.log("[GET /api/users/:id] count error:", countError.message);
  }

  const response = {
    id: id,
    email: user?.email ?? null,
    full_name: user?.user_metadata?.full_name ?? profile?.full_name ?? null,
    username: profile?.username ?? null,
    bio: profile?.bio ?? null,
    avatar_url: profile?.avatar_url ?? null,
    created_at: profile?.created_at ?? user?.created_at ?? null,
    posts_count: postsCount ?? 0,
  };

  return NextResponse.json(response);
}
