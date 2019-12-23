#!/bin/sh
# This script packages already built GRASS GIS as a standalone ZIP file that
# can be extracted to C:\OSGeo4W64.

set -e
. ${GRASSBUILDRC-~/.grassbuildrc}
cd $GRASS_SRC

OSGEO4W_ROOT_MSYS=$OSGEO4W64
OSGEO4W_ROOT=`echo $OSGEO4W_ROOT_MSYS | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
OPT_PATH=$OSGEO4W_MSYS_ROOT/opt
GRASS_PATH=$OPT_PATH/grass
VERSION=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
ARCH=x86_64-w64-mingw32
DATE=`date +%Y%m%d`
GRASS_ZIP=~/usr/grass/grass$VERSION-$ARCH-osgeo4w64-$DATE.zip

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

OSGEO4W_ROOT_ESCAPED=`echo $OSGEO4W_ROOT | sed 's/\\\\/\\\\\\\\/g'`
(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e 's/@POSTFIX@/'$VERSION'/g' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $GRASS_PATH/grass$VERSION.bat
unix2dos $GRASS_PATH/grass$VERSION.bat

cd $OSGEO4W_MSYS_ROOT/..
OSGEO4W_BASENAME=`basename $OSGEO4W_MSYS_ROOT`
rm -f ~/usr/grass/grass*-$ARCH-osgeo4w64-*.zip
zip -r $GRASS_ZIP $OSGEO4W_BASENAME -x "$OSGEO4W_BASENAME/var/*" "*/__pycache__/*"
