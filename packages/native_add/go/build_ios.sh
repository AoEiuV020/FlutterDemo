#!/bin/sh
set -e
export GOOS=ios
export CGO_ENABLED=1
# export CGO_CFLAGS="-fembed-bitcode"
# export MIN_VERSION=15

SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path)

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
fi

if [ "$SDK" = "iphoneos" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION"
elif [ "$SDK" = "iphonesimulator" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION-simulator"
fi

CLANG=$(xcrun --sdk "$SDK" --find clang)
CC="$CLANG -target $TARGET -isysroot $SDK_PATH $@"
export CC

# 使用全局导出的GO_BUILD_FLAGS变量
eval go build $GO_BUILD_FLAGS -buildmode=c-archive -o $PREBUILD_PATH/$SDK/$CARCH/${LIB_NAME}.a
rm $PREBUILD_PATH/$SDK/$CARCH/${LIB_NAME}.h
