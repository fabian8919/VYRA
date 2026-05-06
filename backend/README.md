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

## 🌐 Deploy en Vercel

### 1. Preparar el proyecto

Asegúrate de que `backend/.env.local` tenga tus credenciales reales (no se sube al repo, está en `.gitignore`).

### 2. Instalar Vercel CLI

```bash
npm i -g vercel
```

### 3. Login y deploy

Desde la carpeta `backend/`:

```bash
cd backend
vercel --prod
```

O conecta tu repositorio de GitHub/GitLab en [vercel.com](https://vercel.com) para deploys automáticos en cada `push`.

### 4. Configurar variables de entorno en Vercel

En el dashboard de Vercel → **Settings** → **Environment Variables**, agrega:

| Variable | Valor |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://tu-proyecto.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbG...` |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbG...` |
| `NEXT_PUBLIC_APP_URL` | `https://tu-backend.vercel.app` |
| `ALLOWED_ORIGIN` | `*` (dev) o URL de tu app Flutter |

> ⚠️ **NUNCA** expongas `SUPABASE_SERVICE_ROLE_KEY` en el frontend.

### 5. Actualizar el frontend

Cambia la URL del backend en `frontend/lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://tu-backend.vercel.app';
```

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
