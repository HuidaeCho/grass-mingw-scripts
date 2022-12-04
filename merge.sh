#!/bin/sh
# This script merges upstream branches.

set -e

remote=`git remote -v | grep "git@github.com:OSGeo/"`
upstream=`echo $remote | sed 's/ .*//'`
repo=`echo $remote | sed 's#^.*OSGeo/\|\.git .*##g'`

case $repo in
grass-addons)
	branch=grass8
	;;
grass|gdal-grass)
	branch=main
	;;
*)
	echo "$repo: Unknown repository"
	exit 1
	;;
esac

git fetch --all --prune
git checkout $branch
git rebase $upstream/$branch
