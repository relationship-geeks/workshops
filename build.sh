#!/usr/bin/env bash

set -ex

URL="${1?Missing parameter: URL}"

DIR="$(cd "$0"; pwd)"

#git submodule update --init --recursive

rm -rf "content/archive"
mkdir -p "content/archive"
for archive in archive/*
do
  rm -rf "public/${archive}"
  echo "+++
title = '$(basename "${archive}")'
date = '$(git log -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%dT%H:%M:%S+00:00)'
type = 'archive'
+++

stub" > "content/${archive}.md"
done

hugo --minify -b "$URL"

for archive in archive/*
do
  "$archive/build.sh" "${URL}/${archive}"
  mkdir -p "public/${archive}"
  rm -rf "public/${archive}"
  cp -r "${archive}/public" "public/${archive}"
done


