@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
python "%SCRIPT_DIR%generate_korean_composite_16x16.py" --bank0-test
if errorlevel 1 (
    echo.
    echo Physical bank 0 composite test build failed.
) else (
    echo.
    echo Physical bank 0 composite test build was created.
)
pause
