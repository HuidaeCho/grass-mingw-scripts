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
git checkout main
# if upstream/main exists, assume it's OSGeo's main branch
if echo "$branches" | grep -q '^upstream/main$'; then
	# rebase OSGeo's main
	git rebase upstream/main
else
	# merge origin/main (either OSGeo's or HuidaeCho's main)
	git rebase origin/main
fi
# if origin/hcho exists, assume it's HuidaeCho's hcho branch
if echo "$branches" | grep -q '^origin/hcho$'; then
	# use hcho because he's cool ;-)
	git checkout hcho
	# rebase origin/hcho
	git rebase origin/hcho
	# may not be able to rebase
	# merge main already merged with upstream/main or origin/main
	git merge main
fi
