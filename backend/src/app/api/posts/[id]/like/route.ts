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

  // Verificar si ya existe el like (maybeSingle evita errores si no hay fila).
  const { data: existingLike } = await adminClient
    .from("likes")
    .select("id")
    .eq("post_id", postId)
    .eq("user_id", user.id)
    .maybeSingle();

  let liked: boolean;

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
    liked = false;
  } else {
    // Dar like. Usamos insert simple; la constraint UNIQUE(post_id, user_id)
    // garantiza que un usuario solo puede dar un like por post.
    const { error } = await adminClient
      .from("likes")
      .insert({ post_id: postId, user_id: user.id });

    if (error) {
      // Si la fila ya existía por una carrera, lo tratamos como "ya tiene like".
      if (error.code !== "23505") {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }
    }
    liked = true;
  }

  // Contar likes reales en tiempo real para sincronizar el cliente,
  // independientemente del estado del campo denormalizado `likes_count`.
  const { count: likesCount } = await adminClient
    .from("likes")
    .select("id", { count: "exact", head: true })
    .eq("post_id", postId);

  return NextResponse.json({
    liked,
    likes_count: likesCount ?? 0,
  });
}
