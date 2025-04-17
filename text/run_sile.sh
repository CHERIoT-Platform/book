#!/usr/bin/env bash

SILE_FLAGS=""

# SILE 0.5.11 and later broke compatibility with resilient via the silex
# dependency.  We need this hack until resilient is fixed.
if [ $(sile --version | cut -f 2 -d ' '  | cut -f 3 -d . -) -gt 10 ] ; then
	SILE_FLAGS='-e require("hack1512")'
fi

# This sets LUA_PATH and LUA_CPATH...
eval $(luarocks --lua-version 5.1 --tree lua_modules path)
# ...but SILE needs this to include ;; to preserve existing paths!
export LUA_PATH="${LUA_PATH};;"
export LUA_CPATH="${LUA_CPATH};;"

# Run SILE once
echo sile $SILE_FLAGS $@ 
sile $SILE_FLAGS $@ 2>&1 | tee $1.sile.log
while grep 'please rerun SILE' $1.sile.log ; do
	sile $SILE_FLAGS $@ 2>&1 | tee $1.sile.log
done

# Clean up
rm $1.sile.log
exit 0
