cmake_minimum_required(VERSION 2.8)
project(nsswitcher)

SET (CMAKE_C_COMPILER "gcc")
SET (CMAKE_CXX_FLAGS "-Wall -Werror=return-type -g3 -O0 -fno-builtin -ffast-math")
SET (CMAKE_C_FLAGS "-Wall -Werror=return-type -g3 -O0 -fno-builtin -ffast-math")

SET (NSS
    src/nsswitcher.c
)


set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/build)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(CMAKE_EXE_LINKER_FLAGS -static)

add_executable(nsswitcher ${NSS})
