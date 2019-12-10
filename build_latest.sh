#!/bin/sh
set -e
export MINGW_CHOST=x86_64-w64-mingw32
export PATH="/mingw64/bin:$PATH"
. ~/.ssh/agentrc

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
