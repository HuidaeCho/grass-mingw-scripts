#!/bin/sh
# This script configures include/Make/Platform.make and other files for
# building GRASS GIS.

set -e
. ${GRASSBUILDRC-~/.grassbuildrc}
cd $GRASS_SRC

OSGEO4W_ROOT_MSYS=$OSGEO4W
GRASS_SOURCE=`pwd`
tmp=`dirname $0`
GRASS_MINGW_SCRIPTS=`realpath $tmp`

sed -e 's/-lproj/-lproj_6_2/g' configure > myconfigure
OSGEO4W_ROOT_MSYS=$OSGEO4W_ROOT_MSYS \
./myconfigure \
--host=$MINGW_CHOST \
--with-nls \
--with-includes=$OSGEO4W_ROOT_MSYS/include \
--with-libs="$OSGEO4W_ROOT_MSYS/lib $OSGEO4W_ROOT_MSYS/bin" \
--with-gdal=$GRASS_SOURCE/mswindows/osgeo4w/gdal-config \
--with-opengl=windows \
--with-freetype-includes=$OSGEO4W_ROOT_MSYS/include/freetype2 \
--with-geos=$GRASS_SOURCE/mswindows/osgeo4w/geos-config \
--with-netcdf=$GRASS_MINGW_SCRIPTS/nc-config \
--with-liblas=$GRASS_SOURCE/mswindows/osgeo4w/liblas-config \
--with-bzlib \
> myconfigure.log 2>&1
