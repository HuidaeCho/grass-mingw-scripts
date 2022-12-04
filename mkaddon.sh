#!/bin/sh
# This script builds a GRASS GIS addon.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}

make \
MODULE_TOPDIR=$GRASS_SRC \
LIBREDWGLIBPATH=-L$LIBREDWG_LIB \
LIBREDWGINCPATH=-I$LIBREDWG_INC \
"$@"
