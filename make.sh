#!/bin/sh
# This script builds GRASS GIS.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

make "$@" > make.log 2>&1
