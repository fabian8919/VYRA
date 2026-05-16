import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/posts/:id/comments
 * Lista comentarios de un post con perfil del autor.
 */
export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id: postId } = await params;
  const adminClient = createAdminClient();

  const { data, error } = await adminClient
    .from("comentarios")
    .select("id, user_id, post_id, contenido, parent_id, created_at, reports_count")
    .eq("post_id", postId)
    .order("created_at", { ascending: false })
    .limit(50);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const comments = (data ?? []) as Record<string, unknown>[];
  const userIds = [...new Set(comments.map((c) => c.user_id as string).filter(Boolean))];

  // Obtener perfiles
  let profilesMap: Record<string, { username: string | null; avatar_url: string | null }> = {};
  if (userIds.length > 0) {
    const { data: profilesData } = await adminClient
      .from("profiles")
      .select("id, username, avatar_url")
      .in("id", userIds);

    profilesMap = Object.fromEntries(
      (profilesData ?? []).map((p) => [p.id, p])
    );
  }

  const normalized = comments.map((comment) => ({
    ...comment,
    profiles: profilesMap[comment.user_id as string] ?? null,
  }));

  return NextResponse.json({ data: normalized });
}

/**
 * POST /api/posts/:id/comments
 * Crea un nuevo comentario en un post.
 */
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
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

  const { id: postId } = await params;
  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json(
      { error: "Cuerpo de petición inválido" },
      { status: 400 }
    );
  }

  const contenido = typeof body.contenido === "string" ? body.contenido.trim() : "";
  if (!contenido) {
    return NextResponse.json(
      { error: "El contenido es requerido" },
      { status: 400 }
    );
  }

  const adminClient = createAdminClient();

  const { data, error } = await adminClient
    .from("comentarios")
    .insert({
      post_id: postId,
      user_id: user.id,
      contenido,
      parent_id: typeof body.parent_id === "string" ? body.parent_id : null,
    })
    .select("id, user_id, post_id, contenido, parent_id, created_at, reports_count")
    .single();

  if (error || !data) {
    return NextResponse.json(
      { error: error?.message ?? "Error al crear comentario" },
      { status: 500 }
    );
  }

  // Adjuntar el perfil del autor para que el cliente pueda mostrar
  // username/avatar inmediatamente sin recargar.
  const { data: profileData } = await adminClient
    .from("profiles")
    .select("id, username, avatar_url")
    .eq("id", user.id)
    .single();

  const normalized = {
    ...data,
    profiles: profileData ?? null,
  };

  // El contador comentarios_count se actualiza automáticamente por el trigger
  // `on_comment_change` definido en la migración.
  return NextResponse.json({ data: normalized }, { status: 201 });
}
