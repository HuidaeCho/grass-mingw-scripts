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
busybox=""
package=0
for opt; do
	case "$opt" in
	-h|--help)
		cat<<'EOT'
Usage: build.sh [OPTIONS]

-h, --help       display this help message
    --merge      merge the upstream repositories
    --addons     build addons
    --busybox    create batch files for BusyBox
    --package    package the build as grass{VERSION}-{ARCH}-osgeo4w{BIT}-{YYYYMMDD}.zip
EOT
		exit
		;;
	--merge)
		merge=1
		;;
	--addons)
		addons=1
		;;
	--busybox)
		busybox=$opt
		;;
	--package)
		package=1
		;;
	esac
done

export MINGW_CHOST=$arch
export PATH="$GRASS_MINGW_SCRIPTS:/mingw$bit/bin:$PATH"

# build
(
cd $GRASS_SRC
if [ $merge -eq 1 ]; then
	merge.sh
fi
configure.sh
make.sh clean default
copydlls.sh
mkbats.sh $busybox

if [ $addons -eq 1 ]; then
	cd $GRASS_ADDONS_SRC
	if [ $merge -eq 1 ]; then
		merge.sh
	fi
	mkaddons.sh
fi

if [ $package -eq 1 ]; then
	copydist.sh
	package.sh
fi
) > build.log 2>&1
