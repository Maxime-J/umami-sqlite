cmake_minimum_required(VERSION 3.31)
project(regexp C)

add_library(regexp MODULE src/regexp.c)

target_include_directories(regexp PRIVATE include)

set_target_properties(regexp PROPERTIES
  PREFIX ""
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}
  LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}
)
