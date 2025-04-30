# Flutter工具要求开发者安装CMake 3.10或更高版本
# 不要提高此版本要求，否则会导致插件在某些用户环境中编译失败
# 解释：设置CMake最低版本要求，保持兼容性
cmake_minimum_required(VERSION 3.10)

# 定义项目名称、版本和使用的编程语言
# 解释：创建native_add_library项目，使用C语言
project(native_add_library VERSION 0.0.1 LANGUAGES C)

# 添加共享库
# 解释：创建名为native_add的共享库，包含native_add.c源文件
add_library(native_add SHARED
  "native_add.c"
)

# 设置目标属性
# 解释：指定公共头文件和输出名称
set_target_properties(native_add PROPERTIES
  PUBLIC_HEADER native_add.h
  OUTPUT_NAME "native_add"
)

# 添加编译定义
# 解释：为native_add目标添加DART_SHARED_LIB宏定义
target_compile_definitions(native_add PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # 支持Android 15的16k页面大小
  # 解释：为Android平台设置链接选项
  target_link_options(native_add PRIVATE "-Wl,-z,max-page-size=16384")
endif()
