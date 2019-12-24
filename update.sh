#!/bin/sh
# This script builds the latest version of the master branch of
# https://github.com/OSGeo/grass.git or the hcho branch of
# https://github.com/HuidaeCho/grass.git.
#
# Usage:
#	update.sh           # update the build
#	update.sh --package # update and package the build
#
# To override the default OSGEO4W (/c/osgeo4w64),
#	OSGEO4W=/d/osgeo4w64 update.sh

set -e

# see if we're inside the root of the GRASS source code
if [ ! -e grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	ARCH=x86_64-w64-mingw32
	BIT=64
	;;
i686)
	ARCH=i686-w64-mingw32
	BIT=32
	;;
*)
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

tmp=`dirname $0`; GRASS_BUILD_SCRIPTS=`realpath $tmp`

export MINGW_CHOST=$ARCH
export PATH="$GRASS_BUILD_SCRIPTS:/mingw$BIT/bin:$PATH"

# build
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
) > update.log 2>&1
