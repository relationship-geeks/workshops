#!/usr/bin/env bash

set -ex

if [[ " $* " =~ " "(--help|-h)" " ]]
then
  echo "archive_congress.sh [OPTIONS] congress_id
  
  OPTIONS
    -h, --help    Print this message and exit
    --gh-auth-ssh Use ssh for pushing to github (will not affect existing/permanent remotes or submodules)
"
  exit 0
fi

cd "$(dirname "${0}")" || { echo 'Failed to change dir' >&2; exit 1; }

CONGRESS_ID="${1?ERR: Missing parameter: congress_id}"

if [[ -e "archive/${CONGRESS_ID}" ]]
then
  echo "ERR: A file or directory 'archive/${CONGRESS_ID}' already exists. Aborting..." >&2
  exit 1
fi

remote_name="gh-tmp-$(base64 < /dev/urandom | tr -d '=+' | head -c 8)"
branch="congress/${CONGRESS_ID}"

remote_url_http="https://github.com/relationship-geeks/workshops.git"
remote_url_ssh="git@github.com:relationship-geeks/workshops.git"
remote_url="$remote_url_http"

if [[ " $* " =~ " --gh-auth-ssh " ]]
then
  remote_url="$remote_url_ssh"
fi

trap 'set +e; git checkout main; git remote remove "$remote_name"; git branch -D "$branch"' EXIT

git checkout -b "$branch"

git remote add "$remote_name" "$remote_url"

git push "$remote_name" "$branch"

trap 'set +e; git checkout main; git remote remove "$remote_name"' EXIT

git checkout main

git submodule add -b "$branch" "$remote_url_http" "archive/${CONGRESS_ID}"

git rm -r "content/workshops"

trap 'set +e; git checkout main; git remote remove "$remote_name"; test -e "archive/${CONGRESS_ID}" || { git rm "archive/${CONGRESS_ID}"; rm -rf ".git/modules/archive/${CONGRESS_ID}"; }' EXIT

git commit -m "Archive congress '${CONGRESS_ID}'" ".gitmodules" "archive/${CONGRESS_ID}"

echo "Congress branch 'congress/${CONGRESS_ID}' has been created and added to archive"

set +e
git remote remove "$remote_name"

trap '' EXIT

