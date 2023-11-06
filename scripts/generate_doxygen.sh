#!/bin/sh
podman run --mount type=bind,src=$(realpath $(dirname $0)/..),target=/mnt --rm ghcr.io/cheriot-platform/book-build-container bash -c 'cd /mnt/ && /doxygen/bin/doxygen'
