#!/bin/sh
# This script recreates batch files for supporting BusyBox for Windows
# (https://frippery.org/busybox/).

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

version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' $GRASS_SRC/include/Make/Platform.make`

sed -e 's/^\(set GISBASE=\).*/\1'$dist_esc'/' \
    $GRASS_MINGW_SCRIPTS/env.bat | unix2dos > dist.$arch/etc/env.bat

unix2dos -n $GRASS_MINGW_SCRIPTS/sh.bat dist.$arch/etc/sh.bat
