cmake_minimum_required(VERSION 3.10)
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

set(TARGET_LIB_NAME "native_add")
set(LIB_CACHE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib_cache/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")

# 确保缓存目录存在
file(MAKE_DIRECTORY "${LIB_CACHE_DIR}")

# 设置库文件路径
if(WIN32)
    set(CACHED_LIB_PATH "${LIB_CACHE_DIR}/${TARGET_LIB_NAME}.dll")
    set(CACHED_IMPLIB_PATH "${LIB_CACHE_DIR}/${TARGET_LIB_NAME}.lib")
else()
    set(CACHED_LIB_PATH "${LIB_CACHE_DIR}/lib${TARGET_LIB_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

message(STATUS "Checking for cached library at: ${CACHED_LIB_PATH}")

# 检查预编译库是否存在
if(EXISTS "${CACHED_LIB_PATH}" AND (NOT WIN32 OR EXISTS "${CACHED_IMPLIB_PATH}"))
    message(STATUS "Using cached library: ${CACHED_LIB_PATH}")
    
    add_library(${TARGET_LIB_NAME} SHARED IMPORTED GLOBAL)
    
    set_target_properties(${TARGET_LIB_NAME} PROPERTIES
        IMPORTED_LOCATION "${CACHED_LIB_PATH}"
    )
    
    if(WIN32)
        set_target_properties(${TARGET_LIB_NAME} PROPERTIES
            IMPORTED_IMPLIB "${CACHED_IMPLIB_PATH}"
        )
    endif()
    
    set_target_properties(${TARGET_LIB_NAME} PROPERTIES
        PUBLIC_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/native_add.h"
        INTERFACE_COMPILE_DEFINITIONS "DART_SHARED_LIB"
    )
    
    # 安装预编译库
    install(FILES "${CACHED_LIB_PATH}"
        DESTINATION "${CMAKE_INSTALL_PREFIX}"
    )
    if(WIN32)
        install(FILES "${CACHED_IMPLIB_PATH}"
            DESTINATION "${CMAKE_INSTALL_PREFIX}"
        )
    endif()
else()
    message(STATUS "Building library from source...")
    
    add_library(${TARGET_LIB_NAME} SHARED
        "native_add.c"
    )
    
    set_target_properties(${TARGET_LIB_NAME} PROPERTIES
        PUBLIC_HEADER "native_add.h"
        OUTPUT_NAME "${TARGET_LIB_NAME}"
    )
    
    if(WIN32)
        target_compile_definitions(${TARGET_LIB_NAME} PRIVATE
            "EXPORT=__declspec(dllexport)"
        )
    endif()
    
    # 公共编译定义
    target_compile_definitions(${TARGET_LIB_NAME} PUBLIC DART_SHARED_LIB)
    
    # 编译后缓存库文件
    add_custom_command(TARGET ${TARGET_LIB_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${LIB_CACHE_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:${TARGET_LIB_NAME}>"
            "${CACHED_LIB_PATH}"
        COMMENT "Caching built library to ${CACHED_LIB_PATH}"
    )
    
    # Windows平台需要额外缓存.lib文件
    if(WIN32)
        add_custom_command(TARGET ${TARGET_LIB_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "$<TARGET_FILE_DIR:${TARGET_LIB_NAME}>/$<TARGET_FILE_BASE_NAME:${TARGET_LIB_NAME}>.lib"
                "${CACHED_IMPLIB_PATH}"
            COMMENT "Caching import library to ${CACHED_IMPLIB_PATH}"
        )
    endif()
endif()

if(ANDROID)
    if(TARGET ${TARGET_LIB_NAME} AND NOT TARGET ${TARGET_LIB_NAME} IMPORTED)
        target_link_options(${TARGET_LIB_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
    endif()
endif()