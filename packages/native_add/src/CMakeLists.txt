cmake_minimum_required(VERSION 3.14) # 建议升级，3.10 太老了
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

# 目标库名称
set(TARGET_NAME "native_add")

# 预编译库存放的根目录
set(PREBUILD_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/prebuild")

# 根据平台设置变量
set(IS_MACOS FALSE)
if(APPLE AND CMAKE_SYSTEM_NAME MATCHES "Darwin")
    # More specific check if you also plan to support iOS/tvOS/watchOS in this CMake file
    # if(APPLE AND NOT IOS AND NOT TVOS AND NOT WATCHOS)
    set(IS_MACOS TRUE)
    message(STATUS "Configuring for macOS")
endif()

# 设置平台和ABI相关的库路径
if(ANDROID)
    if(NOT CMAKE_ANDROID_ARCH_ABI)
        message(FATAL_ERROR "CMAKE_ANDROID_ARCH_ABI is not defined. Ensure you are using the Android NDK toolchain.")
    endif()
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Android/${CMAKE_ANDROID_ARCH_ABI}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
elseif(WIN32)
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Windows/${CMAKE_SYSTEM_PROCESSOR}") # e.g., AMD64, x86
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.dll")
    set(PREBUILD_IMPLIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.lib")
elseif(IS_MACOS)
    # For macOS, CMAKE_SYSTEM_PROCESSOR might not be set early by podspec.
    # CMAKE_OSX_ARCHITECTURES (e.g., "arm64;x86_64") will be set by the podspec.
    # We'll handle architecture variations in the prebuild check or assume universal binary for prebuilts.
    if(DEFINED CMAKE_OSX_ARCHITECTURES AND NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "")
        # If building for specific arch (e.g. "arm64" or "x86_64" - not a list "arm64;x86_64")
        # This gets complex if CMAKE_OSX_ARCHITECTURES is a list.
        # For prebuilts, it's easier to assume a universal prebuilt or one for CMAKE_HOST_SYSTEM_PROCESSOR
        # Or that the pod's s.prepare_command logic picks the right prebuilt.
        # For now, let's assume a prebuilt exists for CMAKE_HOST_SYSTEM_PROCESSOR if specific.
        # A better prebuilt strategy for macOS might involve checking for each arch in CMAKE_OSX_ARCHITECTURES.
        # For simplicity, we'll check a common path.
        set(PREBUILD_ARCH_DIR_PART "${CMAKE_SYSTEM_PROCESSOR}") # This will be set if podspec calls CMake for a single arch
                                                                # or CMAKE_HOST_SYSTEM_PROCESSOR if not specific
    else()
        set(PREBUILD_ARCH_DIR_PART "universal") # Fallback or convention
    endif()
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Darwin/${PREBUILD_ARCH_DIR_PART}")
    # MODIFIED: Expect .dylib for macOS prebuilt
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .dylib
elseif(UNIX AND NOT APPLE AND NOT ANDROID) # Linux
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Linux/${CMAKE_SYSTEM_PROCESSOR}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
else() # Other platforms or fallback
    message(WARNING "Platform detection fallback. Prebuilt logic might not be accurate.")
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

# 确保预编译库目标目录存在
file(MAKE_DIRECTORY "${PREBUILD_ABI_DIR}")

message(STATUS "Targeting System: ${CMAKE_SYSTEM_NAME}")
if(ANDROID)
    message(STATUS "Targeting ABI: ${CMAKE_ANDROID_ARCH_ABI}")
elseif(IS_MACOS)
    message(STATUS "Targeting macOS Architectures: ${CMAKE_OSX_ARCHITECTURES} (Host: ${CMAKE_HOST_SYSTEM_PROCESSOR})")
else()
    message(STATUS "Targeting Processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()
message(STATUS "Checking for prebuilt library at: ${PREBUILD_LIB_PATH}")
if(WIN32 AND EXISTS "${PREBUILD_LIB_PATH}")
    message(STATUS "Checking for Windows import library at: ${PREBUILD_IMPLIB_PATH}")
endif()

# 检查预编译库是否存在
if(EXISTS "${PREBUILD_LIB_PATH}" AND (NOT WIN32 OR EXISTS "${PREBUILD_IMPLIB_PATH}"))
    message(STATUS "Using prebuilt library: ${PREBUILD_LIB_PATH}")

    if(ANDROID)
        # Android prebuilt dummy lib approach (as in your original)
        if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")
            file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c" "void _dummy_native_add_function_() {} \n")
        endif()
        add_library(${TARGET_NAME} SHARED "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${PREBUILD_LIB_PATH}"
            "$<TARGET_FILE:${TARGET_NAME}>"
            COMMENT "Copying prebuilt Android library ${PREBUILD_LIB_PATH} to $<TARGET_FILE:${TARGET_NAME}>"
            VERBATIM
        )
    elseif(IS_MACOS)
        # MODIFIED: Import as SHARED for macOS .dylib
        add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)
        set_target_properties(${TARGET_NAME} PROPERTIES
            IMPORTED_LOCATION "${PREBUILD_LIB_PATH}"
        )
    else() # Windows and other platforms (e.g. Linux)
        add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL) # SHARED for others
        set_target_properties(${TARGET_NAME} PROPERTIES
            IMPORTED_LOCATION "${PREBUILD_LIB_PATH}"
        )
        if(WIN32)
            set_target_properties(${TARGET_NAME} PROPERTIES
                IMPORTED_IMPLIB "${PREBUILD_IMPLIB_PATH}"
            )
        endif()
    endif()

    set_target_properties(${TARGET_NAME} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}" # Assumes native_add.h is in src/
    )
    # DART_SHARED_LIB is a common convention for FFI visibility, adjust if your macro is different
    if(NOT ANDROID) # Android POST_BUILD copy means the dummy lib is the one getting compile defs
        target_compile_definitions(${TARGET_NAME} INTERFACE DART_SHARED_LIB)
    else()
        target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB)
    endif()

