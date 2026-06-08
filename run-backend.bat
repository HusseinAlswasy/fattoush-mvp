@echo off
set "PORT=%PORT%"
if "%PORT%"=="" set "PORT=3000"
echo Starting Fattoush backend on port %PORT%...
start "Fattoush Backend" cmd /k "cd /d C:\Users\RTX\Documents\Codex\2026-04-30\1-mvp-3-backend-login-checkout\api && set PORT=%PORT% && echo Starting Fattoush backend on port %PORT%... && npm.cmd run start"
