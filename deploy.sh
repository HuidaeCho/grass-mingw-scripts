#!/bin/sh
# This script is meant to be run by Task Scheduler.
#
# To build the latest:
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/deploy.sh
#
# To build the latest and copy it to P:\Archive and U:\Shared\Software:
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/deploy.sh
#	/p/archive /u/shared/software
#
# To build the latest and copy it to P:\Archive and U:\Shared\Software, but
# delete any previous packages from U:\Shared\Software leaving the latest only:
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/deploy.sh
#	/p/archive -/u/shared/software

set -e
. ${GRASSMINGWRC-~/.grassmingwrc}
cd $GRASS_SRC

if [ $# -lt 1 ]; then
	echo "Usage: deploy.sh /path/to/grass/source [/deploy/path1 /deploy/paty2 ...]"
	exit 1
fi

grass_mingw_scripts=$(dirname $(realpath $0))

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

export PATH="$grass_mingw_scripts:$PATH"

build.sh --merge --addons --busybox --package

version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
date=`date +%Y%m%d`
grass_zip=grass$version-$arch-osgeo4w$bit-$date.zip

for dir; do
	delete=0
	case "$dir" in
	-*)
		delete=1
		dir=`echo $dir | sed 's/^-//'`
		;;
	esac
	[ -d $dir ] || mkdir -p $dir
	if [ $delete -eq 1 ]; then
		rm -f $dir/grass*-$arch-osgeo4w$bit-*.zip
	fi
	cp -a $grass_zip $dir
done
