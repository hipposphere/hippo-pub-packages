cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "hotkey_api")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "hotkey_api_plugin")

list(APPEND PLUGIN_SOURCES
  "hotkey_api_plugin.cc"
)

add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
pkg_check_modules(X11 REQUIRED x11)
pkg_check_modules(XI REQUIRED xi)

target_compile_options(${PLUGIN_NAME} PRIVATE ${GTK_CFLAGS} ${X11_CFLAGS} ${XI_CFLAGS})
target_include_directories(${PLUGIN_NAME} PRIVATE ${GTK_INCLUDE_DIRS} ${X11_INCLUDE_DIRS} ${XI_INCLUDE_DIRS})
target_link_libraries(${PLUGIN_NAME} PRIVATE ${GTK_LIBRARIES} ${X11_LIBRARIES} ${XI_LIBRARIES})
