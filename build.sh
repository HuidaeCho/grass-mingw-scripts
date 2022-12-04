#!/bin/sh
# This script builds GRASS GIS using other scripts.
#
# Usage:
#	build.sh
#	build.sh --merge
#	build.sh --addons
#	build.sh --package

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
package=0
addons=0
for opt; do
	case $opt in
	-m|--merge)
		merge=1
		;;
	-p|--package)
		package=1
		;;
	-a|--addons)
		addons=1
		;;
	esac
done
exit

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
mkbats.sh

if [ $addons -eq 1 ]; then
	cd $GRASS_ADDONS_SRC
	if [ $merge -eq 1 ]; then
		merge.sh
	fi
	mkaddons.sh
fi

if [ $package -eq 1 ]; then
	package.sh
fi
) > update.log 2>&1
