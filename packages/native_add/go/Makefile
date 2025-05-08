# 检测操作系统类型
ifeq ($(OS),Windows_NT)
	# Windows
	ANDROID_HOME ?= $(LOCALAPPDATA)/Android/Sdk
	NDK_PLATFORM := windows-x86_64
else
	# Unix-like (Linux/macOS)
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		ANDROID_HOME ?= $(HOME)/Android/Sdk
		NDK_PLATFORM := linux-x86_64
	else ifeq ($(UNAME_S),Darwin)  # macOS
		ANDROID_HOME ?= $(HOME)/Library/Android/sdk
		NDK_PLATFORM := darwin-x86_64
	else
		$(error Unsupported OS: $(UNAME_S))
	endif
endif

NDK_VERSION ?= 27.2.12479018
NDK_BIN ?= $(ANDROID_HOME)/ndk/$(NDK_VERSION)/toolchains/llvm/prebuilt/$(NDK_PLATFORM)/bin

# 根据目标名称设置平台路径
LIB_PREFIX = lib
ifeq ($(findstring ios,$(MAKECMDGOALS)),ios)
	PLATFORM = iOS
else ifeq ($(findstring android,$(MAKECMDGOALS)),android)
	PLATFORM = Android
else ifeq ($(findstring macos,$(MAKECMDGOALS)),macos)
	PLATFORM = macOS
else ifeq ($(MAKECMDGOALS),windows)
	PLATFORM = Windows
	LIB_PREFIX :=
else ifeq ($(MAKECMDGOALS),linux)
	PLATFORM = Linux
else ifeq ($(MAKECMDGOALS),web)
	PLATFORM = Web
else
	PLATFORM = $(MAKECMDGOALS)
endif
PREBUILD_PATH = ../prebuild/$(PLATFORM)
LIB_NAME := $(LIB_PREFIX)native_add

android-armv7a: CURRENT_ARCH := armeabi-v7a
android-armv7a:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm \
	GOARM=7 \
	CC=$(NDK_BIN)/armv7a-linux-androideabi21-clang \
	go build -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-arm64: CURRENT_ARCH := arm64-v8a
android-arm64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm64 \
	CC=$(NDK_BIN)/aarch64-linux-android21-clang \
	go build -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-x86: CURRENT_ARCH := x86
android-x86:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=386 \
	CC=$(NDK_BIN)/i686-linux-android21-clang \
	go build -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-x86_64: CURRENT_ARCH := x86_64
android-x86_64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=amd64 \
	CC=$(NDK_BIN)/x86_64-linux-android21-clang \
	go build -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android: android-armv7a android-arm64 android-x86 android-x86_64

ios-x86_64-sim:
	GOARCH=amd64 \
	SDK=iphonesimulator \
	LIB_NAME=${LIB_NAME} \
	PREBUILD_PATH=${PREBUILD_PATH} \
	./build_ios.sh

ios-arm64-sim:
	GOARCH=arm64 \
	SDK=iphonesimulator \
	LIB_NAME=${LIB_NAME} \
	PREBUILD_PATH=${PREBUILD_PATH} \
	./build_ios.sh

ios-arm64:
	GOARCH=arm64 \
	SDK=iphoneos \
	LIB_NAME=${LIB_NAME} \
	PREBUILD_PATH=${PREBUILD_PATH} \
	./build_ios.sh

ios: ios-x86_64-sim ios-arm64-sim ios-arm64

macos-arm64:
	GOARCH=arm64 \
	LIB_NAME=${LIB_NAME} \
	PREBUILD_PATH=${PREBUILD_PATH} \
	./build_mac.sh

macos-amd64:
	GOARCH=amd64 \
	LIB_NAME=${LIB_NAME} \
	PREBUILD_PATH=${PREBUILD_PATH} \
	./build_mac.sh

macos-universal: macos-arm64 macos-amd64
	mkdir -p $(PREBUILD_PATH)/universal/
	lipo \
		-create \
		$(PREBUILD_PATH)/arm64/$(LIB_NAME).a \
		$(PREBUILD_PATH)/x86_64/$(LIB_NAME).a \
		-output $(PREBUILD_PATH)/universal/$(LIB_NAME).a
	rm $(PREBUILD_PATH)/arm64/$(LIB_NAME).a
	rm $(PREBUILD_PATH)/x86_64/$(LIB_NAME).a

macos: macos-arm64 macos-amd64

windows:
	CGO_ENABLED=1 \
	GOOS=windows \
	GOARCH=amd64 \
	go build -trimpath -buildmode=c-shared -o ${PREBUILD_PATH}/AMD64/${LIB_NAME}.dll .
	rm ${PREBUILD_PATH}/AMD64/${LIB_NAME}.h

linux:
	CGO_ENABLED=1 \
	GOOS=linux \
	GOARCH=amd64 \
	go build -trimpath -buildmode=c-shared -o ${PREBUILD_PATH}/x86_64/${LIB_NAME}.so .
	rm ${PREBUILD_PATH}/x86_64/${LIB_NAME}.h

web:
	GOOS=js \
	GOARCH=wasm \
	go build -o ${PREBUILD_PATH}/${LIB_NAME}.wasm .
	cp "$(shell go env GOROOT)/lib/wasm/wasm_exec.js" ${PREBUILD_PATH}/
