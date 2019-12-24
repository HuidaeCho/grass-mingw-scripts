#!/bin/sh
# This script builds GRASS GIS.

set -e

# see if we're inside the root of the GRASS source code
if [ ! -e grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

# make
make "$@" > mymake.log 2>&1
