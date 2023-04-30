#!/bin/bash -eux

source common.sh

RELEASE_UUID=$1

RELEASE_DIR="$WWW_DIR/$RELEASE_UUID"
PACKS_DIR="$RELEASE_DIR/packs"


function buildPacks() {
  pushd "$SOURCES_DIR/packs"

  for pack in ./*; do
    pushd $pack
        
    pack_name=$(basename $pack)

    if [ -d minetest/games ]; then
        if [ -d minetest/worlds ]; then
            tar -cf "$pack_name.tzst" minetest/games minetest/worlds --use-compress-program=zstd
        else
            tar -cf "$pack_name.tzst" minetest/games --use-compress-program=zstd
        fi
        #tar -xf "$packname.tzst" --use-compress-program=unzstd # to unpack
        mv "$pack_name.tzst" $PACKS_DIR/$pack_name.pack
    fi

    popd
  done

  popd

}

if [ ! -d "$SOURCES_DIR/packs" ]; then
    mkdir "$SOURCES_DIR/packs"
fi


getrepo packs/minetest_survey https://github.com/yagcioe/minetest-survey.git

buildPacks