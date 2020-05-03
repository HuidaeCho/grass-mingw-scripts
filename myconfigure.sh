#!/bin/sh
# This script configures include/Make/Platform.make and other files for
# building GRASS GIS.
#
# To override the default OSGeo4W path (/c/OSGeo4W64),
#	OSGEO4W_PATH=/d/OSGeo4W64 myconfigure.sh

set -e
osgeo4w_root_msys=${OSGEO4W_PATH-/c/OSGeo4W64}

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

grass_src=`pwd`
tmp=`dirname $0`; grass_build_scripts=`realpath $tmp`

OSGEO4W_ROOT_MSYS=$osgeo4w_root_msys \
./configure \
--host=$MINGW_CHOST \
--with-includes=$osgeo4w_root_msys/include \
--with-libs="$osgeo4w_root_msys/lib $osgeo4w_root_msys/bin" \
--with-nls \
--with-freetype-includes=$osgeo4w_root_msys/include/freetype2 \
--with-bzlib \
--with-geos=$grass_src/mswindows/osgeo4w/geos-config \
--with-netcdf=$grass_build_scripts/nc-config \
--with-gdal=$grass_src/mswindows/osgeo4w/gdal-config \
--with-liblas=$grass_src/mswindows/osgeo4w/liblas-config \
--with-opengl=windows \
> myconfigure.log 2>&1
