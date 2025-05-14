PROJECT_NAME := native_add
PREBUILD_BASE := ../prebuild

# 构建模式设置，默认为release模式
BUILD_MODE ?= release

# 根据构建模式设置Go构建参数
ifeq ($(BUILD_MODE),debug)
	# Debug模式：保留调试信息
	GO_BUILD_FLAGS := -gcflags="all=-N -l"
else
	# Release模式：优化体积
	GO_BUILD_FLAGS := -trimpath -ldflags="-s -w" 
endif

NDK_VERSION ?= 27.0.12077973
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
	endif
endif

NDK_BIN ?= $(subst \,/,$(ANDROID_HOME))/ndk/$(NDK_VERSION)/toolchains/llvm/prebuilt/$(NDK_PLATFORM)/bin
# 使用通用的 wildcard 函数检查 NDK_BIN 是否存在
NDK_EXISTS := $(if $(wildcard $(NDK_BIN)),true,false)

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
else ifeq ($(MAKECMDGOALS),all)
	# 设置默认平台，将在 all 目标中处理
else ifeq ($(MAKECMDGOALS),)
	# 如果没有指定目标，也使用默认平台
else
	PLATFORM = $(MAKECMDGOALS)
endif
PREBUILD_PATH = $(PREBUILD_BASE)/$(PLATFORM)
LIB_NAME := $(LIB_PREFIX)$(PROJECT_NAME)

export PREBUILD_PATH
export LIB_NAME
export GO_BUILD_FLAGS
export BUILD_MODE
export PROJECT_NAME

# 添加默认目标，根据系统类型自动选择目标
.PHONY: release
all:
ifeq ($(OS),Windows_NT)
	$(MAKE) windows
else ifeq ($(UNAME_S),Linux)
	$(MAKE) linux
else ifeq ($(UNAME_S),Darwin)  # macOS
	$(MAKE) macos
	# 在macOS上追加执行ios任务
	$(MAKE) ios
else
	$(error Unsupported OS for default build: $(UNAME_S))
endif
	# 如果NDK存在，追加执行android任务（所有平台通用）
	@if [ "$(NDK_EXISTS)" = "true" ]; then \
		$(MAKE) android; \
	fi
	# 追加执行web任务（所有平台通用）
	$(MAKE) web

# 添加debug目标
debug:
	$(MAKE) BUILD_MODE=debug all

# 添加release目标
release:
	$(MAKE) BUILD_MODE=release all

# 设置 all 为默认目标
.DEFAULT_GOAL := all

android-armv7a: CURRENT_ARCH := armeabi-v7a
android-armv7a:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm \
	GOARM=7 \
	CC=$(NDK_BIN)/armv7a-linux-androideabi21-clang \
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-arm64: CURRENT_ARCH := arm64-v8a
android-arm64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm64 \
	CC=$(NDK_BIN)/aarch64-linux-android21-clang \
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-x86: CURRENT_ARCH := x86
android-x86:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=386 \
	CC=$(NDK_BIN)/i686-linux-android21-clang \
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android-x86_64: CURRENT_ARCH := x86_64
android-x86_64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=amd64 \
	CC=$(NDK_BIN)/x86_64-linux-android21-clang \
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.so .
	rm $(PREBUILD_PATH)/$(CURRENT_ARCH)/${LIB_NAME}.h

android: android-armv7a android-arm64 android-x86 android-x86_64

ios-x86_64-sim:
	GOARCH=amd64 \
	SDK=iphonesimulator \
	./build_ios.sh

ios-arm64-sim:
	GOARCH=arm64 \
	SDK=iphonesimulator \
	./build_ios.sh

ios-arm64:
	GOARCH=arm64 \
	SDK=iphoneos \
	./build_ios.sh

ios: ios-x86_64-sim ios-arm64-sim ios-arm64

macos-arm64:
	GOARCH=arm64 \
	./build_mac.sh

macos-amd64:
	GOARCH=amd64 \
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
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o ${PREBUILD_PATH}/AMD64/${LIB_NAME}.dll .
	rm ${PREBUILD_PATH}/AMD64/${LIB_NAME}.h

linux:
	CGO_ENABLED=1 \
	GOOS=linux \
	GOARCH=amd64 \
	go build $(GO_BUILD_FLAGS) -buildmode=c-shared -o ${PREBUILD_PATH}/x86_64/${LIB_NAME}.so .
	rm ${PREBUILD_PATH}/x86_64/${LIB_NAME}.h

web:
	GOOS=js \
	GOARCH=wasm \
	go build $(GO_BUILD_FLAGS) -o ${PREBUILD_PATH}/${LIB_NAME}.wasm .
	cp "$(shell go env GOROOT)/lib/wasm/wasm_exec.js" ${PREBUILD_PATH}/
