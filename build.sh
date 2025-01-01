#!/usr/bin/env bash

cd "$(dirname "${0}")" || { echo 'Failed to change dir' >&2; exit 1; }
URL="${1?Missing parameter: URL}"

hugo --minify -b "$URL" --cleanDestinationDir -d public
