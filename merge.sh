#!/bin/sh
# This script merges remote branches.

# see if we're inside the root of the GRASS source code
if [ ! -f SUBMITTING ]; then
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
	# rebase OSGeo's master
	git rebase upstream/master
else
	# merge origin/master (either OSGeo's or HuidaeCho's master)
	git rebase origin/master
fi
# if origin/hcho exists, assume it's HuidaeCho's hcho branch
if echo "$branches" | grep -q '^origin/hcho$'; then
	# use hcho because he's cool ;-)
	git checkout hcho
	# rebase origin/hcho
	git rebase origin/hcho
	# may not be able to rebase
	# merge master already merged with upstream/master or origin/master
	git merge master
fi
