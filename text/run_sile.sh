#!/bin/sh

sile $@ 2>&1 | tee sile.log
grep 'please rerun SILE' sile.log && sile $@
exit 0
