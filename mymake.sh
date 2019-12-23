#!/bin/sh
# This script builds GRASS GIS.

set -e
. ${GRASSBUILDRC-~/.grassbuildrc}
cd $GRASS_SRC

make "$@" > mymake.log 2>&1
