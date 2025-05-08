LIB_NAME=native_add

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
