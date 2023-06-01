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
    pathsToArchive=''
    if [ -d minetest/games ]; then
      pathsToArchive+="minetest/games "
    fi
    if [ -d minetest/worlds ]; then
      pathsToArchive+="minetest/worlds "
    fi
    if [ -f minetest/builtin/game/chat.lua ]; then
      pathsToArchive+="minetest/builtin/game/chat.lua "
    fi
    if [ -f minetest/builtin/game/item.lua ]; then
      pathsToArchive+="minetest/builtin/game/item.lua "
    fi
      if [ -f minetest/minetest.prod.conf ]; then
      mv -f ~/minetest/minetest.prod.conf ~/minetest/minetest.conf
      pathsToArchive+="minetest/minetest.conf "
    fi

    if [ ! -z "$pathsToArchive" ]; then
      echo add pack
      tar -cf "$pack_name.tzst" $pathsToArchive --use-compress-program=zstd
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