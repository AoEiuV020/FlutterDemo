# Flutter工具要求开发者安装包含CMake 3.14或更高版本的Visual Studio
# 不要提高此版本要求，否则会导致插件在某些用户环境中编译失败
# 解释：设置CMake最低版本要求，保持兼容性
cmake_minimum_required(VERSION 3.14)

# 项目级配置
# 解释：定义项目名称和使用的编程语言
set(PROJECT_NAME "native_add")
project(${PROJECT_NAME} LANGUAGES CXX)

# 调用与其他目标平台共享的本地代码构建
# 解释：添加子目录构建共享代码，可根据不同构建需求修改
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# 需要与插件一起打包的库的绝对路径列表
# 此列表可能包含预构建库或由此构建文件触发的外部构建创建的库
# 解释：定义要打包的库文件列表
set(native_add_bundled_libraries
  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  $<TARGET_FILE:native_add>
  PARENT_SCOPE
)
