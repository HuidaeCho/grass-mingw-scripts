#!/bin/sh
# This script is meant to be run by Task Scheduler.
#
# To build the latest
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/build_daily.sh /usr/local/src/grass
#
# To build the latest and copy it to U:\Shared\Software and P:\Software
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/build_daily.sh /usr/local/src/grass
#	/u/shared/software /p/software
#
# To build the latest and copy it to U:\Shared\Software and P:\Software, but
# delete any previous packages from P:\Software
# cmd.exe /c c:\msys64\usr\bin\bash -l
#	/usr/local/src/grass-mingw-scripts/build_daily.sh /usr/local/src/grass
#	/u/shared/software -/p/software

set -e

if [ $# -lt 1 ]; then
	echo "Usage: build_daily.sh /path/to/grass/source [/deploy/path1 /deploy/paty2 ...]"
	exit 1
fi

GRASS_SRC=$1
if [ ! -d $GRASS_SRC ]; then
	echo "$GRASS_SRC: No such directory"
	exit 1
fi

shift
DEPLOY_PATHS="$@"

cd $GRASS_SRC
(
tmp=`dirname $0`; GRASS_BUILD_SCRIPTS=`realpath $tmp`
$GRASS_BUILD_SCRIPTS/grass-mingw-scripts/compile.sh --update --package

# check architecture
case "$MSYSTEM_CARCH" in
x86_64)
	ARCH=x86_64-w64-mingw32
	BIT=64
	;;
i686)
	ARCH=i686-w64-mingw32
	BIT=32
	;;
*)
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

VERSION=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
DATE=`date +%Y%m%d`
GRASS_ZIP=grass$VERSION-$ARCH-osgeo4w$BIT-$DATE.zip

for dir in "$@"; do
	delete=0
	case "$dir" in
	-*)
		delete=1
		dir=`echo $dir | sed 's/^-//'`
		;;
	esac
	test -e $dir || mkdir -p $dir
	if [ $delete -eq 1 ]; then
		rm -f $dir/grass*-$ARCH-osgeo4w$BIT-*.zip
	fi
	cp -a $GRASS_ZIP $dir
done
) > build_daily.log 2>&1