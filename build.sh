#!/bin/sh
# This script builds GRASS GIS using other scripts.

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}

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

merge=0
addons=0
gdal=0
busybox=""
package=0
for opt; do
	case "$opt" in
	-h|--help)
		cat<<'EOT'
Usage: build.sh [OPTIONS]

-h, --help       display this help message
-m, --merge      merge the upstream repositories
-a, --addons     build addons
-g, --gdal       build gdal-grass
-b, --busybox    create batch files for BusyBox
-p, --package    package the build as grass{VERSION}-{ARCH}-osgeo4w{BIT}-{YYYYMMDD}.zip
EOT
		exit
		;;
	-m|--merge)
		merge=1
		;;
	-a|--addons)
		addons=1
		;;
	-g|--gdal)
		gdal=1
		;;
	-b|--busybox)
		busybox=$opt
		;;
	-p|--package)
		package=1
		;;
	esac
done

export MINGW_CHOST=$arch
mingw64_bin=`pacman -Ql mingw-w64-x86_64-gcc | sed '/bin\/gcc\.exe$/!d; s/.* \|\|\/gcc.*//g'`
export PATH="$(dirname $(realpath $0)):$mingw64_bin:$PATH"

echo "Started compilation: `date`"
echo

[ $merge -eq 1 ] && merge.sh
configure.sh
make.sh clean default

if [ $gdal -eq 1 ]; then
	[ $merge -eq 1 ] && merge.sh --gdal
	configure.sh --gdal
	make.sh --gdal clean install
fi

copydlls.sh
mkbats.sh $busybox

if [ $addons -eq 1 ]; then
	[ $merge -eq 1 ] && merge.sh --addons
	make.sh --addons clean default
fi

if [ $package -eq 1 ]; then
	copydist.sh
	package.sh
fi

echo
echo "Completed compilation: `date`"
