# GRASS MinGW Scripts

This repository contains MinGW scripts for building GRASS GIS on MS Windows.

Please refer to [How to compile GRASS GIS on MS Windows](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html) to see why I created these scripts in the first place, but I found another use case.

## OSGeo4W Installation without Administrative Rights

[The OSGeo4W installer](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86_64.exe) requires [administrative rights](https://trac.osgeo.org/osgeo4w/ticket/304), but most IT departments, if not all, in many institutes and universities do not give out administrative rights to faculty and students. They may provide a means for installing selected software from their proprietary software center, but, usually, not all packages are maintained up to date. I have personally experienced this problem and my students were not able to install the latest daily build of GRASS GIS.

## Just Extract Daily Builds to C:\

My solution was to build it myself daily and deploy it to a shared folder so they can extract it to their C drive. This is possible because MS Windows allows non-administrators to create new folders in the root of the C drive (but not new files there). You can download the latest daily build of GRASS GIS from [here](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html#latest-daily-build).

## Official Daily Builds from the GRASS GIS Development Team

Please note that these scripts compile a personal daily build. Official daily builds from the GRASS GIS development team are available from [here](https://grass.osgeo.org/download/software/ms-windows/).
