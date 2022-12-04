#!/bin/sh
# This script recreates batch files for supporting BusyBox for Windows
# (https://frippery.org/busybox/).

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_MINGW_SCRIPTS

grass_path=$OSGEO4W_ROOT/opt/grass
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' $GRASS_SRC/include/Make/Platform.make`

for i in env sh; do
	unix2dos -n $i.bat $grass_path/etc/$i.bat
done

sed 's/@POSTFIX@/'$version'/g' grass.bat | unix2dos > $grass_path/grass.bat
