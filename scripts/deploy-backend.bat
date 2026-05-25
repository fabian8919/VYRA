@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   DEPLOY BACKEND A VERCEL (via Git push)
echo ============================================
echo.

:: Verificar que estamos en la raíz del repo
if not exist ".git" (
    echo [ERROR] No se encontró .git
    echo Ejecuta este script desde la raíz del proyecto (VYRA/)
    pause
    exit /b 1
)

:: Verificar si hay cambios en backend/
git diff --quiet --cached backend\ 2>nul && git diff --quiet backend\ 2>nul
if %errorlevel% == 0 (
    echo [INFO] No hay cambios pendientes en backend/
    pause
    exit /b 0
)

echo Cambios detectados en backend/:
git status --short backend\
echo.

:: Pedir mensaje de commit
set /p COMMIT_MSG="Escribe el mensaje del commit (o deja vacío para 'update backend'): "
if "!COMMIT_MSG!"=="" set COMMIT_MSG=update backend

echo.
echo [1/3] Agregando cambios...
git add backend\

echo [2/3] Creando commit...
git commit -m "backend: !COMMIT_MSG!"

echo [3/3] Subiendo a GitHub...
git push origin main

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] El push falló.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   ¡DEPLOY INICIADO!
echo ============================================
echo.
echo Vercel detectará el push y hará deploy auto-
echo máticamente en unos segundos.
echo.
echo URL del proyecto: https://project-ax22f.vercel.app
echo.
pause
