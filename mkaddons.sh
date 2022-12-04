#!/bin/sh
# This script builds GRASS GIS addons.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_ADDONS_SRC/src

make \
MODULE_TOPDIR=$GRASS_SRC \
LIBREDWGLIBPATH=-L$LIBREDWG_LIB \
LIBREDWGINCPATH=-I$LIBREDWG_INC \
"$@" > $GRASS_SRC/mkaddons.log 2>&1
