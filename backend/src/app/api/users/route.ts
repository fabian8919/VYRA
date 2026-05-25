import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * GET /api/users
 * - Sin query params: lista usuarios (requiere autenticación).
 * - Con ?id=xxx: devuelve perfil público de ese usuario (no requiere auth).
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get("id");

  // ── Perfil público de otro usuario ──
  if (id) {
    const adminClient = createAdminClient();

    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .select("*")
      .eq("id", id)
      .single();

    if (profileError && profileError.code !== "PGRST116") {
      return NextResponse.json({ error: profileError.message }, { status: 500 });
    }

    const { data: authUser, error: authError } = await adminClient.auth.admin.getUserById(id);
    if (authError) {
      // eslint-disable-next-line no-console
      console.log("[GET /api/users?id=] auth error:", authError.message);
    }

    const user = authUser?.user;

    const { count: postsCount, error: countError } = await adminClient
      .from("post")
      .select("*", { count: "exact", head: true })
      .eq("user_id", id);

    if (countError) {
      // eslint-disable-next-line no-console
      console.log("[GET /api/users?id=] count error:", countError.message);
    }

    return NextResponse.json({
      id,
      email: user?.email ?? null,
      full_name: user?.user_metadata?.full_name ?? profile?.full_name ?? null,
      username: profile?.username ?? null,
      bio: profile?.bio ?? null,
      avatar_url: profile?.avatar_url ?? null,
      created_at: profile?.created_at ?? user?.created_at ?? null,
      posts_count: postsCount ?? 0,
    });
  }

  // ── Listado protegido de usuarios ──
  const supabase = await createClient();

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .limit(20);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ data });
}
