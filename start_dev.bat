@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo   Starting ExportSafe AI Development Environment
echo ===================================================

cd exportsafe_backend

:: 1. Check for saved config
if exist python_path.txt (
    set /p PY_PATH=<python_path.txt
    echo Found saved Python path: !PY_PATH!
    goto :found_python
)

:: 2. Try standard commands
where python >nul 2>nul
if %errorlevel%==0 (
    set PY_PATH=python
    echo Python found in PATH.
    goto :save_and_run
)

where py >nul 2>nul
if %errorlevel%==0 (
    set PY_PATH=py
    echo 'py' launcher found.
    goto :save_and_run
)

:: 3. Try common paths
if exist "C:\Python39\python.exe" set PY_PATH="C:\Python39\python.exe" & goto :save_and_run
if exist "C:\Python310\python.exe" set PY_PATH="C:\Python310\python.exe" & goto :save_and_run
if exist "C:\Python311\python.exe" set PY_PATH="C:\Python311\python.exe" & goto :save_and_run
if exist "%LOCALAPPDATA%\Programs\Python\Python39\python.exe" set PY_PATH="%LOCALAPPDATA%\Programs\Python\Python39\python.exe" & goto :save_and_run
if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" set PY_PATH="%LOCALAPPDATA%\Programs\Python\Python310\python.exe" & goto :save_and_run
if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" set PY_PATH="%LOCALAPPDATA%\Programs\Python\Python311\python.exe" & goto :save_and_run
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set PY_PATH="%LOCALAPPDATA%\Programs\Python\Python312\python.exe" & goto :save_and_run

:: 4. Ask User
echo.
echo [ERROR] Could not find Python automatically.
echo.
echo Please find your 'python.exe' (usually in AppData or Program Files).
echo Right-click it, "Copy as path", and paste it here.
echo.
set /p PY_PATH="Enter full path to python.exe: "

:save_and_run
echo !PY_PATH! > python_path.txt
echo Saved configuration to python_path.txt

:found_python
:: Start Backend
echo.
echo [1/2] Launching Python Backend...
start "ExportSafe Backend" cmd /k "!PY_PATH! -m pip install -r requirements.txt && !PY_PATH! -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"

:: Start Frontend
echo Waiting for backend...
timeout /t 5 >nul
echo.
echo [2/2] Launching Flutter App...
cd ..\exportsafe_ai
flutter run -d chrome
