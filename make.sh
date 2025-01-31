#!/bin/sh
# This script builds GRASS GIS, addons, or gdal-grass.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}

case "$1" in
-h|--help)
	cat<<'EOT'
Usage: make.sh [OPTIONS] [TARGETS]

-h, --help      display this help message
-a, --addons    make addons (default: GRASS)
-A, --addon     make an addon
-g, --gdal      make gdal-grass
EOT
	exit
	;;
-a|-A|-g|--addons|--addon|--gdal)
	opt=$1
	shift
	;;
-*)
	echo "$1: Unknown option"
	exit 1
	;;
*)
	opt=""
	;;
esac

# use OSGeo4W Python
export PATH="$OSGEO4W_ROOT/bin:$PATH"
export PYTHONHOME="$OSGEO4W_ROOT/apps/python312"

case "$opt" in
"")
	cd $GRASS_SRC
	make "$@"
	;;
-a|-A|--addons|--addon)
	[ "$opt" = "--addons" ] && cd $GRASS_ADDONS_SRC/src
	# CFLAGS for v.feature.algebra
	# https://stackoverflow.com/a/28566889/16079666
	make \
	CFLAGS="-Dsrandom=srand -Drandom=rand" \
	MODULE_TOPDIR=$GRASS_SRC \
	LIBREDWGLIBPATH=-L$LIBREDWG_LIB \
	LIBREDWGINCPATH=-I$LIBREDWG_INC \
	"$@"
	;;
-g|--gdal)
	cd $GDAL_GRASS_SRC
	make "$@"
	;;
esac
