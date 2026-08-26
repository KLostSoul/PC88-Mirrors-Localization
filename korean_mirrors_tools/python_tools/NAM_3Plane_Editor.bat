@echo off
setlocal

set "SCRIPT=%~dp0nam_3plane_editor.py"

if not exist "%SCRIPT%" (
    echo NAM 3-plane editor script was not found in this folder.
    pause
    exit /b 1
)

pythonw "%SCRIPT%"
if not errorlevel 1 exit /b 0

pyw "%SCRIPT%"
if not errorlevel 1 exit /b 0

echo Python 3 with Pillow is required to run the NAM editor.
pause
exit /b 1
