#!/bin/bash
set -e
script_dir=$(cd $(dirname $0);pwd)
EMBED_TEST_DIR=$script_dir
ROOT_DIR=$EMBED_TEST_DIR/..
cd $ROOT_DIR
flutter build linux
cd $EMBED_TEST_DIR
mkdir -p build
cd build
cmake ..
make
rm inner
ln -sf $ROOT_DIR/build/linux/x64/release/bundle/demo inner
./wrapper
