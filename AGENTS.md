# VYRA - Contexto del proyecto

> Última actualización: 2026-05-11
> Sesión actual: Implementación de posts/publicaciones

## Stack

- **Backend**: Next.js 15 (App Router) + Supabase (Node.js API Routes)
- **Frontend**: Flutter 3 + Supabase Flutter + `http` para API propia
- **Auth**: JWT Bearer tokens + Supabase Auth

## Convenciones clave

- El backend usa **Next.js App Router** con rutas en `backend/src/app/api/...`
- El frontend Flutter se comunica con el backend vía HTTP (no directo a Supabase para auth/posts)
- Las imágenes se suben **desde Flutter directo a Supabase Storage** (bucket `images`), luego se envían las URLs al backend
- Token de sesión se guarda en `SharedPreferences` y se envía como `Authorization: Bearer <token>`
- El backend usa `validateToken()` + `createAdminClient()` (service_role) para bypass RLS

## Endpoints implementados

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/auth/login` | POST | Login con email/password |
| `/api/auth/register` | POST | Registro |
| `/api/auth/me` | GET | Validar token, retorna usuario |
| `/api/auth/logout` | POST | Cerrar sesión |
| `/api/users/me` | GET | Perfil completo (+ `posts_count`) |
| `/api/users/me` | PATCH | Editar perfil (username, bio, avatar_url, full_name) |
| `/api/users/me/posts` | GET | Posts del usuario autenticado con imágenes |
| `/api/posts` | GET | Feed público de posts |
| `/api/posts` | POST | Crear post con imágenes |

## Esquema de base de datos (Supabase)

### `public.profiles`
- `id` UUID (PK, refs auth.users)
- `username`, `full_name`, `bio`, `avatar_url`
- `created_at`, `updated_at`

### `public.post`
- `id` UUID (PK)
- `user_id` UUID (refs auth.users)
- `descripcion` TEXT
- `created_at`, `updated_at`

### `public.imagenes`
- `id` UUID (PK)
- `url` TEXT
- `user_id` UUID (quién subió la imagen)
- `created_at`

### `public.post_imagenes`
- `id` UUID (PK)
- `post_id` UUID (refs post)
- `imagen_id` UUID (refs imagenes)
- `orden` INT (empieza en 1)

## Flujo de crear publicación

1. Flutter: usuario selecciona imágenes + escribe descripción
2. Flutter: `PostService.uploadImages()` → sube a Storage bucket `images/{userId}/{timestamp}_i.jpg`
3. Flutter: `PostService.createPost()` → envía `{ descripcion, imageUrls }` al backend
4. Backend: inserta en `post` → `imagenes` (con user_id) → `post_imagenes` (orden desde 1)
5. Perfil recarga automáticamente al volver

## Servicios de Flutter

- `AuthService` (`frontend/lib/services/auth_service.dart`): auth completo, tokens, perfil
- `PostService` (`frontend/lib/services/post_service.dart`): uploadImages, createPost, getMyPosts

## Pantallas principales

- `ProfileScreen`: muestra perfil real, posts reales (grid), stats reales, navega a detalle
- `PostDetailScreen`: vista tipo Instagram del post (carrusel, descripción, fecha, acciones)
- `CreatePostScreen`: selección múltiple de imágenes, preview, descripción, publicar
- `EditProfileScreen`: edición de perfil + avatar (sube a Storage)

## Pendientes / próximos pasos sugeridos

- [ ] Likes reales (tabla + endpoints)
- [ ] Comentarios reales
- [ ] Feed global en HomeScreen
- [ ] Seguidores/following real (tablas + endpoints)
- [ ] Notificaciones reales
- [ ] Eliminar/editar posts propios
- [ ] Stories / archivados

## Notas importantes

- Campo de post se llama `descripcion` (no `description`)
- `post_imagenes.orden` empieza en 1
- Las imágenes del avatar también van al bucket `images` en carpeta `{userId}/`
- Al limpiar registros de posts usar:
  ```sql
  TRUNCATE public.post_imagenes RESTART IDENTITY CASCADE;
  TRUNCATE public.imagenes RESTART IDENTITY CASCADE;
  TRUNCATE public.post RESTART IDENTITY CASCADE;
  DELETE FROM storage.objects WHERE bucket_id = 'images';
  ```
