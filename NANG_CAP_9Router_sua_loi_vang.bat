@echo off
setlocal
title FIX 9Router - chong Antigravity trang man hinh (V8)
color 0B

REM =============================================================
REM  FIX 9ROUTER - ANTIGRAVITY BI TRANG MAN HINH / AGENT ERROR
REM =============================================================
REM  Da xac dinh tu log that:
REM   1. Mitm loc sai chunk -> agent "terminated" (da fix V8)
REM   2. Khong co uncaughtException -> MITM tu chet (da fix)
REM   3. Error-frame giua stream -> LS panic (da fix)
REM =============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Dang xin quyen Admin... hay bam YES neu UAC hoi.
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ================================================================
echo   FIX 9ROUTER V8  -  ANTIGRAVITY
echo ================================================================
echo.

echo [1/5] Dong 9Router / MITM cu...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :20128 ^| findstr LISTENING') do taskkill /F /T /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :443 ^| findstr LISTENING') do taskkill /F /T /PID %%a >nul 2>&1
timeout /t 3 /nobreak >nul
echo       Da dong.

echo.
echo [2/5] Ap patch V8 vao MITM...
node "%APPDATA%\9router\9router-mitm-fix.js"
if %errorLevel% neq 0 (
    color 0E
    echo.
    echo   [CANH BAO] Patch bao loi. File cu duoc giu nguyen.
)

echo.
echo [3/5] Bat lai 9Router (cua so rieng - KHONG dong no)...
start "9Router" cmd /k "title 9Router && 9router"
echo       Dang cho MITM khoi dong (toi da 90 giay)...

set /a WAIT=0
:WAITMITM
timeout /t 5 /nobreak >nul
set /a WAIT+=5
netstat -aon | findstr :443 | findstr LISTENING >nul 2>&1
if %errorLevel% equ 0 goto MITM_OK
if %WAIT% lss 90 goto WAITMITM
echo       [!] MITM chua len sau %WAIT%s. Xem cua so 9Router vua mo.
goto VERIFY

:MITM_OK
echo       [OK] MITM da len (sau ~%WAIT%s).

:VERIFY
echo.
echo ---------------- KIEM TRA ----------------
powershell -NoProfile -Command "$r=Get-NetTCPConnection -State Listen -LocalPort 20128 -EA SilentlyContinue; if($r){Write-Host '  [OK] 9Router: port 20128'}else{Write-Host '  [!] 9Router chua len'}; $m=Get-NetTCPConnection -State Listen -LocalPort 443 -EA SilentlyContinue; if($m){Write-Host '  [OK] MITM: port 443'}else{Write-Host '  [!] MITM chua len'}"
powershell -NoProfile -Command "$f=Join-Path $env:APPDATA '9router\runtime\mitm\server.js'; $t=Get-Content $f -Raw -EA SilentlyContinue; if($t -match '9ROUTER_SSEGUARD_V8'){Write-Host '  [OK] Patch V8: da ap'}else{Write-Host '  [!] Patch V8 CHUA ap'}; if($t -match '9ROUTER_PROCGUARD_V6'){Write-Host '  [OK] Chong crash MITM: da ap'}else{Write-Host '  [!] Chua co guard'}; if($t -match '9ROUTER_DNSFIX_V5'){Write-Host '  [OK] Fix DNS: da ap'}"
echo -----------------------------------------
echo.
echo   XONG! Mo Antigravity va chat thu.
echo   Neu con loi: xem %APPDATA%\9router\mitm-crash.log
echo.
pause
