cmake_minimum_required(VERSION 2.8)

project(zMMIX)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RELEASE)
endif()

set(CMAKE_C_FLAGS_RELEASE "-Wall -Wextra -Werror")
set(CMAKE_C_FLAGS_DEBUG "-Wall -Wextra -g -DDEBUG")

add_subdirectory(src)
add_subdirectory(lib)
