#!/bin/sh
# This script builds the latest version of the hcho branch of
# https://github.com/HuidaeCho/grass.git.

set -e
export MINGW_CHOST=x86_64-w64-mingw32
export PATH="/mingw64/bin:$PATH"

(
cd ~/usr/grass/grass
git checkout master
git fetch --all
git merge upstream/master
git checkout hcho
git merge master
make clean
../myconfigure.sh
../mymake.sh
../package.sh
) > ~/usr/grass/update.log 2>&1
