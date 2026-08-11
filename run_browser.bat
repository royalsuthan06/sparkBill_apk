@echo off
echo ===================================================
echo   SparkBill POS - Launching Developer Live Server
echo ===================================================
echo.
echo Running Dart/Flutter POS Application on Web Browser...
echo.
cd /d "%~dp0"
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
pause
