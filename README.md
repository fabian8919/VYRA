# Vyra

Aplicación social construida con **Flutter** (frontend) y **Next.js + Supabase** (backend).

## 📁 Estructura del monorepo

```
vyra/
├── frontend/          ← Aplicación Flutter (iOS, Android, Web, Desktop)
└── backend/           ← API, admin panel y base de datos (Next.js + Supabase)
```

## 🚀 Cómo empezar

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

### Backend (Next.js)

```bash
cd backend
npm install
cp .env.example .env.local
# Completa tus credenciales de Supabase en .env.local
npm run dev
```

## 📖 Documentación

- [Frontend README](./frontend/README.md)
- [Backend README](./backend/README.md)
