cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "desktop_autopaste")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "desktop_autopaste_plugin")

list(APPEND PLUGIN_SOURCES
  "desktop_autopaste_plugin.cc"
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
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# X11 dependencies for XTest
pkg_check_modules(X11 REQUIRED x11)
pkg_check_modules(XTEST REQUIRED xtst)

target_compile_options(${PLUGIN_NAME} PRIVATE ${X11_CFLAGS} ${XTEST_CFLAGS})
target_include_directories(${PLUGIN_NAME} PRIVATE ${X11_INCLUDE_DIRS} ${XTEST_INCLUDE_DIRS})
target_link_libraries(${PLUGIN_NAME} PRIVATE ${X11_LIBRARIES} ${XTEST_LIBRARIES})
