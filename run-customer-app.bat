@echo off
start "Fattoush Customer App" cmd /k "cd /d C:\Users\RTX\Documents\Codex\2026-04-30\1-mvp-3-backend-login-checkout\apps\customer_app && echo Mapping Android phone to local backend on port 3001... && C:\Users\RTX\AppData\Local\Android\sdk\platform-tools\adb.exe -s R5GL10DGTQY reverse tcp:3001 tcp:3001 && echo Starting Flutter app on device R5GL10DGTQY... && flutter run -d R5GL10DGTQY"
