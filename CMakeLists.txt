cmake_minimum_required(VERSION 2.8)

project(zMMIX)

find_program(CLANG "clang")
if (EXISTS ${CLANG})
    set(CMAKE_C_COMPILER "clang")
endif()

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RELEASE)
endif()

set(CMAKE_C_FLAGS_RELEASE "-std=gnu99 -Wall -Wextra -Werror")
set(CMAKE_C_FLAGS_DEBUG "-std=gnu99 -Wall -Wextra -g -DDEBUG")

add_subdirectory(src)
add_subdirectory(lib)
