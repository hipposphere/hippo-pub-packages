# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(hid_api_library VERSION 0.0.1 LANGUAGES C)

add_library(hid_api SHARED
  "hid_api.c"
)

set_target_properties(hid_api PROPERTIES
  PUBLIC_HEADER hid_api.h
  OUTPUT_NAME "hid_api"
)

target_compile_definitions(hid_api PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(hid_api PRIVATE "-Wl,-z,max-page-size=16384")
endif()
