#!/bin/sh
# This script updates ~/usr/grass/grass to the latest version of the hcho
# branch of https://github.com/HuidaeCho/grass.git and recompile it.

set -e
export MINGW_CHOST=x86_64-w64-mingw32
export PATH="/mingw64/bin:$PATH"

(
cd ~/usr/grass/grass
branches=`git branch -a --format='%(refname:short)'`

git fetch --all
git checkout master
# if upstream/master exists, assume it's https://github.com/OSGeo/grass.git's
# master branch
if echo "$branches" | grep -q '^upstream/master$'; then
	# merge OSGeo's master
	git merge upstream/master
else
	# merge origin/master (either OSGeo's or HuidaeCho's master)
	git merge origin/master
fi
# if origin/hcho exists, assume it's https://github.com/HuidaeCho/grass.git's
# hcho branch
if echo "$branches" | grep -q '^origin/hcho$'; then
	# use hcho because he's cool ;-)
	git checkout hcho
	# merge origin/hcho
	git merge origin/hcho
	# merge master already merged with upstream/master or origin/master
	git merge master
fi
../myconfigure.sh
../mymake.sh clean default
../mkbats.sh
) > ~/usr/grass/update.log 2>&1
