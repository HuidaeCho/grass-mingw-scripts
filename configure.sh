#!/bin/sh
# This script configures include/Make/Platform.make and other files for
# building GRASS GIS.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

OSGEO4W_ROOT_MSYS=$OSGEO4W_ROOT \
./configure \
--host=$MINGW_CHOST \
--with-includes=$OSGEO4W_ROOT/include \
--with-libs="$OSGEO4W_ROOT/lib $OSGEO4W_ROOT/bin" \
--with-nls \
--with-freetype-includes=$OSGEO4W_ROOT/include/freetype2 \
--with-bzlib \
--with-netcdf=nc-config \
--with-libpng=mswindows/osgeo4w/libpng-config \
--with-geos=mswindows/osgeo4w/geos-config \
--with-gdal=mswindows/osgeo4w/gdal-config \
--with-liblas=mswindows/osgeo4w/liblas-config \
--with-opengl=windows \
> configure.log 2>&1
