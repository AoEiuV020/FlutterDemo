cmake_minimum_required(VERSION 3.10)
project(gtk_test LANGUAGES CXX)

# 设置可执行文件名
set(BINARY_NAME "inner")
set(WRAPPER_BINARY_NAME "wrapper")

# 设置C++标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找GTK3和X11
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(X11 REQUIRED x11)

# 添加主应用可执行文件
add_executable(${BINARY_NAME}
    main.cc
    my_application.cc
)

# 添加wrapper应用可执行文件
add_executable(${WRAPPER_BINARY_NAME}
    wrapper_main.cc
    wrapper_application.cc
)

# 包含GTK3和X11头文件目录
target_include_directories(${BINARY_NAME} PRIVATE 
    ${GTK3_INCLUDE_DIRS}
    ${X11_INCLUDE_DIRS}
)
target_include_directories(${WRAPPER_BINARY_NAME} PRIVATE 
    ${GTK3_INCLUDE_DIRS}
    ${X11_INCLUDE_DIRS}
)

# 链接GTK3和X11库
target_link_libraries(${BINARY_NAME} PRIVATE 
    ${GTK3_LIBRARIES}
    ${X11_LIBRARIES}
)
target_link_libraries(${WRAPPER_BINARY_NAME} PRIVATE 
    ${GTK3_LIBRARIES}
    ${X11_LIBRARIES}
) 