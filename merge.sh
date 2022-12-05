#!/bin/sh
# This script merges upstream branches.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}

branch=main

case "$1" in
-h|--help)
	cat<<'EOT'
Usage: merge.sh [OPTIONS]

-h, --help      display this help message
-a, --addons    merge GRASS addons (default: GRASS)
-g, --gdal      merge gdal-grass
EOT
	exit
	;;
"")
	cd $GRASS_SRC
	;;
-a|--addons)
	cd $GRASS_ADDONS_SRC
	branch=grass8
	;;
-g|--gdal)
	cd $GDAL_GRASS_SRC
	;;
*)
	echo "$1: Unknown option"
	exit 1
	;;
esac

upstream=`git remote -v | sed '/github.com.OSGeo/!d; s/\t.*//'`

git fetch --all --prune
git checkout $branch
git rebase $upstream/$branch
