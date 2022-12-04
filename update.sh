#!/bin/sh
# This script builds the latest version of the main branch of
# https://github.com/OSGeo/grass.git and the grass8 branch of
# https://github.com/OSGeo/grass-addons.git.
#
# Usage:
#	update.sh           # update the build
#	update.sh --package # update and package the build

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	arch=x86_64-w64-mingw32
	bit=64
	;;
i686)
	arch=i686-w64-mingw32
	bit=32
	;;
*)
	echo "$MSYSTEM_CARCH: Unsupported architecture"
	exit 1
esac

export MINGW_CHOST=$arch
export PATH="$GRASS_MINGW_SCRIPTS:/mingw$bit/bin:$PATH"

# build
(
cd $GRASS_SRC
merge.sh
configure.sh
make.sh clean default
copydlls.sh
mkbats.sh

cd $GRASS_ADDONS_SRC
merge.sh
mkaddons.sh

case "$1" in
-p|-package|--package)
	package.sh
	;;
esac
) > update.log 2>&1
