import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/users/me/posts
 * Lista los posts del usuario autenticado con sus imágenes.
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

  const adminClient = createAdminClient();

  const { data, error } = await adminClient
    .from("post")
    .select(`
      *,
      post_imagenes (
        orden,
        imagenes (url)
      )
    `)
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  // Normalizar respuesta
  const normalized = (data ?? []).map((post: Record<string, unknown>) => {
    const rawImages = post.post_imagenes as Array<{
      orden: number;
      imagenes: { url: string } | null;
    }> | null;

    const imageUrls = (rawImages ?? [])
      .filter((pi) => pi.imagenes?.url)
      .sort((a, b) => a.orden - b.orden)
      .map((pi) => pi.imagenes!.url);

    return {
      ...post,
      image_urls: imageUrls,
    };
  });

  return NextResponse.json({ data: normalized });
}
