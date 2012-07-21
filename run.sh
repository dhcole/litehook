#!/bin/bash

# Checkout specific SHA from git, run jekyll, sync to s3
# TODO: handle branches, sync to new bucket, handle simultaneous runs
# usage `run.sh user repos sha`

USER=$1
REPOS=$2
SHA=$3

# 1. Check to see if repos is already downloaded
if [ ! -d "_repos/$USER.$REPOS" ]; then
    git clone git@github.com:$USER/$REPOS.git "_repos/$USER.$REPOS"
fi

# 2. Pull new commit from github
cd "_repos/$USER.$REPOS"
git pull
git checkout $SHA
cd -

# 3. Run Jekyll or move static files

if [ -f "_repos/$USER.$REPOS/_config.yml" ]; then
    jekyll "_repos/$USER.$REPOS" "_sites/$USER.$REPOS" --no-auto --no-server
else
    rm -rf "_sites/$USER.$REPOS"
    mkdir "_sites/$USER.$REPOS"
    cp -r "_repos/$USER.$REPOS" "_sites/"
fi

# 4. Sync to s3
s3cmd sync --delete-removed --exclude ".git/*" --exclude ".gitignore" "_sites/$USER.$REPOS/" "s3://static.dhcole.com/$USER.$REPOS/"
