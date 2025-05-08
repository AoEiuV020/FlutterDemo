# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "native_add")
project(${PROJECT_NAME} LANGUAGES CXX)

set(native_add_bundled_libraries
  ${CMAKE_CURRENT_SOURCE_DIR}/../prebuild/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}/${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
  PARENT_SCOPE
)
