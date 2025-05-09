#!/bin/sh
export GOOS=darwin
export CGO_ENABLED=1
export SDK=macos
export MACOSX_DEPLOYMENT_TARGET=10.11 # 和.podspec 中的platform一致

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
fi

export CC="cc -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"

go build -trimpath -buildmode=c-archive -o $PREBUILD_PATH/$CARCH/${LIB_NAME}.a .
rm $PREBUILD_PATH/$CARCH/${LIB_NAME}.h
