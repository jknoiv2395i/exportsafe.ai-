@echo off
echo Starting ExportSafe AI Backend...

cd exportsafe_backend

:: Try to find python
where python >nul 2>nul
if %errorlevel%==0 (
    echo Python found in PATH.
    python -m pip install -r requirements.txt
    python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    goto :eof
)

where py >nul 2>nul
if %errorlevel%==0 (
    echo 'py' launcher found.
    py -m pip install -r requirements.txt
    py -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    goto :eof
)

echo.
echo ERROR: Python not found in PATH!
echo Please install Python from https://www.python.org/downloads/
echo Make sure to check "Add Python to PATH" during installation.
echo.
pause
