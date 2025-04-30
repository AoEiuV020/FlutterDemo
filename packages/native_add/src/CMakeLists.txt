# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_add_library VERSION 0.0.1 LANGUAGES C)

add_library(native_add SHARED
  "native_add.c"
)

set_target_properties(native_add PROPERTIES
  PUBLIC_HEADER native_add.h
  OUTPUT_NAME "native_add"
)

target_compile_definitions(native_add PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(native_add PRIVATE "-Wl,-z,max-page-size=16384")
endif()
