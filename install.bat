@echo off
REM Install Google Android skills to %USERPROFILE%\.claude\skills\
REM Supports: Windows (cmd)
REM Usage:
REM   install.bat          Interactive mode - choose skills to install
REM   install.bat --all    Install all skills without prompting

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "SKILLS_DIR=%USERPROFILE%\.claude\skills"

REM --- Skill registry ---
set "TOTAL=6"

set "SKILL_PATH[1]=build\agp\agp-9-upgrade"
set "SKILL_NAME[1]=agp-9-upgrade"
set "SKILL_DESC[1]=Upgrade Android Gradle Plugin to version 9"

set "SKILL_PATH[2]=jetpack-compose\migration\migrate-xml-views-to-jetpack-compose"
set "SKILL_NAME[2]=migrate-xml-views-to-jetpack-compose"
set "SKILL_DESC[2]=Migrate XML views to Jetpack Compose"

set "SKILL_PATH[3]=navigation\navigation-3"
set "SKILL_NAME[3]=navigation-3"
set "SKILL_DESC[3]=Migrate to Navigation 3"

set "SKILL_PATH[4]=performance\r8-analyzer"
set "SKILL_NAME[4]=r8-analyzer"
set "SKILL_DESC[4]=Analyze R8/ProGuard rules for optimization"

set "SKILL_PATH[5]=play\play-billing-library-version-upgrade"
set "SKILL_NAME[5]=play-billing-library-version-upgrade"
set "SKILL_DESC[5]=Upgrade Play Billing Library version"

set "SKILL_PATH[6]=system\edge-to-edge"
set "SKILL_NAME[6]=edge-to-edge"
set "SKILL_DESC[6]=Migrate to edge-to-edge display"

if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"

REM --- Check --all flag ---
if "%~1"=="--all" goto :install_all

REM --- Interactive mode ---
echo.
echo Google Android Skills Installer
echo ================================
echo.
echo Available skills:
echo.

for /L %%i in (1,1,%TOTAL%) do (
    set "status= "
    if exist "%SKILLS_DIR%\!SKILL_NAME[%%i]!" set "status=*"
    echo   [!status!] %%i^) !SKILL_NAME[%%i]! - !SKILL_DESC[%%i]!
)

echo.
echo   [*] = already installed
echo.
echo Options:
echo   Enter numbers separated by spaces (e.g. 1 3 5)
echo   a = install all
echo   q = quit
echo.
set /p "choice=Your choice: "

if /i "!choice!"=="q" (
    echo Cancelled.
    goto :eof
)

if /i "!choice!"=="a" goto :install_all

REM --- Parse selection ---
set "installed=0"
set "selected=0"
echo.

for %%n in (!choice!) do (
    set "num=%%n"
    if !num! GEQ 1 if !num! LEQ %TOTAL% (
        set /a selected+=1
        call :install_skill_by_index !num!
    ) else (
        echo   [ERROR] Invalid number: %%n (must be 1-%TOTAL%)
    )
)

if !selected!==0 (
    echo No valid skills selected. Please run the script again.
    goto :eof
)

echo.
echo Done! Installed: %installed%/%selected%
echo Skills location: %SKILLS_DIR%
goto :eof

REM --- Install all ---
:install_all
echo.
echo Installing all Google Android skills to %SKILLS_DIR%...
echo.
set "installed=0"
for /L %%i in (1,1,%TOTAL%) do (
    call :install_skill_by_index %%i
)
echo.
echo Done! Installed: %installed%/%TOTAL%
echo Skills location: %SKILLS_DIR%
goto :eof

REM --- Install single skill by index ---
:install_skill_by_index
set "idx=%~1"
set "src_path=!SKILL_PATH[%idx%]!"
set "skill_name=!SKILL_NAME[%idx%]!"
set "src_full=%SCRIPT_DIR%!src_path!"
set "dest=%SKILLS_DIR%\!skill_name!"

if not exist "!src_full!\SKILL.md" (
    echo   [SKIP] !skill_name! - SKILL.md not found
    goto :eof
)

if exist "!dest!" rmdir /s /q "!dest!"

xcopy "!src_full!" "!dest!\" /e /i /q >nul 2>&1

echo   [OK] !skill_name!
set /a installed+=1
goto :eof
