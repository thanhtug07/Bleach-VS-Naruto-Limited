@echo off
title BVN - Tat netplay server
set PIDFILE=%~dp0netplay-server\server.pid
if exist "%PIDFILE%" (
  for /f %%p in (%PIDFILE%) do (
    echo Tat server pid %%p ...
    taskkill /PID %%p /F >nul 2>&1
  )
  del "%PIDFILE%" 2>nul
  echo Xong.
) else (
  echo Khong thay server cua game dang chay.
)
pause
