#!/usr/bin/env bash
set -e

echo "============================================"
echo "  DEPLOY BACKEND A VERCEL (via Git push)"
echo "============================================"
echo ""

# Verificar que estamos en la raíz del repo
if [ ! -d ".git" ]; then
    echo "[ERROR] No se encontró .git"
    echo "Ejecuta este script desde la raíz del proyecto (VYRA/)"
    exit 1
fi

# Verificar si hay cambios en backend/
if git diff --quiet --cached backend/ 2>/dev/null && git diff --quiet backend/ 2>/dev/null; then
    echo "[INFO] No hay cambios pendientes en backend/"
    exit 0
fi

echo "Cambios detectados en backend/:"
git status --short backend/
echo ""

# Pedir mensaje de commit
read -rp "Escribe el mensaje del commit (o deja vacío para 'update backend'): " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-update backend}

echo ""
echo "[1/3] Agregando cambios..."
git add backend/

echo "[2/3] Creando commit..."
git commit -m "backend: $COMMIT_MSG"

echo "[3/3] Subiendo a GitHub..."
git push origin "$(git branch --show-current)"

echo ""
echo "============================================"
echo "  ¡DEPLOY INICIADO!"
echo "============================================"
echo ""
echo "Vercel detectará el push y hará deploy auto-"
echo "máticamente en unos segundos."
echo ""
echo "URL del proyecto: https://project-ax22f.vercel.app"
echo ""
