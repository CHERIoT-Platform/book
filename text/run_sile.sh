#!/bin/sh

# This sets LUA_PATH and LUA_CPATH...
eval $(luarocks --lua-version 5.1 --tree lua_modules path)
# ...but SILE needs this to include ;; to preserve existing paths!
export LUA_PATH="${LUA_PATH};;"
export LUA_CPATH="${LUA_CPATH};;"

# Run SILE once
sile $@ 2>&1 | tee $1.sile.log
while grep 'please rerun SILE' $1.sile.log ; do
	sile $@ 2>&1 | tee $1.sile.log
done

# Clean up
rm $1.sile.log
exit 0
