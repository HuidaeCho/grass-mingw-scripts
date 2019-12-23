#!/bin/sh
# This script creates batch files for starting up GRASS GIS from the source
# directory.

set -e
. ${GRASSBUILDRC-~/.grassbuildrc}
cd $GRASS_SRC

OSGEO4W_ROOT_MSYS=$OSGEO4W64
OSGEO4W_ROOT=`echo $OSGEO4W_ROOT_MSYS | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
MSYS2_ROOT=`echo $WD | sed 's#\\\\usr.*##'`
MINGW_ROOT=`echo "$MSYS2_ROOT$MINGW_PREFIX" | sed 's#/#\\\\#g'`

test -e $BATCH_DIR || mkdir $BATCH_DIR

(
sed -e 's/^\(set GISBASE=\).*/\1%HOME%\\usr\\grass\\grass\\dist.'$MINGW_CHOST'/' \
    mswindows/osgeo4w/env.bat.tmpl
echo
echo "set PATH=$MINGW_ROOT\\bin;%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%"
) > $BATCH_DIR/env.bat
unix2dos $BATCH_DIR/env.bat

OSGEO4W_ROOT_ESCAPED=`echo $OSGEO4W_ROOT | sed 's/\\\\/\\\\\\\\/g'`
MSYS2_ROOT_ESCAPED=`echo $MSYS2_ROOT | sed 's/\\\\/\\\\\\\\/g'`
if echo $HOME | grep -q '^/[a-z]\($\|/\)'; then
	HOME_ESCAPED=`echo $HOME | sed 's#^/\(.\)#\1:/#'`
else
	HOME_ESCAPED="$MSYS2_ROOT_ESCAPED/$HOME"
fi
HOME_ESCAPED=`echo $HOME_ESCAPED | sed 's#//*#\\\\\\\\#g'`
VERSION=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
(
sed -e 's/^\(call "\)%~dp0\(.*\)$/\1'$OSGEO4W_ROOT_ESCAPED'\\bin\2\nSET HOME='$HOME_ESCAPED'/' \
    -e 's/^call "%OSGEO4W_ROOT%.*\\env\.bat"$/call "%HOME%\\usr\\grass\\bin\\env.bat"/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\?\(".*\)/\1%HOME%\\usr\\grass\\grass\\bin.'$MINGW_CHOST'\\grass'$VERSION'.py\2/' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $BATCH_DIR/grass$VERSION.bat
unix2dos $BATCH_DIR/grass$VERSION.bat
