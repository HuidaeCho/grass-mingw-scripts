#!/bin/sh
# This script packages an already copied distribution as a standalone ZIP
# file that can be extracted to C:\.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

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
	echo "$MSYSTEM_CARCH: Unsupported architecture"
	exit 1
esac

version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
date=`date +%Y%m%d`

# package
grass_zip=$GRASS_SRC/grass$version-$arch-osgeo4w$bit-$date.zip

cd $OSGEO4W_ROOT/..
osgeo4w_basename=`basename $OSGEO4W_ROOT`
rm -f $GRASS_SRC/grass*-$arch-osgeo4w$bit-*.zip
zip -r $grass_zip $osgeo4w_basename -x "$osgeo4w_basename/var/*" "*/__pycache__/*"