else()
    message(STATUS "Prebuilt library not found or incomplete. Building from source...")

    # Source files (assuming native_add.c and native_add.h)
    set(NATIVE_SOURCES "native_add.c")
    set(NATIVE_HEADERS "native_add.h") # Used for PUBLIC_HEADER

    if(IS_MACOS)
        # MODIFIED: Build as SHARED for macOS to produce .dylib
        add_library(${TARGET_NAME} SHARED ${NATIVE_SOURCES})
        # For macOS, ensure universal binaries if CMAKE_OSX_ARCHITECTURES specifies multiple
        # CMake + Xcode generator usually handles this automatically.
        # For SHARED libraries on macOS, POSITION_INDEPENDENT_CODE is implied or handled by default.
        # Explicitly setting it is not harmful.
        set_target_properties(${TARGET_NAME} PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            # It's good practice to set the install name for dylibs, especially if they might be moved
            # or bundled. @rpath is a common choice for libraries intended to be bundled within an app.
            INSTALL_NAME_DIR "@rpath" # Or specific path like "@loader_path/../lib" etc.
            MACOSX_RPATH ON # Ensures that executables linking this dylib have the correct rpath set
        )
    else() # Android, Windows, Linux
        add_library(${TARGET_NAME} SHARED ${NATIVE_SOURCES})
    endif()

    set_target_properties(${TARGET_NAME} PROPERTIES
        PUBLIC_HEADER "${NATIVE_HEADERS}" # This sets INTERFACE_INCLUDE_DIRECTORIES to CMAKE_CURRENT_SOURCE_DIR
        OUTPUT_NAME "${TARGET_NAME}" # For macOS, SHARED + OUTPUT_NAME "native_add" -> libnative_add.dylib
    )

    if(WIN32)
        # Define EXPORT macro for Windows DLLs
        target_compile_definitions(${TARGET_NAME} PRIVATE "NATIVE_ADD_EXPORT=__declspec(dllexport)")
        # Your native_add.h should use NATIVE_ADD_EXPORT for functions to be exported.
        # e.g. NATIVE_ADD_EXPORT int32_t native_add(int32_t x, int32_t y);
    endif()

    target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB) # Or whatever your FFI visibility macro is

    # --- Output Directories for Podspec Integration (when building from source) ---
    # This ensures the library is placed where the podspec's LIBRARY_SEARCH_PATHS expects it.
    # The podspec's s.prepare_command runs CMake in a 'build' subdirectory of the pod.
    # CMAKE_BINARY_DIR will be that 'build' directory.
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib/Debug)     # For .a (if any static libs were built)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib/Release)  # For .a
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib/Debug)     # For .dylib, .so
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib/Release)  # For .dylib, .so
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/bin/Debug)     # For .dll, executables
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin/Release)  # For .dll, executables
    # --- End Output Directories ---

    # POST_BUILD: Copy to prebuild location (for future use as prebuilt)
    # Determine correct suffix for POST_BUILD copy based on platform
    if(IS_MACOS)
        # MODIFIED: Suffix for .dylib
        set(BUILT_LIB_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}") # .dylib
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>") # For shared libs, this is correct
    elseif(WIN32)
        set(BUILT_LIB_SUFFIX ".dll") # Primary artifact
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>") # This usually points to the .dll
    else() # Linux, Android (shared libs)
        set(BUILT_LIB_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>")
    endif()

    # MODIFIED: Simplified destination path logic
    # For .dylib on macOS and .so on Linux/Android, the 'lib' prefix is standard.
    # For .dll on Windows, no 'lib' prefix.
    if(WIN32)
        set(DEST_PREBUILT_LIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}${BUILT_LIB_SUFFIX}")
    else() # macOS, Linux, Android
        set(DEST_PREBUILT_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${BUILT_LIB_SUFFIX}")
    endif()

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PREBUILD_ABI_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${BUILT_LIB_FILE_VAR}"
        "${DEST_PREBUILT_LIB_PATH}"
        COMMENT "Saving built library to prebuild location: ${DEST_PREBUILT_LIB_PATH}"
        VERBATIM
    )

    if(WIN32)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_LINKER_FILE:${TARGET_NAME}>" # .lib import library
            "${PREBUILD_IMPLIB_PATH}"
            COMMENT "Saving Windows import library: ${PREBUILD_IMPLIB_PATH}"
            VERBATIM
        )
    endif()
endif()

# 通用设置
if(ANDROID)
    target_link_options(${TARGET_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
endif()

if(IS_MACOS)
    # Ensure deployment target is set for macOS if building from source.
    # The podspec usually passes this via CMAKE_OSX_DEPLOYMENT_TARGET.
    # If not (e.g. direct CMake usage), set a default.
    if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS deployment target")
    endif()
    message(STATUS "macOS Deployment Target: ${CMAKE_OSX_DEPLOYMENT_TARGET}")
    # Architectures (CMAKE_OSX_ARCHITECTURES) are passed by the podspec.
endif()