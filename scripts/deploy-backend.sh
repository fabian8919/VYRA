#!/usr/bin/env bash
set -e

echo "============================================"
echo "  DEPLOY BACKEND A VERCEL (via CLI)"
echo "============================================"
echo ""

# Verificar que estamos en la raíz del repo
if [ ! -d ".git" ]; then
    echo "[ERROR] No se encontró .git"
    echo "Ejecuta este script desde la raíz del proyecto (VYRA/)"
    exit 1
fi

echo "[1/2] Haciendo commit de cambios del backend..."
git add backend/

if git diff --cached --quiet; then
    echo "[INFO] No hay cambios nuevos en backend/ para commitear."
else
    read -rp "Escribe el mensaje del commit (o deja vacío para 'update backend'): " COMMIT_MSG
    COMMIT_MSG=${COMMIT_MSG:-update backend}
    git commit -m "backend: $COMMIT_MSG"
    git push origin "$(git branch --show-current)"
fi

echo ""
echo "[2/2] Deployando a Vercel..."
cd backend
npx vercel --prod

echo ""
echo "============================================"
echo "  ¡DEPLOY COMPLETADO!"
echo "============================================"
echo ""
echo "URL del proyecto: https://project-ax22f.vercel.app"
echo ""
