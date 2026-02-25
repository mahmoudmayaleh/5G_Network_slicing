@echo off
REM Build script for 5G Network Slicing Docker images (Windows)

echo ========================================
echo 5G Network Slicing - Docker Build
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running
    exit /b 1
)

REM Build base image
echo [1/5] Building base image...
docker build -f dockerimages/Dockerfile -t baseimage:nova .
if errorlevel 1 (
    echo Failed to build base image
    exit /b 1
)
echo + Base image built successfully
echo.

REM Build 5G Core image
echo [2/5] Building 5G Core image...
docker build -f dockerimages/Dockerfile.5GC -t 5gcimg:nova .
if errorlevel 1 (
    echo Failed to build 5G Core image
    exit /b 1
)
echo + 5G Core image built successfully
echo.

REM Build gNB image
echo [3/5] Building gNB image...
docker build -f dockerimages/Dockerfile.gnb -t gnb:nova .
if errorlevel 1 (
    echo Failed to build gNB image
    exit /b 1
)
echo + gNB image built successfully
echo.

REM Build GNU Radio image
echo [4/5] Building GNU Radio image...
docker build -f dockerimages/Dockerfile.GNU -t gnu:nova .
if errorlevel 1 (
    echo Failed to build GNU Radio image
    exit /b 1
)
echo + GNU Radio image built successfully
echo.

REM Build UE image
echo [5/5] Building UE image...
docker build -f dockerimages/Dockerfile.UE -t ue:nova .
if errorlevel 1 (
    echo Failed to build UE image
    exit /b 1
)
echo + UE image built successfully
echo.

echo ========================================
echo All images built successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Start containers: docker compose up -d
echo 2. Follow the deployment guide in docs\DEPLOYMENT.md
echo.

REM Show built images
echo Built images:
docker images | findstr "baseimage 5gcimg gnb gnu ue" | findstr "nova"

pause
