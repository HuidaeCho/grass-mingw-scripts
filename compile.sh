#!/bin/sh
#
# Standalone script for building a portable package of GRASS GIS for OSGeo4W
#
# Written by Huidae Cho
#
# Basic steps:
#
# mkdir -p ~/usr/src
# cd ~/usr/src
# git clone https://github.com/OSGeo/grass.git
# cd grass
# compile.sh --grass-source=/usr/local/src/grass --osgeo4w-path=/d/OSGeo4W64 \
#	--update --package > compile.log 2>&1
#

# stop on errors
set -e

# default paths, but can be overriden from the command line
osgeo4w_path=${OSGEO4W_PATH-/c/OSGeo4W64}
addons_path=${ADDONS_PATH-../grass-addons}

# process options
update=0
package=0
for opt; do
	case "$opt" in
	-h|--help)
		cat<<'EOT'
Usage: compile.sh [OPTIONS]

-h, --help               display this help message
    --osgeo4w-path=PATH  OSGeo4W path (default: /c/OSGeo4W64)
    --addons-path=PATH   grass-addons path (default: ../grass-addons)
    --update             update the current branch
    --package            package the compiled build as
                         grass79-${ARCH}-osgeo4w${BIT}-YYYYMMDD.zip
EOT
		exit
		;;
	--osgeo4w-path=*)
		osgeo4w_path=`echo $opt | sed 's/^[^=]*=//'`
		;;
	--addons-path=*)
		addons_path=`echo $opt | sed 's/^[^=]*=//'`
		;;
	--update)
		update=1
		;;
	--package)
		package=1
		;;
	*)
		echo "$opt: unknown option"
		exit 1
		;;
	esac
done

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# check path
if [ ! -d $osgeo4w_path ]; then
	echo "$osgeo4w_path: not found"
	exit 1
fi
osgeo4w_root_msys=$osgeo4w_path

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	arch=x86_64-w64-mingw32
	bit=64
	;;
i686)
	arch=i686-w64-mingw32
	bit=32
	;;
*)
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

if [ $update -eq 1 -a ! -d .git ]; then
	echo "not a git repository"
	exit 1
fi

# start
echo "Started compilation: `date`"
echo

# update the current branch if requested
if [ $update -eq 1 -a -d .git ]; then
	git pull
fi

# compile

grass_src=`pwd`
tmp=`dirname $0`; grass_build_scripts=`realpath $tmp`

export MINGW_CHOST=$arch
export PATH="/mingw$bit/bin:$PATH"

OSGEO4W_ROOT_MSYS=$osgeo4w_root_msys \
./configure \
--host=$MINGW_CHOST \
--with-includes=$osgeo4w_root_msys/include \
--with-libs="$osgeo4w_root_msys/lib $osgeo4w_root_msys/bin" \
--with-nls \
--with-freetype-includes=$osgeo4w_root_msys/include/freetype2 \
--with-bzlib \
--with-geos=$grass_src/mswindows/osgeo4w/geos-config \
--with-netcdf=$grass_build_scripts/nc-config \
--with-gdal=$grass_src/mswindows/osgeo4w/gdal-config \
--with-liblas=$grass_src/mswindows/osgeo4w/liblas-config \
--with-opengl=windows \
>> /dev/stdout

make clean default

if [ -d $addons_path ]; then
	MODULE_TOPDIR=`pwd`
	(
	cd $addons_path
	if [ $update -eq 1 -a -d .git ]; then
		git pull
	fi
	cd src
	make MODULE_TOPDIR=$MODULE_TOPDIR clean default
	)
fi

# package

opt_path=$osgeo4w_root_msys/opt
grass_path=$opt_path/grass
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
date=`date +%Y%m%d`
grass_zip=$grass_src/grass$version-$arch-osgeo4w$bit-$date.zip

# copy MinGW libraries
test -d $grass_path && rm -rf $grass_path
test -d $opt_path || mkdir -p $opt_path
cp -a dist.$arch $grass_path
rm -f $grass_path/grass.tmp $grass_path/etc/fontcap
cp -a bin.$arch/grass.py $grass_path/etc/grass$version.py
cp -a `ldd dist.$arch/lib/*.dll | awk '/mingw'$bit'/{print $3}' |
	sort -u | grep -v 'lib\(crypto\|ssl\)'` $grass_path/lib

# create batch files
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
EOT
) > $grass_path/etc/env.bat
unix2dos $grass_path/etc/env.bat

(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e "s/@POSTFIX@/$version/g" \
    mswindows/osgeo4w/grass.bat.tmpl
) > $grass_path/grass.bat
unix2dos $grass_path/grass.bat

# package if requested
if [ $package -eq 1 ]; then
	rm -f grass*-$arch-osgeo4w$bit-*.zip
	cd $osgeo4w_root_msys/..
	osgeo4w_basename=`basename $osgeo4w_root_msys`
	zip -r $grass_zip $osgeo4w_basename -x "$osgeo4w_basename/var/*" "*/__pycache__/*"
fi

echo
echo "Completed compilation: `date`"
