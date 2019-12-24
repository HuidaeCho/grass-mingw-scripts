#!/bin/sh
# This script creates batch files for starting up GRASS GIS from the source
# directory.

set -e
. ${GRASSBUILDRC-~/.grassbuildrc}
cd $GRASS_SRC

case $SYSTEM_BIT in
64)
	ARCH=x86_64-w64-mingw32
	;;
32)
	ARCH=i686-w64-mingw32
	;;
*)
	echo "$SYSTEM_BIT: unknown system bit"
	exit 1
esac

OSGEO4W_ROOT_MSYS=$OSGEO4W
OSGEO4W_ROOT=`echo $OSGEO4W_ROOT_MSYS | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
MSYS2_ROOT=`echo $WD | sed 's#\\\\usr.*##'`
MINGW_ROOT=`echo "$MSYS2_ROOT$MINGW_PREFIX" | tr / '\\\\'`

GRASS_BIN="$GRASS_SRC/bin.$ARCH"
GRASS_DIST="$GRASS_SRC/dist.$ARCH"

GRASS_SRC_WIN=`pwd -W | tr / '\\\\'`
GRASS_BIN_WIN="$GRASS_SRC_WIN\\bin.$ARCH"
GRASS_DIST_WIN="$GRASS_SRC_WIN\\dist.$ARCH"

sed -e 's/^\(set GISBASE=\).*/\1'$GRASS_DIST_WIN'/' \
    mswindows/osgeo4w/env.bat.tmpl
echo
echo "set PATH=$MINGW_ROOT\\bin;%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%"
) > $GRASS_DIST/etc/env.bat
unix2dos $GRASS_DIST/etc/env.bat

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
    -e 's/^call "%OSGEO4W_ROOT%.*\\env\.bat"$/call "'$GRASS_DIST_WIN'\\etc\\env.bat"/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\?\(".*\)/\1'$GRASS_BIN_WIN'\\grass'$VERSION'.py\2/' \
    mswindows/osgeo4w/grass.bat.tmpl
) > $GRASS_BIN/grass$VERSION.bat
unix2dos $GRASS_BIN/grass$VERSION.bat
