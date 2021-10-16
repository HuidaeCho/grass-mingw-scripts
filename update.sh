#!/bin/sh
# This script builds the latest version of the main branch of
# https://github.com/OSGeo/grass.git or the hcho branch of
# https://github.com/HuidaeCho/grass.git.
#
# Usage:
#	update.sh           # update the build
#	update.sh --package # update and package the build
#
# To override the default OSGeo4W path (/c/OSGeo4W64),
#	OSGEO4W_PATH=/d/OSGeo4W64 update.sh

set -e

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

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
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

tmp=`dirname $0`; grass_build_scripts=`realpath $tmp`

export MINGW_CHOST=$arch
export PATH="$grass_build_scripts:/mingw$bit/bin:$PATH"

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
