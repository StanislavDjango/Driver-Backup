@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0dist\DriverVault.exe" (
  start "" "%~dp0dist\DriverVault.exe"
  exit /b
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DriverVault.ps1" -Language Auto
