# Vyra — Backend

API y panel administrativo construidos con **Next.js** + **Supabase**.

## 🚀 Tecnologías

- [Next.js](https://nextjs.org/) — App Router + API Routes
- [TypeScript](https://www.typescriptlang.org/)
- [Supabase](https://supabase.com/) — Base de datos PostgreSQL, Auth, Storage
- [Tailwind CSS](https://tailwindcss.com/)

## 📁 Estructura clave

```
src/
├── app/
│   ├── api/           ← API Routes (tu backend REST)
│   ├── layout.tsx
│   └── page.tsx
├── lib/
│   └── supabase/
│       ├── client.ts   ← Browser client
│       ├── server.ts   ← Server client (con cookies)
│       ├── admin.ts    ← Service role client (solo servidor)
│       └── middleware.ts
└── types/
    └── database.ts     ← Tipos de la DB
database/
└── migrations/         ← Migraciones SQL versionadas
```

## ⚙️ Configuración local

1. Copia las variables de entorno:

   ```bash
   cp .env.example .env.local
   ```

2. Completa tus credenciales de Supabase en `.env.local`.

3. Instala dependencias (si aún no lo hiciste):

   ```bash
   npm install
   ```

4. Inicia el servidor de desarrollo:

   ```bash
   npm run dev
   ```

   Abre [http://localhost:3000](http://localhost:3000).

## 🗄️ Supabase CLI

Este proyecto incluye la CLI de Supabase como dependencia de desarrollo.

```bash
# Iniciar Supabase local (requiere Docker)
npx supabase start

# Crear una nueva migración
npx supabase migration new nombre_de_cambio

# Aplicar migraciones locales
npx supabase db reset

# Generar tipos TypeScript desde tu proyecto remoto
npx supabase gen types typescript --project-id <tu-project-id> --schema public > src/types/database.ts
```

## 🔒 Seguridad

- `NEXT_PUBLIC_SUPABASE_ANON_KEY` → Solo operaciones que respeten RLS.
- `SUPABASE_SERVICE_ROLE_KEY` → Nunca expongas esta clave al cliente. Úsala solo en API Routes o Server Actions.
