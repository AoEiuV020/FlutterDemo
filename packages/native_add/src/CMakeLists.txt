cmake_minimum_required(VERSION 3.14) # 建议：最低版本 3.14
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

# 目标库名称
set(TARGET_NAME "native_add")

# 预编译库存放的根目录
set(PREBUILD_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/prebuild")

# 根据平台设置变量
set(IS_MACOS FALSE)
if(APPLE AND CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(IS_MACOS TRUE)
    message(STATUS "配置目标：macOS")
endif()

# 设置平台和 ABI 相关的库路径
if(ANDROID)
    if(NOT CMAKE_ANDROID_ARCH_ABI)
        message(FATAL_ERROR "错误：未定义 CMAKE_ANDROID_ARCH_ABI。请确保使用 Android NDK 工具链。")
    endif()
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Android/${CMAKE_ANDROID_ARCH_ABI}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
elseif(WIN32)
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Windows/${CMAKE_SYSTEM_PROCESSOR}") # 例如：AMD64, x86
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.dll")
    set(PREBUILD_IMPLIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.lib")
elseif(IS_MACOS)
    set(PREBUILD_ABI_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../macos")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .dylib
else() # Linux 或其他
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/Linux/${CMAKE_SYSTEM_PROCESSOR}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
endif()

# 确保预编译库目标目录存在 (所有平台都需要)
file(MAKE_DIRECTORY "${PREBUILD_ABI_DIR}")

message(STATUS "目标系统：${CMAKE_SYSTEM_NAME}")
if(ANDROID)
    message(STATUS "目标 ABI：${CMAKE_ANDROID_ARCH_ABI}")
elseif(IS_MACOS)
    message(STATUS "目标 macOS 架构：${CMAKE_OSX_ARCHITECTURES} (主机：${CMAKE_HOST_SYSTEM_PROCESSOR})")
else()
    message(STATUS "目标处理器：${CMAKE_SYSTEM_PROCESSOR}")
endif()
message(STATUS "检查预编译库是否存在于：${PREBUILD_LIB_PATH}")
if(WIN32 AND EXISTS "${PREBUILD_LIB_PATH}")
    message(STATUS "检查 Windows 导入库是否存在于：${PREBUILD_IMPLIB_PATH}")
endif()

# 检查预编译库是否存在 (macOS 始终跳过)
if(EXISTS "${PREBUILD_LIB_PATH}" AND (NOT WIN32 OR EXISTS "${PREBUILD_IMPLIB_PATH}") AND NOT IS_MACOS)
    message(STATUS "使用预编译库：${PREBUILD_LIB_PATH}")

    if(ANDROID)
        # Android 预编译空库方法
        if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")
            file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c" "void _dummy_native_add_function_() {} \n")
        endif()
        add_library(${TARGET_NAME} SHARED "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${PREBUILD_LIB_PATH}"
            "$<TARGET_FILE:${TARGET_NAME}>"
            COMMENT "复制 Android 预编译库 ${PREBUILD_LIB_PATH} 到 $<TARGET_FILE:${TARGET_NAME}>"
            VERBATIM
        )
    else() # Windows 和 Linux
        add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)
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
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}" # 假设 native_add.h 在当前目录下
    )
    if(NOT ANDROID)
        target_compile_definitions(${TARGET_NAME} INTERFACE DART_SHARED_LIB) # 定义 Dart FFI 宏
    else()
        target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB)
    endif()

else()
    message(STATUS "IS_MACOS或未找到预编译库或不完整。从源代码构建...")

    # 源文件
    set(NATIVE_SOURCES "native_add.c")
    set(NATIVE_HEADERS "native_add.h")

    add_library(${TARGET_NAME} SHARED ${NATIVE_SOURCES})

    set_target_properties(${TARGET_NAME} PROPERTIES
        PUBLIC_HEADER "${NATIVE_HEADERS}"
        OUTPUT_NAME "${TARGET_NAME}"
    )

    if(IS_MACOS)
        set_target_properties(${TARGET_NAME} PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            INSTALL_NAME_DIR "@rpath"
            MACOSX_RPATH ON
        )
    endif()

    if(WIN32)
        # 为 Windows DLL 定义导出宏
        target_compile_definitions(${TARGET_NAME} PRIVATE "NATIVE_ADD_EXPORT=__declspec(dllexport)")
    endif()

    target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB) # 定义 Dart FFI 宏

    # --- 输出目录配置 ---
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib/Debug)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib/Release)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib/Debug)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib/Release)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/bin/Debug)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin/Release)
    # --- 输出目录配置结束 ---

    # POST_BUILD: 复制构建产物到预编译目录 (所有平台都会执行)
    if(IS_MACOS)
        set(BUILT_LIB_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}") # .dylib
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>")
        set(DEST_PREBUILT_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${BUILT_LIB_SUFFIX}")
    elseif(WIN32)
        set(BUILT_LIB_SUFFIX ".dll")
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>")
        set(DEST_PREBUILT_LIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}${BUILT_LIB_SUFFIX}")
    else() # Linux, Android
        set(BUILT_LIB_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}") # .so
        set(BUILT_LIB_FILE_VAR "$<TARGET_FILE:${TARGET_NAME}>")
        set(DEST_PREBUILT_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${BUILT_LIB_SUFFIX}")
    endif()

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PREBUILD_ABI_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${BUILT_LIB_FILE_VAR}"
        "${DEST_PREBUILT_LIB_PATH}"
        COMMENT "保存构建的库到预编译目录：${DEST_PREBUILT_LIB_PATH}"
        VERBATIM
    )

    if(WIN32)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_LINKER_FILE:${TARGET_NAME}>" # .lib 导入库
            "${PREBUILD_IMPLIB_PATH}"
            COMMENT "保存 Windows 导入库：${PREBUILD_IMPLIB_PATH}"
            VERBATIM
        )
    endif()
endif()

# 平台特定链接选项
if(ANDROID)
    target_link_options(${TARGET_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
endif()

if(IS_MACOS)
    # 设置 macOS 部署目标
    if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "最低 macOS 部署目标")
    endif()
    message(STATUS "macOS 部署目标：${CMAKE_OSX_DEPLOYMENT_TARGET}")
    # 架构 (CMAKE_OSX_ARCHITECTURES) 通常由 podspec 传递
endif()