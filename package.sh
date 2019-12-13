#!/bin/sh
# This script packages already built GRASS GIS as a standalone ZIP file that
# can be extracted to C:\OSGeo4W64.

set -e
OSGEO4W_ROOT='C:\OSGeo4W64'
OSGEO4W_MSYS_ROOT='/c/OSGeo4W64'
OPT_PATH=$OSGEO4W_MSYS_ROOT/opt
GRASS_PATH=$OPT_PATH/grass
GRASS_VERSION=`sed -n '/^INST_DIR/{s/^INST_DIR.*grass//; p}' include/Make/Platform.make`
GRASS_ZIP=~/usr/grass/grass$GRASS_VERSION.zip

test -e $GRASS_PATH && rm -rf $GRASS_PATH
test -e $OPT_PATH || mkdir -p $OPT_PATH
cp -a dist.x86_64-w64-mingw32 $GRASS_PATH
rm -f $GRASS_PATH/grass$GRASS_VERSION.tmp
cp -a bin.x86_64-w64-mingw32/grass$GRASS_VERSION.py $GRASS_PATH/etc
cp -a `ldd dist.x86_64-w64-mingw32/lib/*.dll | awk '/mingw64/{print $3}' | sort -u | grep -v 'lib\(crypto\|ssl\)'` $GRASS_PATH/lib

(
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    mswindows/osgeo4w/env.bat.tmpl
echo
echo "set PATH=%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%"
) > $GRASS_PATH/etc/env.bat

OSGEO4W_ROOT_ESCAPED=`echo $OSGEO4W_ROOT | sed 's/\\\\/\\\\\\\\/g'`
(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\.bat"\)$/\1opt\\grass\2/' \
    -e 's/@POSTFIX@/'$GRASS_VERSION'/g' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $GRASS_PATH/grass$GRASS_VERSION.bat

cd $OSGEO4W_MSYS_ROOT/..
OSGEO4W_BASENAME=`basename $OSGEO4W_MSYS_ROOT`
test -e $GRASS_ZIP && rm -f $GRASS_ZIP
zip -r $GRASS_ZIP $OSGEO4W_BASENAME -x "$OSGEO4W_BASENAME/var/*"
