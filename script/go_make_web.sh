#!/bin/sh
. "$(dirname $0)/env.sh"
cd "$GO_PROJECT_PATH"
make web
cp -f ../prebuild/Web/* ../example/web
cp -f ../prebuild/Web/* "$ROOT"/web
