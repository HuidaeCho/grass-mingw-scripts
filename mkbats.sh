#!/bin/sh
if [ -d /c/osgeo4w64 ]; then
	OSGEO4W_ROOT='C:\OSGeo4W64'
elif [ -d /c/osgeo4w ]; then
	OSGEO4W_ROOT='C:\OSGeo4W'
fi
MSYS2_ROOT=`echo $WD | sed 's#\\\\usr.*##'`
MINGW_ROOT=`echo "$MSYS2_ROOT$MINGW_PREFIX" | sed 's#/#\\\\#g'`

test -e ~/usr/grass/bin || mkdir ~/usr/grass/bin

(
sed -e 's/^\(set GISBASE=\).*/\1%HOME%\\usr\\grass\\grass\\dist.'$MINGW_CHOST'/' \
    mswindows/osgeo4w/env.bat.tmpl
echo
echo "set PATH=$MINGW_ROOT\\bin;%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%"
) > ~/usr/grass/bin/env.bat

OSGEO4W_ROOT_ESCAPED=`echo $OSGEO4W_ROOT | sed 's/\\\\/\\\\\\\\/g'`
MSYS2_ROOT_ESCAPED=`echo $MSYS2_ROOT | sed 's/\\\\/\\\\\\\\/g'`
if echo $HOME | grep '^/[a-z]\($\|/\)' > /dev/null; then
	HOME_ESCAPED=`echo $HOME | sed 's#^/\(.\)#\1:/#'`
else
	HOME_ESCAPED="$MSYS2_ROOT_ESCAPED/$HOME"
fi
HOME_ESCAPED=`echo $HOME_ESCAPED | sed 's#//*#\\\\\\\\#g'`
(
sed -e 's/^\(call "\)%~dp0\(.*\)$/\1'$OSGEO4W_ROOT_ESCAPED'\\bin\2\nSET HOME='$HOME_ESCAPED'/' \
    -e 's/^call "%OSGEO4W_ROOT%.*\\env\.bat"$/call "%HOME%\\usr\\grass\\bin\\env.bat"/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\?\(".*\)/\1%HOME%\\usr\\grass\\grass\\bin.'$MINGW_CHOST'\\grass79.py\2/' \
    mswindows/osgeo4w/grass.bat.tmpl
) > ~/usr/grass/bin/grass79.bat
