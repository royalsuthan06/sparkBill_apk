@echo off
title SparkBill APK Builder
cls
echo ===================================================
echo   SparkBill POS - Flutter APK Build Automation
echo ===================================================
echo.
echo Cleaning build cache and fetching packages...
if exist "windows\flutter\ephemeral" rmdir /s /q "windows\flutter\ephemeral"
call flutter clean
call flutter pub get
echo.
echo Cache cleaned and dependencies resolved successfully!
echo.
echo Please choose the build target:
echo [1] Debug Version APK (Fast compilation, installable for testing)
echo [2] Final Release Version APK (Optimized size and speed, for distribution)
echo [3] Quit
echo.

set /p choice="Enter choice (1, 2, or 3): "

if "%choice%"=="1" goto build_debug
if "%choice%"=="2" goto build_release
if "%choice%"=="3" goto end
goto invalid_choice

:build_debug
echo.
echo Building Debug APK...
call flutter build apk --debug
if %errorlevel% neq 0 goto build_failed
echo.
echo ===================================================
echo   SUCCESS: Debug APK built successfully!
echo   Output Path: build\app\outputs\flutter-apk\app-debug.apk
echo ===================================================
goto end

:build_release
echo.
echo Building Release APK...
call flutter build apk --release
if %errorlevel% neq 0 goto build_failed
echo.
echo ===================================================
echo   SUCCESS: Release APK built successfully!
echo   Output Path: build\app\outputs\flutter-apk\app-release.apk
echo ===================================================
goto end

:build_failed
echo.
echo ===================================================
echo   ERROR: Flutter build failed!
echo   Please check the error messages above.
echo ===================================================
goto end

:invalid_choice
echo.
echo Invalid choice. Exiting...
goto end

:end
echo.
pause
