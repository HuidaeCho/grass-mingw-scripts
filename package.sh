#!/bin/sh
# This script packages already built GRASS GIS as a standalone ZIP file that
# can be extracted to C:\.
#
# To override the default OSGEO4W (/c/OSGeo4W64),
#	OSGEO4W=/d/OSGeo4W64 package.sh

set -e
OSGEO4W_ROOT_MSYS=${OSGEO4W-/c/OSGeo4W64}

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	ARCH=x86_64-w64-mingw32
	BIT=64
	;;
i686)
	ARCH=i686-w64-mingw32
	BIT=32
	;;
*)
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

OSGEO4W_ROOT=`echo $OSGEO4W_ROOT_MSYS | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
OPT_PATH=$OSGEO4W_ROOT_MSYS/opt
GRASS_PATH=$OPT_PATH/grass
VERSION=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
DATE=`date +%Y%m%d`

# copy MinGW libraries
test -d $GRASS_PATH && rm -rf $GRASS_PATH
test -d $OPT_PATH || mkdir -p $OPT_PATH
cp -a dist.$ARCH $GRASS_PATH
rm -f $GRASS_PATH/grass$VERSION.tmp $GRASS_PATH/etc/fontcap
cp -a bin.$ARCH/grass$VERSION.py $GRASS_PATH/etc
cp -a `ldd dist.$ARCH/lib/*.dll | awk '/mingw'$BIT'/{print $3}' |
	sort -u | grep -v 'lib\(crypto\|ssl\)'` $GRASS_PATH/lib

# create batch files
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

OSGEO4W_ROOT_ESCAPED=`echo $OSGEO4W_ROOT | sed 's/\\\\/\\\\\\\\/g'`
(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e 's/@POSTFIX@/'$VERSION'/g' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $GRASS_PATH/grass$VERSION.bat
unix2dos $GRASS_PATH/grass$VERSION.bat

# package
GRASS_SRC=`pwd`
GRASS_ZIP=$GRASS_SRC/grass$VERSION-$ARCH-osgeo4w$BIT-$DATE.zip

cd $OSGEO4W_ROOT_MSYS/..
OSGEO4W_BASENAME=`basename $OSGEO4W_ROOT_MSYS`
rm -f $GRASS_SRC/grass*-$ARCH-osgeo4w$BIT-*.zip
zip -r $GRASS_ZIP $OSGEO4W_BASENAME -x "$OSGEO4W_BASENAME/var/*" "*/__pycache__/*"
