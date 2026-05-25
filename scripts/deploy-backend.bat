@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   DEPLOY BACKEND A VERCEL (via CLI)
echo ============================================
echo.

:: Verificar que estamos en la raíz del repo
if not exist ".git" (
    echo [ERROR] No se encontró .git
    echo Ejecuta este script desde la raíz del proyecto (VYRA/)
    pause
    exit /b 1
)

echo [1/2] Haciendo commit de cambios del backend...
git add backend/

:: Verificar si hay cambios para commitear
git diff --cached --quiet
if %errorlevel% == 0 (
    echo [INFO] No hay cambios nuevos en backend/ para commitear.
) else (
    set /p COMMIT_MSG="Escribe el mensaje del commit (o deja vacío para 'update backend'): "
    if "!COMMIT_MSG!"=="" set COMMIT_MSG=update backend
    git commit -m "backend: !COMMIT_MSG!"
    git push origin main
)

echo.
echo [2/2] Deployando a Vercel...
cd backend
vercel --prod

echo.
echo ============================================
echo   ¡DEPLOY COMPLETADO!
echo ============================================
echo.
echo URL del proyecto: https://project-ax22f.vercel.app
echo.
pause
