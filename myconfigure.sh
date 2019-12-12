#!/bin/sh
sed -e 's/-lproj/-lproj_6_2/g' configure > myconfigure
OSGEO4W_ROOT_MSYS=/c/osgeo4w64 \
./myconfigure \
--host=$MINGW_CHOST \
--with-nls \
--with-includes=/c/osgeo4w64/include \
--with-libs='/c/osgeo4w64/lib /c/osgeo4w64/bin' \
--with-gdal=$HOME/usr/grass/grass/mswindows/osgeo4w/gdal-config \
--with-opengl=windows \
--with-freetype-includes=/c/osgeo4w64/include/freetype2 \
--with-geos=$HOME/usr/grass/grass/mswindows/osgeo4w/geos-config \
--with-netcdf=$HOME/usr/grass/nc-config \
--with-liblas=$HOME/usr/grass/grass/mswindows/osgeo4w/liblas-config \
> myconfigure.log 2>&1
