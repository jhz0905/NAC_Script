@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "ZIP_PATH=%SCRIPT_DIR%07715615E31FE759303ADFAE2AEB326B7E353A4E.zip"
set "DEST_PATH=%SCRIPT_DIR:~0,-1%"

if not exist "%ZIP_PATH%" (
    exit /b 1
)

if not exist "%DEST_PATH%" (
    mkdir "%DEST_PATH%" >nul 2>&1 || (
        exit /b 1
    )
)

powershell -NoLogo -NoProfile -Command "Expand-Archive -LiteralPath \"%ZIP_PATH%\" -DestinationPath \"%DEST_PATH%\" -Force" >nul 2>&1

if errorlevel 1 (
    exit /b %errorlevel%
)

set "SCRIPT_PATH=%DEST_PATH%\install_agent.bat"

if not exist "%SCRIPT_PATH%" (
    exit /b 1
)

call "%SCRIPT_PATH%" >nul 2>&1

if errorlevel 1 (
    exit /b %errorlevel%
)

endlocal
exit /b 0
