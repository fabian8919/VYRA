-- ============================================================
-- Creación de tabla public.profiles para VYRA
-- Ejecutar esto en el SQL Editor de Supabase (nueva consulta)
-- ============================================================

-- 1. Crear tabla profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Comentarios para documentación
COMMENT ON TABLE public.profiles IS 'Perfiles de usuario vinculados a auth.users';
COMMENT ON COLUMN public.profiles.id IS 'UUID del usuario de auth.users';
COMMENT ON COLUMN public.profiles.username IS 'Nombre de usuario único (handle)';

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de seguridad

-- Cualquiera puede ver perfiles públicos
CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles
  FOR SELECT
  USING (true);

-- Solo el dueño puede actualizar su perfil
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Solo el dueño puede insertar su propio perfil (si se hace manualmente)
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 5. Función para crear perfil automáticamente al registrar usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Trigger que ejecuta la función después de insertar en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 7. (Opcional) Migrar usuarios existentes de auth.users a profiles
-- Si ya tienes usuarios registrados, descomenta y ejecuta esto:
-- INSERT INTO public.profiles (id, username, full_name, avatar_url, bio)
-- SELECT 
--   id,
--   raw_user_meta_data->>'username',
--   raw_user_meta_data->>'full_name',
--   raw_user_meta_data->>'avatar_url',
--   raw_user_meta_data->>'bio'
-- FROM auth.users
-- ON CONFLICT (id) DO NOTHING;
