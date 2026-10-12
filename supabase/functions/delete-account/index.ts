import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user }, error } = await userClient.auth.getUser();
  if (error || !user) return new Response("Unauthorized", { status: 401 });

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // Files live at <uid>/<itemId>/<file>; walk the two levels and remove everything.
  const bucket = admin.storage.from("attachments");
  const { data: folders } = await bucket.list(user.id, { limit: 1000 });
  const paths: string[] = [];
  for (const f of folders ?? []) {
    const { data: files } = await bucket.list(`${user.id}/${f.name}`, { limit: 1000 });
    for (const file of files ?? []) paths.push(`${user.id}/${f.name}/${file.name}`);
  }
  if (paths.length) await bucket.remove(paths);

  const { error: delErr } = await admin.auth.admin.deleteUser(user.id);
  if (delErr) return new Response("Failed", { status: 500 });
  return new Response(JSON.stringify({ deleted: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
