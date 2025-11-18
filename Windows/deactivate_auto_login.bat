@echo off
setlocal

rem Require admin rights
net session >nul 2>&1 || (
    exit /b 1
)

set "REG_PATH=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

reg add "%REG_PATH%" /v AutoAdminLogon /t REG_SZ /d 0 /f >nul 2>&1 || (
    exit /b 1
)

endlocal
exit /b 0
