# Vyra

Aplicación Flutter moderna y minimalista con diseño azul degradado y autenticación Supabase (Email/Password).

## Características

- ✅ **Diseño minimalista y moderno** con colores azules degradados
- ✅ **Autenticación por correo y contraseña**
- ✅ **Interfaz de usuario elegante** con animaciones suaves
- ✅ **Multiplataforma**: Android, iOS, Web
- ✅ **Backend con Supabase** - Firebase alternativo open source

## Capturas de pantalla

El diseño cuenta con:
- Fondo con gradiente azul (#3B82F6 → #2563EB → #1D4ED8)
- Cards blancas con sombras suaves
- Botones con gradiente y efectos de sombra
- Iconos en azul para mantener coherencia visual

## Requisitos previos

- Flutter SDK ^3.11.1
- Una cuenta en [Supabase](https://supabase.com)

## Configuración de Supabase

### 1. Crear proyecto en Supabase

1. Ve a [Supabase Dashboard](https://app.supabase.com)
2. Crea un nuevo proyecto llamado "Vyra" (o el nombre que prefieras)
3. Espera a que el proyecto se inicialice

### 2. Obtener credenciales

1. En el panel de Supabase, ve a **Project Settings > API**
2. Copia el **Project URL** y la **anon public** API key

### 3. Configurar Autenticación

1. Ve a **Authentication > Providers**
2. Asegúrate de que **Email** esté habilitado (ya está activo por defecto)

### 4. Configurar la app

Edita `lib/main.dart` y reemplaza los valores:

```dart
await Supabase.initialize(
  url: 'https://tu-projecto-id.supabase.co',  // Tu URL de Supabase
  anonKey: 'tu-anon-key',  // Tu anon key
);
```

## Instalación

1. Clona el repositorio:
   ```bash
   git clone <repo-url>
   cd vyra
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Para iOS, instala los pods:
   ```bash
   cd ios && pod install && cd ..
   ```

4. Configura Supabase (ver sección anterior)

5. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## Estructura del proyecto

```
vyra/
├── lib/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart      # Configuración de tema y colores
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── register_screen.dart
│   │   │       └── widgets/
│   │   │           ├── custom_text_field.dart
│   │   │           └── gradient_button.dart
│   │   └── home/
│   │       └── presentation/
│   │           └── screens/
│   │               └── home_screen.dart
│   ├── services/
│   │   └── auth_service.dart       # Servicio de autenticación
│   └── main.dart
├── android/
├── ios/
└── pubspec.yaml
```

## Paleta de colores

| Color | Hex | Uso |
|-------|-----|-----|
| Azul primario | `#2563EB` | Botones principales, acentos |
| Azul claro | `#3B82F6` | Degradados |
| Azul oscuro | `#1D4ED8` | Degradados |
| Azul cielo | `#93C5FD` | Fondos secundarios |
| Texto principal | `#1E293B` | Títulos, texto importante |
| Texto secundario | `#64748B` | Subtítulos, descripciones |

## Dependencias principales

- `supabase_flutter`: Cliente de Supabase para Flutter
- `font_awesome_flutter`: Iconos de FontAwesome

## Solución de problemas

### Error: `Invalid API key`

Verifica que hayas reemplazado correctamente la URL y el anon key en `lib/main.dart`.

### Error de CocoaPods en iOS

```bash
cd ios
pod deintegrate
pod install
```

## Recursos útiles

- [Documentación de Supabase](https://supabase.com/docs)
- [Supabase Flutter Client](https://supabase.com/docs/reference/dart)
- [Autenticación con Supabase](https://supabase.com/docs/guides/auth)

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

**Nota:** Asegúrate de no subir tus credenciales de Supabase a repositorios públicos. Usa variables de entorno o archivos de configuración no versionados para credenciales sensibles.
