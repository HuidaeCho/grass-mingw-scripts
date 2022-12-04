#!/bin/sh
# This script creates batch files for starting up GRASS GIS from the source
# directory.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	arch=x86_64-w64-mingw32
	;;
i686)
	arch=i686-w64-mingw32
	;;
*)
	echo "$MSYSTEM_CARCH: Unsupported architecture"
	exit 1
esac

busybox=0
for opt; do
	case "$opt" in
	-h|--help)
		cat<<'EOT'
Usage: mkbats.sh [OPTIONS]

-h, --help       display this help message
    --busybox    create batch files for BusyBox
EOT
		exit
		;;
	--busybox)
		busybox=1
		;;
	esac
done

osgeo4w_root=`echo $OSGEO4W_ROOT | sed 's#^/\([a-z]\)#\1:#; s#/#\\\\#g'`
msys2_root=`echo $WD | sed 's#\\\\usr.*##'`
mingw_root=`echo "$msys2_root$MINGW_PREFIX" | tr / '\\\\'`

src_esc=`pwd -W | sed 's#/#\\\\\\\\#g'`
dist_esc="$src_esc\\\\dist.$arch"

# create batch files
if [ $busybox -eq 1 ]; then
	sed -e 's/^\(set GISBASE=\).*/\1'$dist_esc'/' \
	    $GRASS_MINGW_SCRIPTS/env.bat | unix2dos > dist.$arch/etc/env.bat

	unix2dos -n $GRASS_MINGW_SCRIPTS/sh.bat dist.$arch/etc/sh.bat

	wget -O dist.$arch/etc/busybox64.exe \
	    https://frippery.org/files/busybox/busybox64.exe
else
	(
	sed -e 's/^\(set GISBASE=\).*/\1'$dist_esc'/' \
	    mswindows/osgeo4w/env.bat.tmpl
	cat<<EOT

set PATH=$mingw_root\\bin;%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%

if not exist %GISBASE%\\etc\\fontcap (
	pushd .
	%~d0
	cd %GISBASE%\\lib
	set GISRC=dummy
	%GISBASE%\\bin\\g.mkfontcap.exe
	popd
)
EOT
	) | unix2dos > dist.$arch/etc/env.bat
fi

osgeo4w_root_esc=`echo $osgeo4w_root | sed 's/\\\\/\\\\\\\\/g'`
msys2_root_esc=`echo $msys2_root | sed 's/\\\\/\\\\\\\\/g'`
if echo $HOME | grep -q '^/[a-z]\($\|/\)'; then
	home=`echo $HOME | sed 's#^/\(.\)#\1:/#'`
else
	home="$msys2_root/$HOME"
fi
home_esc=`echo $home | sed 's#//*#\\\\\\\\#g'`
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
sed -e 's/^\(call "\)%~dp0\(.*\)$/\1'$osgeo4w_root_esc'\\bin\2\nSET HOME='$home_esc'/' \
	-e 's/^\(call "\)%OSGEO4W_ROOT%.*\(\\etc\\env\.bat"\)$/\1'$dist_esc'\2/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\?\(".*\)/\1'$dist_esc'\\etc\\grass'$version'.py\2/' \
    mswindows/osgeo4w/grass.bat.tmpl | unix2dos > bin.$arch/grass.bat

test -f bin.$arch/grass.py && mv bin.$arch/grass.py dist.$arch/etc/grass$version.py

rm -f bin.$arch/grass dist.$arch/grass.tmp dist.$arch/etc/fontcap
