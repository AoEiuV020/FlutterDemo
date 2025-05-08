#!/bin/sh
export GOOS=darwin
export CGO_ENABLED=1
export SDK=macos

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
fi

go build -trimpath -buildmode=c-archive -o $PREBUILD_PATH/$CARCH/${LIB_NAME}.a .
rm $PREBUILD_PATH/$CARCH/${LIB_NAME}.h
