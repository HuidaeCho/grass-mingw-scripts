#!/bin/sh
# This script builds the latest version of the master branch of
# https://github.com/OSGeo/grass.git or the hcho branch of
# https://github.com/HuidaeCho/grass.git.

set -e
export MINGW_CHOST=x86_64-w64-mingw32
export PATH="/mingw64/bin:$PATH"

(
cd ~/usr/grass/grass
../merge.sh
../myconfigure.sh
../mymake.sh clean default
../package.sh
) > ~/usr/grass/update.log 2>&1
