import { NextResponse } from "next/server";
import { validateToken, getBearerToken } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/posts
 * Lista posts públicos con sus imágenes.
 */
export async function GET() {
  const adminClient = createAdminClient();

  const { data, error } = await adminClient
    .from("post")
    .select(`
      *,
      profiles:user_id (username, avatar_url),
      post_imagenes (
        orden,
        imagenes (url)
      )
    `)
    .order("created_at", { ascending: false })
    .limit(20);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  // Normalizar la respuesta para que las imágenes vengan como array
  const normalized = data.map((post: Record<string, unknown>) => {
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
