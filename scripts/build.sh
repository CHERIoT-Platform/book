#!/bin/sh

# Generate the PDF.
podman run --mount type=bind,src=$(realpath $(dirname $0)/..),target=/mnt --rm ghcr.io/cheriot-platform/book-build-container:main sh -c 'cd /mnt && asciidoxy --spec-file packages.toml --base-dir text text/index.adoc -D _site --build-dir build  -b pdf -r asciidoctor-pdf --template-dir templates && mv _site/index.pdf _site/cheriot-programmers-guide.pdf'

# Export as plain AsciiDoc (not AsciiDoxy)
podman run --mount type=bind,src=$(realpath $(dirname $0)/..),target=/mnt --rm ghcr.io/cheriot-platform/book-build-container:main sh -c 'cd /mnt && asciidoxy --spec-file packages.toml --base-dir text text/index.adoc -D build --build-dir build --template-dir templates -b adoc'
# Use asciidoctor-multipage to generate the HTML.
podman run --mount type=bind,src=$(realpath $(dirname $0)/..),target=/mnt --rm ghcr.io/cheriot-platform/book-build-container:main sh -c 'cd /mnt/ && asciidoctor-multipage -D _site build/index.adoc'
