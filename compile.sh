#!/bin/sh
# This script recreates batch files for supporting BusyBox for Windows
# (busybox64.exe).

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

opt_path=$OSGEO4W_ROOT/opt/grass
grass_path=$opt_path/grass
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`

(
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    mswindows/osgeo4w/env.bat.tmpl
cat<<EOT

set PYTHONHOME=%OSGEO4W_ROOT%\\apps\\Python37
set PATH=%OSGEO4W_ROOT%\\apps\\msys\\bin;%OSGEO4W_ROOT%\\apps\\Python37;%OSGEO4W_ROOT%\\apps\\Python37\\Scripts;%PATH%

rem If GRASS_SH is externally defined, that shell will be used; Otherwise,
rem GISBASE\etc\sh.bat will be used if it exists; If not, cmd.exe will be used;
rem This check is mainly for supporting BusyBox for Windows (busybox64.exe)
rem (https://frippery.org/busybox/)
setlocal EnableDelayedExpansion
if not defined GRASS_SH (
	set GRASS_SH=%GISBASE%\\etc\\sh.bat
	if not exist "!GRASS_SH!" set GRASS_SH=
)
endlocal & set GRASS_SH=%GRASS_SH%

rem With busybox64.exe and Firefox as the default browser, g.manual fails with
rem "Your Firefox profile cannot be loaded. It may be missing or inaccessible";
rem I tried to set GRASS_HTML_BROWSER to the full path of chrome.exe, but it
rem didn't work; Setting BROWSER to its full path according to the webbrowser
rem manual worked
setlocal EnableDelayedExpansion
if "%GRASS_SH%" == "%GISBASE%\\etc\\sh.bat" if not defined BROWSER (
	for %%i in ("%ProgramFiles%" "%ProgramFiles(x86)%") do (
		if not defined BROWSER (
			set BROWSER=%%i
			set BROWSER=!BROWSER:"=!
			if exist "!BROWSER!\\Google\\Chrome\\Application\\chrome.exe" (
				set BROWSER=!BROWSER!\\Google\\Chrome\\Application\\chrome.exe
			) else (
				set BROWSER=
			)
		)
	)
)
endlocal & set BROWSER=%BROWSER%

if not exist %GISBASE%\\etc\\fontcap (
	pushd .
	%~d0
	cd %GISBASE%\\lib
	set GISRC=dummy
	%GISBASE%\\bin\\g.mkfontcap.exe
	popd
)
EOT
) | unix2dos > $grass_path/etc/env.bat

sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e "s/@POSTFIX@/$version/g" \
    mswindows/osgeo4w/grass.bat.tmpl | unix2dos > $grass_path/grass.bat
