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
# compile.sh --pull --package > compile.log 2>&1
#

# stop on errors
set -e

# default path, but can be overriden from the command line
OSGEO4W64=${OSGEO4W64-/c/osgeo4w64}

# process options
PULL=0
PACKAGE=0
for opt; do
	case $opt in
	-h|--help)
		cat<<'EOT'
Usage: compile.sh [OPTIONS]

-h, --help       display this help message
    --osgeo4w64  OSGeo4W64 path (default: /c/osgeo4w64)
    --pull       update the current branch
    --package    package the compiled build as
                 grass79-x86_64-w64-mingw32-osgeo4w64-YYYYMMDD.zip
EOT
		exit
		;;
	--osgeo4w64=*)
		OSGEO4W64=`echo $opt | sed 's/^[^=]*=//'`
		;;
	--pull)
		PULL=1
		;;
	--package)
		PACKAGE=1
		;;
	*)
		echo "$opt: unknown option"
		exit 1
		;;
	esac
done

# see if we're inside the root of the GRASS source code
if [ ! -e grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# check path
if [ ! -e $OSGEO4W64 ]; then
	echo "$OSGEO4W64: not found"
	exit 1
fi
OSGEO4W_MSYS_ROOT=$OSGEO4W64

# update the current branch if requested
if [ $PULL -eq 1 ]; then
	if [ ! -e .git ]; then
		echo "not a git repository"
		exit 1
	fi
	git pull
fi

# compile

GRASS_SOURCE=`pwd`
tmp=`dirname $0`
GRASS_MINGW_SCRIPTS=`realpath $tmp`

sed -e 's/-lproj/-lproj_6_2/g' configure > myconfigure
OSGEO4W_MSYS_ROOT=$OSGEO4W_MSYS_ROOT \
./myconfigure \
--host=$MINGW_CHOST \
--with-nls \
--with-includes=$OSGEO4W_MSYS_ROOT/include \
--with-libs="$OSGEO4W_MSYS_ROOT/lib $OSGEO4W_MSYS_ROOT/bin" \
--with-gdal=$GRASS_SOURCE/mswindows/osgeo4w/gdal-config \
--with-opengl=windows \
--with-freetype-includes=$OSGEO4W_MSYS_ROOT/include/freetype2 \
--with-geos=$GRASS_SOURCE/mswindows/osgeo4w/geos-config \
--with-netcdf=$GRASS_MINGW_SCRIPTS/nc-config \
--with-liblas=$GRASS_SOURCE/mswindows/osgeo4w/liblas-config \
--with-bzlib \
>> /dev/stdout

make clean default

# package

OPT_PATH=$OSGEO4W_MSYS_ROOT/opt
GRASS_PATH=$OPT_PATH/grass
VERSION=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
ARCH=x86_64-w64-mingw32
DATE=`date +%Y%m%d`
GRASS_ZIP=$GRASS_SOURCE/grass$VERSION-$ARCH-osgeo4w64-$DATE.zip

test -e $GRASS_PATH && rm -rf $GRASS_PATH
test -e $OPT_PATH || mkdir -p $OPT_PATH
cp -a dist.$ARCH $GRASS_PATH
rm -f $GRASS_PATH/grass$VERSION.tmp $GRASS_PATH/etc/fontcap
cp -a bin.$ARCH/grass$VERSION.py $GRASS_PATH/etc
cp -a `ldd dist.$ARCH/lib/*.dll | awk '/mingw64/{print $3}' | sort -u | grep -v 'lib\(crypto\|ssl\)'` $GRASS_PATH/lib

(
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    mswindows/osgeo4w/env.bat.tmpl
cat<<EOT

set PATH=%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%

if not exist %GISBASE%\etc\fontcap (
	pushd .
	%~d0
	cd %GISBASE%\lib
	set GISRC=dummy
	%GISBASE%\bin\g.mkfontcap.exe
	popd
)
EOT
) > $GRASS_PATH/etc/env.bat
unix2dos $GRASS_PATH/etc/env.bat

(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e 's/@POSTFIX@/'$VERSION'/g' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $GRASS_PATH/grass$VERSION.bat
unix2dos $GRASS_PATH/grass$VERSION.bat

# package if requested
if [ $PACKAGE -eq 1 ]; then
	rm -f grass*-$ARCH-osgeo4w64-*.zip
	cd $OSGEO4W_MSYS_ROOT/..
	OSGEO4W_BASENAME=`basename $OSGEO4W_MSYS_ROOT`
	zip -r $GRASS_ZIP $OSGEO4W_BASENAME -x "$OSGEO4W_BASENAME/var/*" "*/__pycache__/*"
fi
