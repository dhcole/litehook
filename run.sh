#!/bin/bash
set -e 

# Checkout specific SHA from git, run jekyll, sync to s3
# TODO: handle branches, handle simultaneous runs
# usage `run.sh user repos sha`

USER=$1
REPOS=$2
SHA=$3
EMAIL=$4

# 1. Check to see if repos is already downloaded

if [ ! -d "_repos/$USER.$REPOS" ]; then
    git clone git@github.com:$USER/$REPOS.git "_repos/$USER.$REPOS"
fi

# 2. Pull new commit from github
# TODO: IF repos name *.github.com, use master

cd "_repos/$USER.$REPOS"
if [[ "$REPOS" = *".github.com" ]]; then
    git checkout master
    git pull origin master
else
    git checkout gh-pages
    git pull origin gh-pages
fi
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

if [ -f "_repos/$USER.$REPOS/CNAME" ]; then
    BUCKET="`cat _repos/$USER.$REPOS/CNAME`.dhcole.com"
    PREFIX=""
else
    BUCKET="$USER.dhcole.com"
    PREFIX="$REPOS/"
fi

echo "bucket: $BUCKET \nprefix: $PREFIX"

# TODO: read CNAME, use that as bucket name, if *.github.com, use root, don't delete other repos; if errors, dont create new bucket (obviated by CNAME); don't create bucket if clone failed.

s3cmd mb "s3://$BUCKET"
s3cmd sync --delete-removed --exclude ".git/*" --exclude ".gitignore" "_sites/$USER.$REPOS/" "s3://$BUCKET/$PREFIX"

# Send mail
sendmail $EMAIL "to: $EMAIL\nfrom: no-reply@dhcole.com\nsubject: Successfully built your site\n\nView it here: http://$USER.dhcole.com/$REPOS/\n\n"
