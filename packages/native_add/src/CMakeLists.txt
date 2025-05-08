cmake_minimum_required(VERSION 3.10)
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

# 目标库名称
set(TARGET_NAME "native_add")

# 预编译库存放目录
set(PREBUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/prebuild/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")
file(MAKE_DIRECTORY "${PREBUILD_DIR}")

# 设置平台相关库路径
if(WIN32)
    set(PREBUILD_LIB "${PREBUILD_DIR}/${TARGET_NAME}.dll")
    set(PREBUILD_IMPLIB "${PREBUILD_DIR}/${TARGET_NAME}.lib")
else()
    set(PREBUILD_LIB "${PREBUILD_DIR}/lib${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

message(STATUS "正在检查预编译库: ${PREBUILD_LIB}")

# 如果存在预编译库则直接使用
if(EXISTS "${PREBUILD_LIB}" AND (NOT WIN32 OR EXISTS "${PREBUILD_IMPLIB}"))
    message(STATUS "使用预编译库: ${PREBUILD_LIB}")
    
    add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)
    set_target_properties(${TARGET_NAME} PROPERTIES
        IMPORTED_LOCATION "${PREBUILD_LIB}"
    )
    
    if(WIN32)
        set_target_properties(${TARGET_NAME} PROPERTIES
            IMPORTED_IMPLIB "${PREBUILD_IMPLIB}"
        )
    endif()

else()
    message(STATUS "未找到预编译库，正在从源码构建...")
    
    add_library(${TARGET_NAME} SHARED "native_add.c")
    set_target_properties(${TARGET_NAME} PROPERTIES
        PUBLIC_HEADER "native_add.h"
        OUTPUT_NAME "${TARGET_NAME}"
    )

    if(WIN32)
        target_compile_definitions(${TARGET_NAME} PRIVATE "EXPORT=__declspec(dllexport)")
    endif()
    
    target_compile_definitions(${TARGET_NAME} PUBLIC DART_SHARED_LIB)

    # 构建后保存为预编译库
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PREBUILD_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:${TARGET_NAME}>"
            "${PREBUILD_LIB}"
        COMMENT "保存构建结果为预编译库: ${PREBUILD_LIB}"
    )

    if(WIN32)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "$<TARGET_FILE_DIR:${TARGET_NAME}>/$<TARGET_FILE_BASE_NAME:${TARGET_NAME}>.lib"
                "${PREBUILD_IMPLIB}"
            COMMENT "保存Windows导入库: ${PREBUILD_IMPLIB}"
        )
    endif()
endif()

if(ANDROID)
# Android平台特殊处理
    if(ANDROID AND TARGET ${TARGET_NAME} AND NOT TARGET ${TARGET_NAME} IMPORTED)
        target_link_options(${TARGET_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
    endif()
endif()
