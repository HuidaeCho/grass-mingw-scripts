# MinGW scripts for building portable GRASS GIS on MS Windows

This repository contains MinGW scripts for building portable GRASS GIS on 64-bit MS Windows (not tested on 32-bit systems). These scripts will compile [a personal portable daily build](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html#-latest-daily-build). Official daily builds from the GRASS GIS development team are available from [here](https://grass.osgeo.org/download/software/ms-windows/).

Please refer to [How to compile GRASS GIS on MS Windows](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html) to see why I created these scripts in the first place, but I found another use case: portability with no administrative rights.

See [grass-build-scripts](https://github.com/HuidaeCho/grass-build-scripts) for cross-compilation for MS Windows.

## OSGeo4W installation without administrative rights

[The OSGeo4W installer](https://download.osgeo.org/osgeo4w/v2/osgeo4w-setup.exe) requires [administrative rights](https://trac.osgeo.org/osgeo4w/ticket/304), but most IT departments, if not all, in many institutes and universities do not give out administrative rights to faculty and students. They may provide a means for installing selected software from their proprietary software center, but, usually, not all packages are maintained up to date. I have personally experienced this problem and my students were not able to install the latest daily build of GRASS GIS.

## Just extracting to C:\

My solution was to build it myself daily and deploy it to a shared folder so they can extract it to their C drive. This is possible because MS Windows allows non-administrators to create new folders in the root of the C drive (but not new files there). You can download the latest daily build of GRASS GIS from [here](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html#-latest-daily-build).

## Portability

You can extract this build to anywhere including external USB drives to make GRASS GIS portable. Just run `E:\OSGeo4W\opt\grass\grass.bat` where `E:` is your external drive.

## How to compile the latest version of GRASS GIS

Again, 32-bit systems were not tested.

### Preparing a building environment

1. Start a `cmd` window and run the following command to install [OSGeo4W](https://download.osgeo.org/osgeo4w/v2/osgeo4w-setup.exe) to `C:\OSGeo4W`:
   ```batch
   osgeo4w-setup.exe -A -g -k -q -s https://download.osgeo.org/osgeo4w/v2/x86_64/ -P python3-wxpython,python3-pywin32,proj-devel,gdal-devel,liblas-devel,netcdf-devel,geos-devel,libtiff-devel,libpng-devel,sqlite3-devel,cairo-devel,freetype-devel,zstd-devel
   ```
2. Install [MSYS2](https://www.msys2.org/) to `C:\msys64`.
3. Start `MSYS2 MinGW 64-bit` and run the following command:
   ```bash
   pacman --noconfirm -S tar libintl make flex bison diffutils git dos2unix zip mingw-w64-x86_64-gcc libbz2-devel mingw-w64-x86_64-libsystre mingw-w64-x86_64-fftw mingw-w64-x86_64-pkg-config
   ```
4. Compile GRASS GIS.
   ```bash
   # add two export lines to ~/.bash_profile
   cat <<'EOT' >> ~/.bash_profile
   export LC_ALL=C
   export PATH="/c/osgeo4w/bin:/mingw64/bin:$PATH"
   export PROJ_LIB="/c/osgeo4w/share/proj"
   export PYTHONHOME="/c/osgeo4w/apps/python312"
   EOT

   # source ~/.bash_profile
   . ~/.bash_profile

   mkdir -p ~/usr/local/src
   cd ~/usr/local/src

   # download the GRASS build scripts in ~/usr/local/src/grass-mingw-scripts
   git clone https://github.com/HuidaeCho/grass-mingw-scripts.git

   # download the GRASS source code in ~/usr/local/src/grass
   git clone https://github.com/OSGeo/grass.git
   ```

Now, you're ready to build GRASS GIS and don't need to repeat these steps again.

### Building and packaging GRASS GIS

Copy `.grassmingwrc-example` to `$HOME/.grassmingwrc` and edit it to your paths. Start `MSYS2 MinGW 64-bit` and run the following command:
```bash
build.sh --package
```

The `build.sh` script will build GRASS GIS in `~/usr/local/src/grass/dist.x86_64-w64-mingw32` and optionally package it as `~/usr/local/src/grass/grass83-x86_64-w64-mingw32-osgeo4w64-YYYYMMDD.zip`, which you can simply extract to any drive on other computers without administrative rights.

### Scheduling daily builds

You can schedule daily builds and, optionally, copy the latest package to deployment directories (``U:\Shared\Software`` in this example).

1. Press the Windows key, type and run `Task Scheduler`.
2. Click `Create Basic Task...`.
3. Set `Name` to `Daily GRASS Builds` and click `Next`.
4. Select `Daily` and click `Next`.
5. Set your preferred start time and click `Next`.
6. Select `Start a program` and click `Next`.
7. Set `Program/script` to `C:\msys64\usr\bin\bash.exe`, `Add arguments` to `-l ~/usr/local/src/grass-mingw-scripts/deploy.sh /u/shared/software`, and click `Next`.
8. Click `Finish`.

## Autocompletion in the `cmd` window

GRASS GIS has a lot of command-line modules and I sometimes rely on autocompletion to find some module names in Linux. However, in MS Windows, the `cmd` window has limited autocompletion features compared to the bash shell and does not allow me to complete command names. You may want to replace the default shell with the MSYS shell by uncommenting `GRASS_SH` in `C:\OSGeo4W\opt\grass\etc\env.bat`, but GRASS modules written in Python won't work because batch file wrappers cannot be executed properly from the MSYS shell. You would have to type full batch filenames including `.bat`, but, even then, it would fail with `@%GRASS_PYTHON%: command not found`. The MSYS shell cannot just handle batch files nicely.

I found a great autocompletion utility called [Clink](https://github.com/chrisant996/clink). It runs with the `cmd` window and supports command name completion. The easiest way to run Clink with `cmd` is to use its autorun install.

```batch
clink autorun install
```

Clink will automatically run whenever you start `cmd`.

## BusyBox for Windows

Alternatively, you can use [BusyBox for Windows](https://frippery.org/busybox/).

```bash
build.sh --busybox --package
```
