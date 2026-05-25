import { NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/users/[id]/posts
 *
 * Lista los posts públicos de un usuario por su ID con sus imágenes.
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

  // 1. Obtener posts del usuario
  const { data: postsData, error: postsError } = await adminClient
    .from("post")
    .select("*")
    .eq("user_id", id)
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

  // 4. Normalizar respuesta
  const normalized = posts.map((post) => ({
    ...post,
    image_urls: imagesMap[post.id as string] ?? [],
  }));

  return NextResponse.json({ data: normalized });
}
