REM
REM Environmental variables for GRASS OSGeo4W installer
REM

set GISBASE=%OSGEO4W_ROOT%\opt\grass

REM Uncomment if you want to use Bash instead of Cmd
REM Note that msys package must be also installed
REM set GRASS_SH=%OSGEO4W_ROOT%\apps\msys\bin\sh.exe

set GRASS_PYTHON=%OSGEO4W_ROOT%\bin\python3.exe
set GRASS_PROJSHARE=%OSGEO4W_ROOT%\share\proj

set FONTCONFIG_FILE=%GISBASE%\etc\fonts.conf

REM
REM RStudio-related
REM
REM set RStudio temporarily to %PATH% if it exists
IF EXIST "%ProgramFiles%\RStudio\bin\rstudio.exe" set PATH=%PATH%;%ProgramFiles%\RStudio\bin
REM set R_USER if %USERPROFILE%\Documents\R\ exists to catch most common cases of private R libraries
IF EXIST "%USERPROFILE%\Documents\R\" set R_USER=%USERPROFILE%\Documents\

set PYTHONHOME=%OSGEO4W_ROOT%\apps\Python312
set PATH=%OSGEO4W_ROOT%\apps\msys\bin;%OSGEO4W_ROOT%\apps\Python312;%OSGEO4W_ROOT%\apps\Python312\Scripts;%PATH%

rem If GRASS_SH is externally defined, that shell will be used; Otherwise,
rem GISBASE\etc\sh.bat will be used if it exists; If not, cmd.exe will be used;
rem This check is mainly for supporting BusyBox for Windows (busybox64.exe)
rem (https://frippery.org/busybox/)
setlocal EnableDelayedExpansion
if not defined GRASS_SH (
	set GRASS_SH=%GISBASE%\etc\sh.bat
	if not exist "!GRASS_SH!" set GRASS_SH=
)
endlocal & set GRASS_SH=%GRASS_SH%

rem With busybox64.exe and Firefox as the default browser, g.manual fails with
rem "Your Firefox profile cannot be loaded. It may be missing or inaccessible";
rem I tried to set GRASS_HTML_BROWSER to the full path of chrome.exe, but it
rem didn't work; Setting BROWSER to its full path according to the webbrowser
rem manual worked
setlocal EnableDelayedExpansion
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
endlocal & set BROWSER=%BROWSER%

if not exist %GISBASE%\etc\fontcap (
	pushd .
	%~d0
	cd %GISBASE%\lib
	set GISRC=dummy
	%GISBASE%\bin\g.mkfontcap.exe
	popd
)
