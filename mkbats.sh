#!/bin/sh
# This script creates batch files for starting up GRASS GIS from the source
# directory.
#
# To override the default OSGeo4W path (/c/OSGeo4W64),
#	OSGEO4W_PATH=/d/OSGeo4W64 mkbats.sh

set -e
osgeo4w_root_msys=${OSGEO4W_PATH-/c/OSGeo4W64}

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	arch=x86_64-w64-mingw32
	;;
i686)
	arch=i686-w64-mingw32
	;;
*)
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

osgeo4w_root=`echo $osgeo4w_root_msys | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
msys2_root=`echo $WD | sed 's#\\\\usr.*##'`
mingw_root=`echo "$msys2_root$MINGW_PREFIX" | tr / '\\\\'`

grass_src_win=`pwd -W | tr / '\\\\'`
grass_bin_win="$grass_src_win\\bin.$arch"
grass_dist_win="$grass_src_win\\dist.$arch"

# create batch files
sed -e 's/^\(set GISBASE=\).*/\1'$grass_dist_win'/' \
    mswindows/osgeo4w/env.bat.tmpl
echo
echo "set PATH=$mingw_root\\bin;%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%"
) > dist.$arch/etc/env.bat
unix2dos dist.$arch/etc/env.bat

osgeo4w_root_escaped=`echo $osgeo4w_root | sed 's/\\\\/\\\\\\\\/g'`
msys2_root_escaped=`echo $msys2_root | sed 's/\\\\/\\\\\\\\/g'`
if echo $HOME | grep -q '^/[a-z]\($\|/\)'; then
	home_escaped=`echo $HOME | sed 's#^/\(.\)#\1:/#'`
else
	home_escaped="$msys2_root_escaped/$HOME"
fi
home_escaped=`echo $home_escaped | sed 's#//*#\\\\\\\\#g'`
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
(
sed -e 's/^\(call "\)%~dp0\(.*\)$/\1'$osgeo4w_root_escaped'\\bin\2\nSET HOME='$home_escaped'/' \
    -e 's/^call "%OSGEO4W_ROOT%.*\\env\.bat"$/call "'$grass_dist_win'\\etc\\env.bat"/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\?\(".*\)/\1'$grass_bin_win'\\grass'$version'.py\2/' \
    mswindows/osgeo4w/grass.bat.tmpl
) > bin.$arch/grass$version.bat
unix2dos bin.$arch/grass$version.bat
