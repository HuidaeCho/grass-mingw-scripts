#!/bin/sh
# This script configures include/Make/Platform.make and other files for
# building GRASS GIS.
#
# To override the default OSGEO4W (/c/osgeo4w64),
#	OSGEO4W=/d/osgeo4w64 myconfigure.sh

set -e
OSGEO4W_ROOT_MSYS=${OSGEO4W-/c/osgeo4w64}

# see if we're inside the root of the GRASS source code
if [ ! -e grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

GRASS_SRC=`pwd`
tmp=`dirname $0`; GRASS_BUILD_SCRIPTS=`realpath $tmp`

sed -e 's/-lproj/-lproj_6_2/g' configure > myconfigure
OSGEO4W_ROOT_MSYS=$OSGEO4W_ROOT_MSYS \
./myconfigure \
--host=$MINGW_CHOST \
--with-nls \
--with-includes=$OSGEO4W_ROOT_MSYS/include \
--with-libs="$OSGEO4W_ROOT_MSYS/lib $OSGEO4W_ROOT_MSYS/bin" \
--with-gdal=$GRASS_SRE/mswindows/osgeo4w/gdal-config \
--with-opengl=windows \
--with-freetype-includes=$OSGEO4W_ROOT_MSYS/include/freetype2 \
--with-geos=$GRASS_SRC/mswindows/osgeo4w/geos-config \
--with-netcdf=$GRASS_BUILD_SCRIPTS/nc-config \
--with-liblas=$GRASS_SRC/mswindows/osgeo4w/liblas-config \
--with-bzlib \
> myconfigure.log 2>&1
