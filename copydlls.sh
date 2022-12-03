#!/bin/sh
# This script copies dependent DLLs from MinGW.

set -e

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi

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
	echo "$MSYSTEM_CARCH: unsupported architecture"
	exit 1
esac

cp -a `ldd dist.$arch/lib/*.dll | awk '/mingw'$bit'/{print $3}' |
	sort -u | grep -v 'lib\(crypto\|ssl\)'` dist.$arch/lib
