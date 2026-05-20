import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/posts
 * Lista posts públicos con sus imágenes.
 */
export async function GET(request: Request) {
  const adminClient = createAdminClient();

  // 1. Obtener posts
  const { data: postsData, error: postsError } = await adminClient
    .from("post")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(20);

  if (postsError) {
    return NextResponse.json({ error: postsError.message }, { status: 500 });
  }

  const posts = (postsData ?? []) as Record<string, unknown>[];
  const userIds = [...new Set(posts.map((p) => p.user_id as string).filter(Boolean))];

  // 2. Obtener perfiles de los usuarios
  let profilesMap: Record<string, { username: string | null; avatar_url: string | null }> = {};
  if (userIds.length > 0) {
    const { data: profilesData } = await adminClient
      .from("profiles")
      .select("id, username, avatar_url")
      .in("id", userIds);

    profilesMap = Object.fromEntries(
      (profilesData ?? []).map((profile) => [profile.id, profile])
    );
  }

  // 3. Obtener relaciones post-imagen
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

    // 4. Obtener URLs de imágenes por imagen_id
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

  // 5. Si hay usuario autenticado, obtener sus likes
  let likedPostIds = new Set<string>();
  const token = getBearerToken(request);
  if (token) {
    const user = await validateToken(token);
    if (user && postIds.length > 0) {
      const { data: likesData } = await adminClient
        .from("likes")
        .select("post_id")
        .eq("user_id", user.id)
        .in("post_id", postIds);

      likedPostIds = new Set(
        (likesData ?? []).map((like) => like.post_id as string)
      );
    }
  }

  // 5.b. Contar likes y comentarios reales desde las tablas (evita usar los
  // contadores denormalizados que podrían estar desincronizados).
  const likesCountMap: Record<string, number> = {};
  const commentsCountMap: Record<string, number> = {};
  if (postIds.length > 0) {
    const { data: allLikes } = await adminClient
      .from("likes")
      .select("post_id")
      .in("post_id", postIds);
    for (const row of (allLikes ?? []) as Array<{ post_id: string }>) {
      likesCountMap[row.post_id] = (likesCountMap[row.post_id] ?? 0) + 1;
    }

    const { data: allComments } = await adminClient
      .from("comentarios")
      .select("post_id")
      .in("post_id", postIds);
    for (const row of (allComments ?? []) as Array<{ post_id: string }>) {
      commentsCountMap[row.post_id] = (commentsCountMap[row.post_id] ?? 0) + 1;
    }
  }

  // 6. Normalizar respuesta
  const normalized = posts.map((post) => ({
    ...post,
    profiles: profilesMap[post.user_id as string] ?? null,
    image_urls: imagesMap[post.id as string] ?? [],
    is_liked: likedPostIds.has(post.id as string),
    likes_count: likesCountMap[post.id as string] ?? 0,
    comentarios_count: commentsCountMap[post.id as string] ?? 0,
  }));

  return NextResponse.json({ data: normalized });
}

/**
 * POST /api/posts
 * Crea un nuevo post con imágenes (requiere autenticación).
 * Body: { description: string, imageUrls: string[] }
 */
export async function POST(request: Request) {
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

  const descripcion = typeof body.descripcion === "string" ? body.descripcion.trim() : "";
  const imageUrls = Array.isArray(body.imageUrls)
    ? body.imageUrls.filter((u): u is string => typeof u === "string")
    : [];

  if (!descripcion && imageUrls.length === 0) {
    return NextResponse.json(
      { error: "Debes proporcionar una descripción o al menos una imagen" },
      { status: 400 }
    );
  }

  const adminClient = createAdminClient();

  // 1. Insertar el post
  const { data: postData, error: postError } = await adminClient
    .from("post")
    .insert({ user_id: user.id, descripcion })
    .select()
    .single();

  if (postError || !postData) {
    return NextResponse.json(
      { error: postError?.message ?? "Error al crear el post" },
      { status: 500 }
    );
  }

  const postId = postData.id as string;

  // 2. Insertar imágenes y relaciones
  const insertedImageUrls: string[] = [];

  for (let i = 0; i < imageUrls.length; i++) {
    const url = imageUrls[i];

    // Insertar en imagenes
    const { data: imgData, error: imgError } = await adminClient
      .from("imagenes")
      .insert({ url, user_id: user.id })
      .select()
      .single();

    if (imgError || !imgData) {
      // eslint-disable-next-line no-console
      console.error("[POST /api/posts] error insertando imagen:", imgError?.message);
      continue;
    }

    // Insertar relación en post_imagenes
    const { error: relError } = await adminClient
      .from("post_imagenes")
      .insert({
        post_id: postId,
        imagen_id: imgData.id,
        orden: i + 1,
      });

    if (relError) {
      // eslint-disable-next-line no-console
      console.error("[POST /api/posts] error insertando relación:", relError.message);
      continue;
    }

    insertedImageUrls.push(url);
  }

  return NextResponse.json(
    {
      data: {
        ...postData,
        image_urls: insertedImageUrls,
      },
    },
    { status: 201 }
  );
}
