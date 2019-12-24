#!/bin/sh
# This script builds the latest version of the master branch of
# https://github.com/OSGeo/grass.git or the hcho branch of
# https://github.com/HuidaeCho/grass.git.
#
# Usage:
#	update.sh           # update the build
#	update.sh --package # update and package the build

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

export MINGW_CHOST=$ARCH
export PATH="$GRASS_BUILD_DIR:/mingw$SYSTEM_BIT/bin:$PATH"

(
merge.sh
myconfigure.sh
mymake.sh clean default

case $1 in
-p|--package)
	package.sh
	;;
*)
	mkbats.sh
	;;
esac
) > build_latest.log 2>&1
