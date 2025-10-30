@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Ptolemy II - Build Fat JAR Script (fixed for long manifest)
REM ============================================================

REM === Configuration ===
set PROJECT_DIR=D:\dev\projects\ptII-win-installer
set OUTPUT_DIR=%PROJECT_DIR%\output
set LIB_DIR=%PROJECT_DIR%\lib
set JAR_NAME=ptII-fat.jar
set MAIN_CLASS=ptolemy.vergil.VergilApplication
set MANIFEST_FILE=%PROJECT_DIR%\manifest.mf

echo --------------------------------------------
echo Building fat JAR for %MAIN_CLASS%
echo Project directory: %PROJECT_DIR%
echo --------------------------------------------

REM === 1. Create manifest.mf with proper line wrapping ===
echo Creating manifest file...

(
  echo Main-Class: %MAIN_CLASS%
  setlocal enabledelayedexpansion
  set LINE=Class-Path: .

  REM --- Add all JARs from lib folder ---
  for /r "%LIB_DIR%" %%f in (*.jar) do (
    set JARPATH=lib/%%~nxf
    call :ADD_TO_MANIFEST_LINE "!JARPATH!"
  )

  REM --- Add all JARs from ptolemy subfolders ---
  for /r "%PROJECT_DIR%\ptolemy" %%f in (*.jar) do (
    set RELPATH=%%f
    set RELPATH=!RELPATH:%PROJECT_DIR%\=!
    set RELPATH=!RELPATH:\=/!
    call :ADD_TO_MANIFEST_LINE "!RELPATH!"
  )

  REM --- Write final buffered line ---
  echo !LINE!
  echo(
  endlocal
) > "%MANIFEST_FILE%"

echo ✅ Manifest created at %MANIFEST_FILE%

REM === 2. Create the fat jar ===
cd /d "%PROJECT_DIR%"
if exist "%JAR_NAME%" del "%JAR_NAME%"

echo Creating %JAR_NAME% ...
jar cfm "%JAR_NAME%" "%MANIFEST_FILE%" -C "%OUTPUT_DIR%" .

if %errorlevel% neq 0 (
  echo ❌ JAR creation failed!
  exit /b 1
)

echo ✅ JAR created successfully: %PROJECT_DIR%\%JAR_NAME%

REM === 3. Optionally copy dependencies (keeps existing lib) ===
echo Copying dependencies to ensure they are next to the jar...
xcopy "%LIB_DIR%\*.jar" "%PROJECT_DIR%\lib\" /Y >nul

for /r "%PROJECT_DIR%\ptolemy" %%f in (*.jar) do (
  set RELPATH=%%f
  set TARGET=%PROJECT_DIR%\lib\%%~nxf
  if not exist "%TARGET%" copy /Y "%%f" "%TARGET%" >nul
)

echo ✅ All dependencies are available in %PROJECT_DIR%\lib

REM === 4. Final info ===
echo --------------------------------------------
echo To run:
echo     cd /d "%PROJECT_DIR%"
echo     java -jar %JAR_NAME%
echo --------------------------------------------
goto :EOF


REM ============================================================
REM  Helper function: wrap Class-Path lines at 72 characters
REM ============================================================
:ADD_TO_MANIFEST_LINE
set "ITEM=%~1"
set "TMP=!LINE! %ITEM%"
if not "!TMP:~72,1!"=="" (
  REM line too long — flush current and start continuation line
  echo !LINE!
  set "LINE= %ITEM%"
) else (
  set "LINE=!TMP!"
)
exit /b
