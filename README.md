# Relationship Works Workshops Site

Parent repository for RG workshops

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

