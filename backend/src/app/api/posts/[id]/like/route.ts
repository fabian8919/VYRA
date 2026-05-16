import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * POST /api/posts/:id/like
 * Toggle like en un post (dar o quitar like).
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
  const adminClient = createAdminClient();

  // Verificar si ya existe el like
  const { data: existingLike } = await adminClient
    .from("likes")
    .select("*")
    .eq("post_id", postId)
    .eq("user_id", user.id)
    .single();

  if (existingLike) {
    // Quitar like
    const { error } = await adminClient
      .from("likes")
      .delete()
      .eq("post_id", postId)
      .eq("user_id", user.id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // El contador likes_count se actualiza automáticamente por el trigger
    // `on_like_change` definido en la migración.
    return NextResponse.json({ liked: false });
  } else {
    // Dar like
    const { error } = await adminClient
      .from("likes")
      .insert({ post_id: postId, user_id: user.id });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // El contador likes_count se actualiza automáticamente por el trigger
    // `on_like_change` definido en la migración.
    return NextResponse.json({ liked: true });
  }
}
