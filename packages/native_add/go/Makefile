ANDROID_OUT=$(PREBUILD_PATH)/Android
NDK_BIN=$(ANDROID_HOME)/ndk/27.2.12479018/toolchains/llvm/prebuilt/darwin-x86_64/bin

PREBUILD_PATH = ../prebuild

# 默认 prefix 是 lib
prefix = lib
# 目标特定的变量：仅在 windows 任务中覆盖 prefix
windows: prefix =

LIB_NAME = $(prefix)native_add

android-armv7a:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm \
	GOARM=7 \
	CC=$(NDK_BIN)/armv7a-linux-androideabi21-clang \
	go build -buildmode=c-shared -o $(ANDROID_OUT)/armeabi-v7a/${LIB_NAME}.so .
	rm ${ANDROID_OUT}/armeabi-v7a/${LIB_NAME}.h

android-arm64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm64 \
	CC=$(NDK_BIN)/aarch64-linux-android21-clang \
	go build -buildmode=c-shared -o $(ANDROID_OUT)/arm64-v8a/${LIB_NAME}.so .
	rm ${ANDROID_OUT}/arm64-v8a/${LIB_NAME}.h

android-x86:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=386 \
	CC=$(NDK_BIN)/i686-linux-android21-clang \
	go build -buildmode=c-shared -o $(ANDROID_OUT)/x86/${LIB_NAME}.so .
	rm ${ANDROID_OUT}/x86/${LIB_NAME}.h

android-x86_64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=amd64 \
	CC=$(NDK_BIN)/x86_64-linux-android21-clang \
	go build -buildmode=c-shared -o $(ANDROID_OUT)/x86_64/${LIB_NAME}.so .
	rm ${ANDROID_OUT}/x86_64/${LIB_NAME}.h

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
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=arm64 \
	SDK=macos \
	go build -trimpath -buildmode=c-archive -o $(PREBUILD_PATH)/macOS/arm64/$(LIB_NAME).a .
	rm $(PREBUILD_PATH)/macOS/arm64/$(LIB_NAME).h

macos-amd64:
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=amd64 \
	SDK=macos \
	go build -trimpath -buildmode=c-archive -o $(PREBUILD_PATH)/macOS/x86_64/$(LIB_NAME).a .
	rm $(PREBUILD_PATH)/macOS/x86_64/$(LIB_NAME).h

macos-universal: macos-arm64 macos-amd64
	mkdir -p $(PREBUILD_PATH)/macOS/universal/
	lipo \
		-create \
		$(PREBUILD_PATH)/macOS/arm64/$(LIB_NAME).a \
		$(PREBUILD_PATH)/macOS/x86_64/$(LIB_NAME).a \
		-output $(PREBUILD_PATH)/macOS/universal/$(LIB_NAME).a
	rm $(PREBUILD_PATH)/macOS/arm64/$(LIB_NAME).a
	rm $(PREBUILD_PATH)/macOS/x86_64/$(LIB_NAME).a

macos: macos-arm64 macos-amd64

windows:
	CGO_ENABLED=1 \
	GOOS=windows \
	GOARCH=amd64 \
	go build -trimpath -buildmode=c-shared -o ${PREBUILD_PATH}/Windows/AMD64/${LIB_NAME}.dll .
	rm ${PREBUILD_PATH}/Windows/AMD64/${LIB_NAME}.h

linux:
	CGO_ENABLED=1 \
	GOOS=linux \
	GOARCH=amd64 \
	go build -trimpath -buildmode=c-shared -o ${PREBUILD_PATH}/Linux/x86_64/${LIB_NAME}.so .
	rm ${PREBUILD_PATH}/Linux/x86_64/${LIB_NAME}.h
