LIB_NAME=native_add
PREBUILD_PATH=../prebuild

ios-x86_64-sim:
	GOARCH=amd64 \
	SDK=iphonesimulator \
	LIB_NAME=lib${LIB_NAME} \
	./build_ios.sh

ios-arm64-sim:
	GOARCH=arm64 \
	SDK=iphonesimulator \
	LIB_NAME=lib${LIB_NAME} \
	./build_ios.sh

ios-arm64:
	GOARCH=arm64 \
	SDK=iphoneos \
	LIB_NAME=lib${LIB_NAME} \
	./build_ios.sh

ios: ios-x86_64-sim ios-arm64-sim ios-arm64
	lipo \
    -create \
    lib${LIB_NAME}_arm64_iphonesimulator.a \
    lib${LIB_NAME}_amd64_iphonesimulator.a \
    -output lib${LIB_NAME}_iphonesimulator.a
	rm lib${LIB_NAME}_arm64_iphonesimulator.*
	rm lib${LIB_NAME}_amd64_iphonesimulator.*

	mkdir -p ios-arm64
	mkdir -p ios-simulator
	mv ./lib${LIB_NAME}_arm64_iphoneos.a ./ios-arm64/lib${LIB_NAME}.a
	cp ./lib${LIB_NAME}_arm64_iphoneos.h ./ios-arm64/lib${LIB_NAME}.h
	mv ./lib${LIB_NAME}_iphonesimulator.a ./ios-simulator/lib${LIB_NAME}.a
	mv ./lib${LIB_NAME}_arm64_iphoneos.h ./ios-simulator/lib${LIB_NAME}.h

	xcodebuild -create-xcframework \
			-output lib${LIB_NAME}.xcframework \
			-library ios-arm64/lib${LIB_NAME}.a \
			-headers ios-arm64/lib${LIB_NAME}.h \
			-library ios-simulator/lib${LIB_NAME}.a \
			-headers ios-simulator/lib${LIB_NAME}.h
	rm -rf ios-arm64
	rm -rf ios-arm64-simulator
	rm -rf ios-simulator
	rm -rf ../ios/lib${LIB_NAME}.xcframework
	mv lib${LIB_NAME}.xcframework ../ios/

macos:
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=arm64 \
	SDK=macos \
	go build -trimpath -buildmode=c-shared -o lib${LIB_NAME}_arm64.dylib .
	CGO_ENABLED=1 \
	GOOS=darwin \
	GOARCH=amd64 \
	SDK=macos \
	go build -trimpath -buildmode=c-shared -o lib${LIB_NAME}_amd64.dylib .
	lipo \
		-create \
		lib${LIB_NAME}_arm64.dylib \
		lib${LIB_NAME}_amd64.dylib \
		-output lib${LIB_NAME}.dylib
	install_name_tool -id "@rpath/lib${LIB_NAME}.dylib" lib${LIB_NAME}.dylib
	mv lib${LIB_NAME}.dylib ../macos/lib${LIB_NAME}.dylib
	rm lib${LIB_NAME}_*.h
	rm lib${LIB_NAME}_*.dylib

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
	go build -trimpath -buildmode=c-shared -o ${PREBUILD_PATH}/Linux/x86_64/lib${LIB_NAME}.so .
	rm ${PREBUILD_PATH}/Linux/x86_64/lib${LIB_NAME}.h
