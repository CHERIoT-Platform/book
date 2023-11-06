#!/bin/sh
podman run --mount type=bind,src=$(realpath $(dirname $0)/..),target=/mnt --rm asciidoxy bash -c 'cd /mnt/ && /doxygen/bin/doxygen'
