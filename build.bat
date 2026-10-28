@echo off
setlocal EnableExtensions

REM ============================================================
REM  Build Bernese Docker Image
REM  Windows Batch version
REM ============================================================

set "IMAGE_NAME=bernese54-runtime"

cd /d "%~dp0"

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Start Docker Desktop and try again.
    pause
    exit /b 1
)

docker build ^
    --build-arg "HTTP_PROXY=%HTTP_PROXY%" ^
    --build-arg "HTTPS_PROXY=%HTTPS_PROXY%" ^
    --build-arg "NO_PROXY=%NO_PROXY%" ^
    -t "%IMAGE_NAME%" ^
    .

if errorlevel 1 (
    echo.
    echo ERROR: Docker build failed.
    pause
    exit /b 1
)

exit /b 0
