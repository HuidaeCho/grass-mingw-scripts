@echo off
setlocal EnableDelayedExpansion

set GISBASE=%~dp0
set GISBASE=%GISBASE:~0,-1%

set GRASS_PROJSHARE=%GISBASE%\share\proj

set PROJ_LIB=%GISBASE%\share\proj
set GDAL_DATA=%GISBASE%\share\gdal

rem XXX: Do we need these variables?
rem set GEOTIFF_CSV=%GISBASE%\share\epsg_csv
rem set FONTCONFIG_FILE=%GISBASE%\etc\fonts.conf

if defined GRASS_PYTHON (
	if not exist "%GRASS_PYTHON%" (
		echo.
		echo %GRASS_PYTHON% not found
		echo Please fix GRASS_PYTHON
		echo.
		pause
		goto :eof
	)
) else (
	rem Change this variable to override auto-detection of python.exe in
	rem PATH
	set GRASS_PYTHON=C:\Python39\python.exe

	rem For portable installation, use %~d0 for the changing drive letter
	rem set GRASS_PYTHON=%~d0\Python39\python.exe

	if not exist "%GRASS_PYTHON%" (
		set GRASS_PYTHON=
		for /f usebackq %%i in (`where python.exe`) do if "!GRASS_PYTHON!" == "" set GRASS_PYTHON=%%i
	)
	if not defined GRASS_PYTHON (
		echo.
		echo python.exe not found in PATH
		echo Please set GRASS_PYTHON
		echo.
		pause
		goto :eof
	)
)
rem XXX: Do we need PYTHONHOME?
rem for %%i in (%GRASS_PYTHON%) do set PYTHONHOME=%%~dpi

rem If GRASS_SH is externally defined, that shell will be used; Otherwise,
rem GISBASE\etc\sh.bat will be used if it exists; If not, cmd.exe will be used;
rem This check is mainly for supporting BusyBox for Windows (busybox64.exe)
rem (https://frippery.org/busybox/)
if not defined GRASS_SH (
	set GRASS_SH=%GISBASE%\etc\sh.bat
	if not exist "!GRASS_SH!" set GRASS_SH=
)

rem With busybox64.exe and Firefox as the default browser, g.manual fails with
rem "Your Firefox profile cannot be loaded. It may be missing or inaccessible";
rem I tried to set GRASS_HTML_BROWSER to the full path of chrome.exe, but it
rem didn't work; Setting BROWSER to its full path according to the webbrowser
rem manual worked
if "%GRASS_SH%" == "%GISBASE%\etc\sh.bat" if not defined BROWSER (
	for %%i in ("%ProgramFiles%" "%ProgramFiles(x86)%") do (
		if not defined BROWSER (
			set BROWSER=%%i
			set BROWSER=!BROWSER:"=!
			if exist "!BROWSER!\Google\Chrome\Application\chrome.exe" (
				set BROWSER=!BROWSER!\Google\Chrome\Application\chrome.exe
			) else (
				set BROWSER=
			)
		)
	)
)

if not exist "%GISBASE%\etc\fontcap" (
	pushd .
	%~d0
	cd %GISBASE%\lib
	set GISRC=dummy
	"%GISBASE%\bin\g.mkfontcap.exe"
	popd
)

"%GRASS_PYTHON%" "%GISBASE%\etc\grass80.py" %*
if %ERRORLEVEL% geq 1 pause
