#!/bin/sh
# This script merges remote branches.

# see if we're inside the root of the GRASS source code
if [ ! -f grass.pc.in ]; then
	echo "Please run this script from the root of the GRASS source code"
	exit 1
fi
if [ ! -d .git ]; then
	echo "not a git repository"
	exit 1
fi

branches=`git branch -a --format='%(refname:short)'`

git fetch --all
git checkout master
# if upstream/master exists, assume it's OSGeo's master branch
if echo "$branches" | grep -q '^upstream/master$'; then
	# merge OSGeo's master
	git merge upstream/master
else
	# merge origin/master (either OSGeo's or HuidaeCho's master)
	git merge origin/master
fi
# if origin/hcho exists, assume it's HuidaeCho's hcho branch
if echo "$branches" | grep -q '^origin/hcho$'; then
	# use hcho because he's cool ;-)
	git checkout hcho
	# merge origin/hcho
	git merge origin/hcho
	# merge master already merged with upstream/master or origin/master
	git merge master
fi
