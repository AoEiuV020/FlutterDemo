cmake_minimum_required(VERSION 3.10) # 建议使用较新版本如3.18+ 以获得更好的Android支持
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

# 目标库名称
set(TARGET_NAME "native_add")

# 预编译库存放的根目录
set(PREBUILD_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/prebuild")

# 设置平台和ABI相关的库路径
if(ANDROID)
    # CMAKE_ANDROID_ARCH_ABI 由 Android NDK toolchain 文件设置, e.g., armeabi-v7a, arm64-v8a
    if(NOT CMAKE_ANDROID_ARCH_ABI)
        message(FATAL_ERROR "CMAKE_ANDROID_ARCH_ABI is not defined. Ensure you are using the Android NDK toolchain.")
    endif()
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/${CMAKE_SYSTEM_NAME}/${CMAKE_ANDROID_ARCH_ABI}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}") # e.g. /path/to/prebuild/Android/arm64-v8a/libnative_add.so
elseif(WIN32)
    # CMAKE_SYSTEM_PROCESSOR on Windows is typically AMD64, x86 etc.
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.dll")
    set(PREBUILD_IMPLIB_PATH "${PREBUILD_ABI_DIR}/${TARGET_NAME}.lib")
else() # Other platforms like Linux, macOS
    set(PREBUILD_ABI_DIR "${PREBUILD_ROOT_DIR}/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")
    set(PREBUILD_LIB_PATH "${PREBUILD_ABI_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

# 确保预编译库目标目录存在，以便后续从源码构建时可以复制过去
file(MAKE_DIRECTORY "${PREBUILD_ABI_DIR}")

message(STATUS "Targeting System: ${CMAKE_SYSTEM_NAME}")
if(ANDROID)
    message(STATUS "Targeting ABI: ${CMAKE_ANDROID_ARCH_ABI}")
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
        # 对于Android，如果直接使用 IMPORTED 库作为Gradle的构建目标，AGP可能不会打包它。
        # 一个解决方法是创建一个普通的SHARED库，然后通过自定义命令将预编译库复制到其预期的输出位置。
        # 这会“欺骗”AGP，让它认为这个库是由CMake构建的。
        # 你需要一个虚拟的源文件，或者使用更高级的CMake技巧避免它。
        # 创建一个空的 dummy.c 文件: e.g., void dummy() {}
        if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")
            file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c" "void _dummy_native_add_function_() {} // Dummy source for prebuilt library\n")
        endif()
        add_library(${TARGET_NAME} SHARED "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c")

        # 构建后命令：将预编译库复制到CMake的输出位置
        # $<TARGET_FILE:${TARGET_NAME}> 会解析为CMake构建此目标时应输出的完整路径
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${PREBUILD_LIB_PATH}"
                "$<TARGET_FILE:${TARGET_NAME}>"
                COMMENT "Copying prebuilt Android library ${PREBUILD_LIB_PATH} to $<TARGET_FILE:${TARGET_NAME}>"
                VERBATIM # 确保 $<TARGET_FILE:...> 正确展开
        )
        # 如果预编译库有特定的链接依赖（比如log库），也需要在这里声明
        # target_link_libraries(${TARGET_NAME} PUBLIC log) # 示例

    else() # Windows 和其他平台可以使用 IMPORTED GLOBAL
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
    # 公共头文件和定义仍然需要设置，以便其他目标可以正确链接
    set_target_properties(${TARGET_NAME} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}" # 假设 native_add.h 在源目录
    )
    if(NOT ANDROID) # Android 的 POST_BUILD 复制方案已经是一个 "构建" 目标了
        target_compile_definitions(${TARGET_NAME} INTERFACE DART_SHARED_LIB)
    else()
        target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB)
    endif()


else()
    message(STATUS "Prebuilt library not found or incomplete. Building from source...")

    add_library(${TARGET_NAME} SHARED "native_add.c")
    set_target_properties(${TARGET_NAME} PROPERTIES
            PUBLIC_HEADER "native_add.h" # PUBLIC_HEADER 会自动添加 INTERFACE_INCLUDE_DIRECTORIES
            OUTPUT_NAME "${TARGET_NAME}" # 通常不需要，除非你想覆盖默认名称规则
    )

    if(WIN32)
        target_compile_definitions(${TARGET_NAME} PRIVATE "EXPORT=__declspec(dllexport)")
    endif()

    target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB)

    # 构建后保存为预编译库
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${PREBUILD_ABI_DIR}"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:${TARGET_NAME}>"
            "${PREBUILD_LIB_PATH}"
            COMMENT "Saving built library to prebuild location: ${PREBUILD_LIB_PATH}"
            VERBATIM
    )

    if(WIN32)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "$<TARGET_LINKER_FILE:${TARGET_NAME}>" # $<TARGET_LINKER_FILE:...> 获取 .lib 文件
                "${PREBUILD_IMPLIB_PATH}"
                COMMENT "Saving Windows import library: ${PREBUILD_IMPLIB_PATH}"
                VERBATIM
        )
    endif()
endif()

# 通用设置，无论是否预编译
if(ANDROID)
    # Android平台特定链接选项
    # 注意：如果使用上面的Android预编译方案，此链接选项需要加给 ${TARGET_NAME}
    target_link_options(${TARGET_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
endif()

# 如果你的项目中有其他目标链接到 native_add，例如一个可执行文件或另一个库：
# add_executable(my_app main.c)
# target_link_libraries(my_app PRIVATE ${TARGET_NAME})