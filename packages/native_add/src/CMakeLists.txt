cmake_minimum_required(VERSION 3.10)
project(native_add_internal VERSION 0.0.1 LANGUAGES C)

set(TARGET_LIB_NAME "native_add")
set(LIB_CACHE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib_cache/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}")
file(MAKE_DIRECTORY ${LIB_CACHE_DIR})
file(MAKE_DIRECTORY ${LIB_CACHE_DIR})
set(CACHED_LIB_PATH "${LIB_CACHE_DIR}/${TARGET_LIB_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")

# 始终定义目标（使用伪源文件）
add_library(${TARGET_LIB_NAME} SHARED
    "${CMAKE_CURRENT_SOURCE_DIR}/dummy.c"
)

if(EXISTS ${CACHED_LIB_PATH})
    message(STATUS "Using cached library: ${CACHED_LIB_PATH}")
    
    # 1. 禁用实际编译
    set_target_properties(${TARGET_LIB_NAME} PROPERTIES
        EXCLUDE_FROM_ALL TRUE
        LINKER_LANGUAGE C
    )
    
    # 2. 添加自定义命令确保文件被复制到正确位置
    add_custom_command(TARGET ${TARGET_LIB_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CACHED_LIB_PATH}
            $<TARGET_FILE_DIR:${TARGET_LIB_NAME}>/
        COMMENT "Deploying cached library to build directory"
    )
    
    # 3. 确保安装阶段能找到库文件
    install(FILES ${CACHED_LIB_PATH}
        DESTINATION "${CMAKE_INSTALL_PREFIX}"
        CONFIGURATIONS Debug Release
    )
else()
    message(STATUS "Building library from source...")
    
    # 正常编译设置
    target_sources(${TARGET_LIB_NAME} PRIVATE
        "native_add.c"
    )
    
    set_target_properties(${TARGET_LIB_NAME} PROPERTIES
        EXCLUDE_FROM_ALL FALSE
        PUBLIC_HEADER native_add.h
    )

    if(WIN32)
        target_compile_definitions(${TARGET_LIB_NAME} PRIVATE
            "EXPORT=__declspec(dllexport)"
        )
    endif()

    # 编译后缓存
    add_custom_command(TARGET ${TARGET_LIB_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:${TARGET_LIB_NAME}>
            ${CACHED_LIB_PATH}
        COMMENT "Caching library to ${CACHED_LIB_PATH}"
    )
endif()