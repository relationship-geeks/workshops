#!/usr/bin/env bash

set -e

if [[ " $* " =~ " "(--help|-h)" " ]]
then
  echo "build.sh [OPTIONS] [HUGO_OPTIONS]
  
  Builds main site and archives

  OPTIONS
    -h, --help Show this message
    -w, --watch Continously watch for file changes and rebuild
  
  HUGO_OPTIONS
    any other options are passed to hugo when building main site or archive sites"
  exit 0
fi

URL="${1?Missing parameter: URL}"
shift

watch=f
hugo_args=()
for arg in "$@"
do
  if [[ "$arg" =~ ^(-w|--watch)$ ]]
  then
    if [[ -z "$(type -t inotifywait)" ]]
    then
      echo "WARN: Cannot enable --watch: inotifywait command not found (hint: install inotify-tools)" >&2
    else
      watch=t
    fi
  else
    hugo_args+=("$arg")
  fi
done

cd "$(dirname "${0}")" || { echo 'Failed to change dir' >&2; exit 1; }
#git submodule update --init --recursive

rm -rf "content/archive"
mkdir -p "content/archive"
for archive in archive/*
do
  rm -rf "public/${archive}"
  echo "+++
title = '$(basename "${archive}")'
date = '$(git log -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%dT%H:%M:%S"$(date +%z)")'
type = 'archive'
+++

stub" > "content/${archive}.md"
done

first=f
watch_cond() {
  if [[ "$first" == f ]]
  then
    first=t
    return 0
  fi

  if [[ "$watch" == "t" ]]
  then
    inotifywait -r . -e modify -e attrib -e close_write -e move -e create -e delete -e unmount \
      --exclude '^./(.git|.idea|public)$'
  else
    return 1
  fi
}

while watch_cond
do

  hugo -b "$URL" "${hugo_args[@]}" || echo "WARN: hugo did not build successfully" >&2

  for archive in archive/*
  do
    {
      "$archive/build.sh" "${URL}/${archive}" "${hugo_args[@]}"
      mkdir -p "public/${archive}"
      rm -rf "public/${archive}"
      cp -r "${archive}/public" "public/${archive}"
    } || echo "WARN: '${archive}' did not build successfully" >&2
  done

done

