import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * GET /api/posts
 * Lista posts públicos.
 */
export async function GET() {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("posts")
    .select("*, profiles(username, avatar_url)")
    .order("created_at", { ascending: false })
    .limit(20);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ data });
}

/**
 * POST /api/posts
 * Crea un nuevo post (requiere autenticación).
 */
export async function POST(request: Request) {
  const supabase = await createClient();

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await request.json().catch(() => null);
  if (!body?.content) {
    return NextResponse.json(
      { error: "Content is required" },
      { status: 400 }
    );
  }

  const { data, error } = await supabase
    .from("posts")
    .insert({
      user_id: user.id,
      content: body.content,
      media_url: body.media_url || null,
    })
    .select()
    .single();

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ data }, { status: 201 });
}
