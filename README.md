# Relationship Geeks Workshops Site

## Concept

This repository contains resources for workshops offered by the relationship geeks group on current and past events.
The site for the currently ongoing event can be found in the main branch.
After the event is over, the main branch will be archived into a `congress/*` branch, stripped from workshop notes and the new `congress/*` branch will be added to the archive/ directory as submodule.
This is automated with the script `./archive_congress.sh`.

The main branch is used for building all sites, including submodules and merging them into a single site with archive sub-sites that is then published via github pages under https://workshop.relationship-geeks.de.

## Workflow

### Before the event

- Adjust the theme, CSS, colors, etc. as desired
- Adjust everything in layouts/* (if the theme has been changed, it will likely be necessary to recreate all files in layouts/* from whatever is provided by the theme)
  - Notably, adjust the welcome message in layouts/index.html
- Adjust hugo.toml (e.g. change '3*c3' to whatever the name of the current event is)
- Add workshop notes under `./content/workshops`

### After the event

- Archive the event with `./archive_congress.sh <event-id>` and push
- Strip hugo.toml from references to the specific event

### TODO: Archive upstream projects (especially themes, see `hugo mod vendor`) to ensure archived sites to remain buildable

## Build & Development

Checkout the repository locally

```sh
git clone --recurse-submodules https://github.com/relationship-geeks/workshops && cd workshops
```

The easiest way to develop locally is building the page and running a local webserver on the output directory:
Run the provided build script. This builds the repo and merges the archive repos into the output site.

```sh
mkdir -p public
# Run a local webserver
docker run --rm -p -p 127.0.0.1:8080:80 -v "$PWD/public:/usr/local/apache2/htdocs/" httpd
# Build (and watch) the repo
./build.sh http://localhost:8080
```

Then open the site in your browser at http://localhost:8080

## Helper Scripts

### build.sh

```sh
build.sh [OPTIONS] [HUGO_OPTIONS]
  
  Builds main site and archives

  OPTIONS
    -h, --help Show this message
    -w, --watch Continously watch for file changes and rebuild
  
  HUGO_OPTIONS
    any other options are passed to hugo when building main site or archive sites
```

### archive_congress.sh

```sh
archive_congress.sh [OPTIONS] congress_id

  Archives current event site and resets workshops
  
  OPTIONS
    -h, --help    Print this message and exit
    --gh-auth-ssh Use ssh for pushing to github (will not affect existing/permanent remotes or submodules)
```
