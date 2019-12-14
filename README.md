# GRASS MinGW Scripts

This repository contains MinGW scripts for building portable GRASS GIS on 64-bit MS Windows. These scripts do not support 32-bit systems and will compile a personal daily build. Official daily builds from the GRASS GIS development team are available from [here](https://grass.osgeo.org/download/software/ms-windows/).

Please refer to [How to compile GRASS GIS on MS Windows](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html) to see why I created these scripts in the first place, but I found another use case.

## OSGeo4W Installation Without Administrative Rights

[The OSGeo4W installer](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86_64.exe) requires [administrative rights](https://trac.osgeo.org/osgeo4w/ticket/304), but most IT departments, if not all, in many institutes and universities do not give out administrative rights to faculty and students. They may provide a means for installing selected software from their proprietary software center, but, usually, not all packages are maintained up to date. I have personally experienced this problem and my students were not able to install the latest daily build of GRASS GIS.

## Just Extract to C:\

My solution was to build it myself daily and deploy it to a shared folder so they can extract it to their C drive. This is possible because MS Windows allows non-administrators to create new folders in the root of the C drive (but not new files there). You can download the latest daily build of GRASS GIS from [here](https://idea.isnew.info/how-to-compile-grass-gis-on-ms-windows.html#latest-daily-build).

## Portability

You can extract this build to anywhere including external USB drives to make GRASS GIS portable. Just run `E:\OSGeo4W64\opt\grass\grass79.bat` where `E:` is your external drive.

## How to Compile the Latest Version of GRASS GIS

Again, 32-bit systems are not supported.

### Preparing a Building Environment

1. Start a `cmd` window and run the following command to install [OSGeo4W](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86_64.exe) to `C:\OSGeo4W64`:
   ```batch
   osgeo4w-setup-x86_64.exe -A -g -k -q -s http://download.osgeo.org/x86_64 -P cairo,fftw,freetype-devel,gdal-ecw,gdal-mrsid,liblas-devel,libxdr,msys,pdcurses,python3-numpy,python3-pywin32,python3-wx,regex-devel,wxpython,zstd-devel
   ```
2. Install [MSYS2](https://www.msys2.org/) to `C:\msys64`.
3. Start `MSYS2 MinGW 64-bit` and run the following command:
   ```bash
   pacman -S tar libintl make bison diffutils git dos2unix zip mingw-w64-x86_64-toolchain mingw-w64-x86_64-cairo mingw-w64-x86_64-python3-six
   ```
4. Add `/mingw64/bin` and `/c/osgeo4w64/bin` to `$PATH`:
   ```bash
   cat <<EOT >> ~/.bash_profile
   export LC_ALL=C
   export PATH="/mingw64/bin:/c/osgeo4w64/bin:$PATH"
   EOT
   . ~/.bash_profile
   ```
5. Clone this repository and GRASS GIS repository:
   ```bash
   mkdir ~/usr
   cd ~/usr
   git clone https://github.com/HuidaeCho/grass-mingw-scripts.git grass
   cd grass
   git clone git clone https://github.com/OSGeo/grass.git
   ```

Now, you're ready to build GRASS GIS and don't need to repeat these steps again.

### Building the Latest Master Branch

Start `MSYS2 MinGW 64-bit` and run `~/usr/grass/build_latest_master.sh`.

The `build_latest_master.sh` will build the latest master branch of the official GRASS GIS repository in `~/usr/grass/grass/dist.x86_64-w64-mingw32` and package it as `~/usr/grass/grass79.zip`, which you can simply extract to `C:\OSGeo4W64` on other computers without administrative rights.

### Building the Latest HCho Branch

If you want to build the latest hcho branch of my personal repository that includes all my personal changes that may not have been merged into the official repository yet, change `https://github.com/OSGeo/grass.git` to `https://github.com/HuidaeCho/grass.git` in step 5 and run `~/usr/grass/build_latest_hcho.sh`.

### Scheduling Daily Builds

You can run `build_latest_master.sh` automatically overnight to keep the build up to date daily.

1. Press the Windows key, type and run `Task Scheduler`.
2. Click `Create Basic Task...`.
3. Set `Name` to `Daily GRASS Builds` and click `Next`.
4. Select `Daily` and click `Next`.
5. Set your preferred start time and click `Next`.
6. Select `Start a program` and click `Next`.
7. Set `Program/script` to `C:\msys64\usr\bin\bash.exe`, `Add arguments` to `-l ~/usr/grass/build_latest_master.sh`, and click `Next`.
8. Click `Finish`.

## Autocompletion in the CMD Window

GRASS GIS has a lot of command-line modules and I sometimes rely on autocompletion to find some module names in Linux. However, in MS Windows, the `cmd` window has limited autocompletion features compared to the bash shell and does not allow me to complete command names. You may want to replace the default shell with the MSYS shell by uncommenting `GRASS_SH` in `C:\OSGeo4W64\opt\grass\etc\env.bat`, but GRASS modules written in Python won't work because batch file wrappers cannot be executed properly from the MSYS shell. You would have to type full batch filenames including `.bat`, but, even then, it would fail with `@%GRASS_PYTHON%: command not found`. The MSYS shell cannot just handle batch files nicely.

I found a great autocompletion utility called [Clink](http://mridgers.github.io/clink/). It runs with the `cmd` window and supports command name completion. The easiest way to run Clink with `cmd` is to use its autorun install.

```batch
clink_x64.exe autorun install
```

Clink will automatically run whenever you start `cmd`.
