# 默认 prefix 是 lib
prefix = lib
# 目标特定的变量：仅在 windows 任务中覆盖 prefix
windows: prefix =

LIB_NAME = $(prefix)native_add
PREBUILD_PATH = ../prebuild

# 其他任务默认使用 prefix=lib
ios-x86_64-sim:
	GOARCH=amd64 \
	SDK=iphonesimulator \
	LIB_NAME=${LIB_NAME} \
	./build_ios.sh

ios-arm64-sim:
	GOARCH=arm64 \
	SDK=iphonesimulator \
	LIB_NAME=${LIB_NAME} \
	./build_ios.sh

ios-arm64:
	GOARCH=arm64 \
	SDK=iphoneos \
	LIB_NAME=${LIB_NAME} \
	./build_ios.sh

ios: ios-x86_64-sim ios-arm64-sim ios-arm64

macos:
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=arm64 \
	SDK=macos \
	go build -trimpath -buildmode=c-shared -o $(LIB_NAME)_arm64.dylib .
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=amd64 \
	SDK=macos \
	go build -trimpath -buildmode=c-shared -o $(LIB_NAME)_amd64.dylib .
	lipo \
		-create \
		$(LIB_NAME)_arm64.dylib \
		$(LIB_NAME)_amd64.dylib \
		-output $(LIB_NAME).dylib
	install_name_tool -id "@rpath/$(LIB_NAME).dylib" $(LIB_NAME).dylib
	mv $(LIB_NAME).dylib ../macos/$(LIB_NAME).dylib
	rm $(LIB_NAME)_*.h
	rm $(LIB_NAME)_*.dylib

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
