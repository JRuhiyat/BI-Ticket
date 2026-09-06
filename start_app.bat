@echo off
title BI Ticket System - Offline Mode
echo ========================================
echo  Starting BI Ticket System (Offline Mode)
echo ========================================
echo.

:: Map directory to drive letter (handles UNC and WSL paths like \\wsl.localhost\...)
pushd "%~dp0"
set "APP_DIR=%CD%"

:: Initialize bundled Ruby environment using mapped drive path
if exist "%APP_DIR%\vendor\ruby\bin\setrbvars.cmd" (
    echo Using bundled portable Ruby runtime...
    call "%APP_DIR%\vendor\ruby\bin\setrbvars.cmd" >nul
) else if exist "%APP_DIR%\vendor\ruby\bin\ruby.exe" (
    echo Using bundled portable Ruby runtime...
    set "PATH=%APP_DIR%\vendor\ruby\bin;%APP_DIR%\vendor\ruby\bin\ruby_builtin_dlls;%PATH%"
) else (
    where ruby >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Ruby runtime not found!
        echo Please ensure vendor\ruby is present in the project directory or Ruby is installed.
        echo.
        pause
        popd
        exit /b 1
    )
)

:: Set local bundle path if vendor\bundle exists
if exist "%APP_DIR%\vendor\bundle" (
    set "BUNDLE_PATH=%APP_DIR%\vendor\bundle"
)

:: Check if gems are installed for bundled Ruby; auto-install precompiled binaries if missing
call bundle exec rails -v >nul 2>&1
if errorlevel 1 (
    echo.
    echo First-time setup: Installing precompiled gems for Windows...
    call bundle config set --local without 'development test'
    call bundle install
    if errorlevel 1 (
        echo [ERROR] Failed to install gems. Please check internet connection for initial setup.
        pause
        popd
        exit /b 1
    )
)

:: Initialize database if not present
if not exist "%APP_DIR%\db\development.sqlite3" (
    echo.
    echo First-time setup: Preparing local database...
    call bundle exec rails db:prepare
)

echo.
echo Opening BI Ticket System in your default browser...
start http://localhost:3000

echo.
echo BI Ticket System is running at http://localhost:3000
echo Keep this window open while using the dashboard.
echo.
call bundle exec rails server -b 127.0.0.1 -p 3000

popd
