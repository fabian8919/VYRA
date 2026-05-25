import { NextRequest, NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/users/me/posts
 * Lista los posts del usuario autenticado con sus imágenes.
 *
 * Query param opcional: ?userId=xxx
 * Si se proporciona, devuelve los posts públicos de ese usuario (sin requerir auth).
 */
export async function GET(request: NextRequest) {
  const userIdParam = request.nextUrl.searchParams.get("userId");

  let targetUserId: string;

  if (userIdParam) {
    targetUserId = userIdParam;
  } else {
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

    targetUserId = user.id;
  }

  const adminClient = createAdminClient();

  // 1. Obtener posts del usuario
  const { data: postsData, error: postsError } = await adminClient
    .from("post")
    .select("*")
    .eq("user_id", targetUserId)
    .order("created_at", { ascending: false });

  if (postsError) {
    return NextResponse.json({ error: postsError.message }, { status: 500 });
  }

  const posts = (postsData ?? []) as Record<string, unknown>[];

  // 2. Obtener relaciones post-imagen
  const postIds = posts.map((p) => p.id as string);
  let imagesMap: Record<string, string[]> = {};
  if (postIds.length > 0) {
    const { data: relData } = await adminClient
      .from("post_imagenes")
      .select("post_id, imagen_id, orden")
      .in("post_id", postIds);

    const rels = (relData ?? []) as Array<{
      post_id: string;
      imagen_id: string;
      orden: number;
    }>;

    // 3. Obtener URLs de imágenes por imagen_id
    const imageIds = [...new Set(rels.map((r) => r.imagen_id))];
    let imageUrlsMap: Record<string, string> = {};
    if (imageIds.length > 0) {
      const { data: imgData } = await adminClient
        .from("imagenes")
        .select("id, url")
        .in("id", imageIds);

      imageUrlsMap = Object.fromEntries(
        (imgData ?? []).map((img) => [img.id, img.url])
      );
    }

    // Agrupar y ordenar imágenes por post
    for (const rel of rels) {
      if (!imagesMap[rel.post_id]) imagesMap[rel.post_id] = [];
      const url = imageUrlsMap[rel.imagen_id];
      if (url) imagesMap[rel.post_id].push(url);
    }

    for (const pid of Object.keys(imagesMap)) {
      const sortedRels = rels
        .filter((r) => r.post_id === pid)
        .sort((a, b) => a.orden - b.orden);
      imagesMap[pid] = sortedRels
        .map((r) => imageUrlsMap[r.imagen_id])
        .filter((url): url is string => !!url);
    }
  }

  // 3. Normalizar respuesta
  const normalized = posts.map((post) => ({
    ...post,
    image_urls: imagesMap[post.id as string] ?? [],
  }));

  return NextResponse.json({ data: normalized });
}
