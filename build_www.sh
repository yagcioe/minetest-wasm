#!/bin/bash -eux

source common.sh

# Generate a random hash for this release
# This is used as a prefix for cache invalidation
SEEDFILE="/tmp/minetest_build_uuid_seed"
dd status=none if=/dev/urandom bs=64 count=1 > "$SEEDFILE"
md5sum -b "$SEEDFILE" > "$SEEDFILE".hash
RELEASE_UUID=`cut -b -12 "$SEEDFILE".hash`
# Clean up temp files
rm "$SEEDFILE" "$SEEDFILE".hash


RELEASE_DIR="$WWW_DIR/$RELEASE_UUID"
PACKS_DIR="$RELEASE_DIR/packs"

echo "Installing release $RELEASE_UUID into www/"
rm -rf "$WWW_DIR"
mkdir "$WWW_DIR"
mkdir "$RELEASE_DIR"
mkdir "$PACKS_DIR"

# Copy emscripten generated files
pushd "$BUILD_DIR/minetest/src"
EMSCRIPTEN_FILES="minetest.js minetest.wasm minetest.worker.js"
for I in $EMSCRIPTEN_FILES; do
  cp "$I" "$RELEASE_DIR"
done

# Ideally this would be in RELEASE_DIR, but the way this file
# is located (see emcc --source-map-base) apparently cannot be
# relative to the .wasm file.
if [ -f minetest.wasm.map ]; then
  cp minetest.wasm.map "$WWW_DIR"
fi

popd

apply_substitutions() {
    local srcfile="$1"
    local dstfile="$2"
    sed "s/%__RELEASE_UUID__%/$RELEASE_UUID/g" "$srcfile" > "$dstfile"
}

# Copy static files, replacing $RELEASE_UUID with the id
pushd "$BASE_DIR/static"
apply_substitutions htaccess_toplevel   "$WWW_DIR"/.htaccess
apply_substitutions index.html  "$WWW_DIR"/index.html
apply_substitutions htaccess_release "$RELEASE_DIR"/.htaccess
apply_substitutions launcher.js "$RELEASE_DIR"/launcher.js
apply_substitutions htaccess_packs "$PACKS_DIR"/.htaccess
apply_substitutions staticwebapp.config.json "$WWW_DIR"/staticwebapp.config.json
popd

# Copy base file system pack
cp "$BUILD_DIR/fsroot.tar.zst" "$PACKS_DIR/base.pack"

echo "DONE"

# Optional script to customize deployment
# Use this to add extra data packs, deploy to webserver, etc
if [ -f deploy.sh ]; then
  ./deploy.sh "$RELEASE_UUID"
fi
