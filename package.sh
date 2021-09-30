#!/bin/sh
# This script packages already built GRASS GIS as a standalone ZIP file that
# can be extracted to C:\.
#
# To override the default OSGeo4W path (/c/OSGeo4W64),
#	OSGEO4W_PATH=/d/OSGeo4W64 package.sh

set -e
osgeo4w_root_msys=${OSGEO4W_PATH-/c/OSGeo4W64}

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

osgeo4w_root=`echo $osgeo4w_root_msys | sed 's#^/##; s#/#:\\\\#; s#/#\\\\#g'`
opt_path=$osgeo4w_root_msys/opt
grass_path=$opt_path/grass
version=`sed -n '/^INST_DIR[ \t]*=/{s/^.*grass//; p}' include/Make/Platform.make`
date=`date +%Y%m%d`

# copy MinGW libraries
test -d $grass_path && rm -rf $grass_path
test -d $opt_path || mkdir -p $opt_path
cp -a dist.$arch $grass_path
rm -f $grass_path/grass.tmp $grass_path/etc/fontcap
cp -a bin.$arch/grass.py $grass_path/etc/grass$version.py
cp -a `ldd dist.$arch/lib/*.dll | awk '/mingw'$bit'/{print $3}' |
	sort -u | grep -v 'lib\(crypto\|ssl\)'` $grass_path/lib

# create batch files for cmd.exe
(
sed -e 's/^\(set GISBASE=\).*/\1%OSGEO4W_ROOT%\\opt\\grass/' \
    mswindows/osgeo4w/env.bat.tmpl
cat<<EOT

set PATH=%OSGEO4W_ROOT%\\apps\\msys\\bin;%PATH%

if not exist %GISBASE%\etc\fontcap (
	pushd .
	%~d0
	cd %GISBASE%\lib
	set GISRC=dummy
	%GISBASE%\bin\g.mkfontcap.exe
	popd
)
EOT
) > $grass_path/etc/env_cmd.bat
unix2dos $grass_path/etc/env_cmd.bat

(
sed -e 's/^\(call "%~dp0\)\(.*\)$/\1\\..\\..\\bin\2/' \
    -e 's/^\(call "%OSGEO4W_ROOT%\\\).*\(\\etc\\env\)\(\.bat"\)$/\1opt\\grass\2_cmd\3/' \
    -e "s/@POSTFIX@/$version/g" \
    mswindows/osgeo4w/grass.bat.tmpl
) > $grass_path/grass_cmd.bat
unix2dos $grass_path/grass_cmd.bat

# create batch files for sh.exe
sed 's/^REM \(set GRASS_SH\)/\1/' $grass_path/etc/env_cmd.bat > $grass_path/etc/env.bat
sed 's/\(\\env\)_cmd\(\.bat\)/\1\2/' $grass_path/grass_cmd.bat > $grass_path/grass.bat
unix2dos $grass_path/etc/env.bat $grass_path/grass.bat

# create shell scripts for sh.exe
for bat in $grass_path/bin/*.bat; do
	sh=`echo $bat | sed 's/\.bat//'`
	(
	echo "#!/bin/sh"
	sed 's/@//; s/%\([^%]*)%/\$\1/g; s/%\*/"\$@"/' $bat
	) > $sh
done

# package
grass_src=`pwd`
grass_zip=$grass_src/grass$version-$arch-osgeo4w$bit-$date.zip

cd $osgeo4w_root_msys/..
osgeo4w_basename=`basename $osgeo4w_root_msys`
rm -f $grass_src/grass*-$arch-osgeo4w$bit-*.zip
zip -r $grass_zip $osgeo4w_basename -x "$osgeo4w_basename/var/*" "*/__pycache__/*"
