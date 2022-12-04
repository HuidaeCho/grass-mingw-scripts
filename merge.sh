#!/bin/sh
# This script merges upstream branches.

set -e

remote=`git remote -v | grep "git@github.com:OSGeo/"`
upstream=`echo $remote | sed 's/ .*//'`
repo=`echo $remote | sed 's#^.*OSGeo/\|\.git .*##g'`

if [ $repo = "grass" ]; then
	branch=main
elif [ $repo = "grass-addons" ]; then
	branch=grass8
else
	exit 1
fi

git fetch --all --prune
git checkout $branch
git rebase $upstream/$branch
