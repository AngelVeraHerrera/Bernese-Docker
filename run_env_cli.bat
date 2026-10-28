@echo off
setlocal EnableExtensions

REM ============================================================
REM  Run Bernese Installed Environment in CLI/BPE Mode
REM  Windows Batch version
REM ============================================================

set "IMAGE_NAME=bernese54-runtime"
set "CONTAINER_NAME=bernese54-cli"
set "SHARED_DIR=%USERPROFILE%\bernese54-shared"

set "MOUNT_GPSDATA=0"

REM ------------------------------------------------------------
REM  Parse command-line arguments
REM ------------------------------------------------------------

:parse_args
if "%~1"=="" goto args_done

if /I "%~1"=="--gpsdata" (
    set "MOUNT_GPSDATA=1"
    shift
    goto parse_args
)

if /I "%~1"=="-h" goto show_help
if /I "%~1"=="--help" goto show_help

echo Unknown option: %~1
echo Usage: %~nx0 [--gpsdata]
exit /b 1

:show_help
echo Usage: %~nx0 [--gpsdata]
echo.
echo Options:
echo   --gpsdata    Mount the GPSDATA directory
echo   -h, --help   Show this help message
exit /b 0

:args_done

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Start Docker Desktop and try again.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM  Create shared directories
REM ------------------------------------------------------------

if not exist "%SHARED_DIR%\GPSWORK" mkdir "%SHARED_DIR%\GPSWORK" || goto error
if not exist "%SHARED_DIR%\EXPORT" mkdir "%SHARED_DIR%\EXPORT" || goto error

REM ------------------------------------------------------------
REM  Configure Docker arguments
REM ------------------------------------------------------------

set "DOCKER_ARGS=--rm -it --name %CONTAINER_NAME% --hostname bernese54"
set "DOCKER_ARGS=%DOCKER_ARGS% -e BERNESE_DEBUG=1"
set "DOCKER_ARGS=%DOCKER_ARGS% -v "%SHARED_DIR%\GPSWORK:/home/bernese/GPSWORK""
set "DOCKER_ARGS=%DOCKER_ARGS% -v "%SHARED_DIR%\EXPORT:/home/bernese/EXPORT""

REM ------------------------------------------------------------
REM  Optional GPSDATA mount
REM ------------------------------------------------------------

if "%MOUNT_GPSDATA%"=="0" goto run

if not exist "%SHARED_DIR%\GPSDATA\CAMPAIGN54" mkdir "%SHARED_DIR%\GPSDATA\CAMPAIGN54" || goto error
if not exist "%SHARED_DIR%\GPSDATA\DATAPOOL" mkdir "%SHARED_DIR%\GPSDATA\DATAPOOL" || goto error
if not exist "%SHARED_DIR%\GPSDATA\SAVEDISK" mkdir "%SHARED_DIR%\GPSDATA\SAVEDISK" || goto error

set "DOCKER_ARGS=%DOCKER_ARGS% -v "%SHARED_DIR%\GPSDATA:/home/bernese/GPSDATA""

REM ------------------------------------------------------------
REM  Start container
REM ------------------------------------------------------------

:run
docker run %DOCKER_ARGS% %IMAGE_NAME% bash

if errorlevel 125 (
    echo.
    echo ERROR: Could not start the container.
    pause
    exit /b 1
)

exit /b 0

:error
echo ERROR: Could not create the required shared directories.
pause
exit /b 1
