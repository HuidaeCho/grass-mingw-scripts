#!/bin/sh
# This script copies an already built distribution to OSGeo4W\opt\grass.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	arch=x86_64-w64-mingw32
	;;
i686)
	arch=i686-w64-mingw32
	;;
*)
	echo "$MSYSTEM_CARCH: Unsupported architecture"
	exit 1
esac

opt_path=$OSGEO4W_ROOT/opt
grass_path=$opt_path/grass

# copy MinGW libraries
test -d $grass_path && rm -rf $grass_path
test -d $opt_path || mkdir -p $opt_path
cp -a dist.$arch $grass_path

# update batch files
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    dist.$arch/etc/env.bat > $grass_path/etc/env.bat

sed -e 's/^\(call "\).*\(\\o4w_env\.bat"\)$/\1%~dp0\\..\\..\\bin\2/' \
    -e 's/^\(call "\).*\(\\etc\\env\.bat"\)$/\1%OSGEO4W_ROOT%\\opt\\grass\2/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\(\\etc\\grass[0-9]*\.py".*\)$/\1%GISBASE%\2/g' \
    bin.$arch/grass.bat > $grass_path/grass.bat
