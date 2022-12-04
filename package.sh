#!/bin/sh
# This script packages already built GRASS GIS as a standalone ZIP file that
# can be extracted to C:\.

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

osgeo4w_root=`echo $OSGEO4W_ROOT | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
opt_path=$OSGEO4W_ROOT/opt
grass_path=$opt_path/grass
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
date=`date +%Y%m%d`

# copy MinGW libraries
test -d $grass_path && rm -rf $grass_path
test -d $opt_path || mkdir -p $opt_path
cp -a dist.$arch $grass_path

# update batch files
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    dist.$arch/etc/env.bat > $grass_path/etc/env.bat

sed -e 's/^\(call "\).*\(\\o4w_env\.bat"\)$/\1%~dp0\\..\\..\\bin\2/' \
    -e 's/^\(call "\).*\(\\env\.bat"\)$/\1%OSGEO4W_ROOT%\\opt\\grass\2/' \
    -e 's/^\("%GRASS_PYTHON%" "\).*\(\\etc\\grass[0-9]*\.py".*\)$/\1%GISBASE%\2/g' \
    bin.$arch/grass.bat > $grass_path/grass.bat

# package
grass_zip=$GRASS_SRC/grass$version-$arch-osgeo4w$bit-$date.zip

cd $OSGEO4W_ROOT/..
osgeo4w_basename=`basename $OSGEO4W_ROOT`
rm -f $GRASS_SRC/grass*-$arch-osgeo4w$bit-*.zip
zip -r $grass_zip $osgeo4w_basename -x "$osgeo4w_basename/var/*" "*/__pycache__/*"
