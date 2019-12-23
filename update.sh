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

export MINGW_CHOST=x86_64-w64-mingw32
export PATH="$GRASS_BUILD_DIR:/mingw64/bin:$PATH"

(
merge.sh
myconfigure.sh
mymake.sh clean default

case "$1" in
-p|--package)
	package.sh
	;;
*)
	mkbats.sh
	;;
esac
) > build_latest.log 2>&1
