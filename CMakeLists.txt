cmake_minimum_required(VERSION 2.8)
project(nsswitcher)

SET (CMAKE_C_COMPILER "gcc")
SET (CMAKE_CXX_FLAGS "-Wall -Werror=return-type -g3 -O0 -fno-builtin -ffast-math")
SET (CMAKE_C_FLAGS "-Wall -Werror=return-type -g3 -O0 -fno-builtin -ffast-math")
include_directories("./include")

SET (NSS
    src/nsswitcher.c
)

SET (CUTILS_SOURCES
    src/utils.c
    src/utilsMount.c
)


set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/build)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(CMAKE_EXE_LINKER_FLAGS -static)


ADD_LIBRARY(cutils STATIC ${CUTILS_SOURCES})
TARGET_LINK_LIBRARIES(cutils)

add_executable(nsswitcher ${NSS})
TARGET_LINK_LIBRARIES(nsswitcher cutils)

add_executable(linkRecursive src/linkRecursive.c)
TARGET_LINK_LIBRARIES(linkRecursive cutils)

add_executable(prepareEnvDir src/prepareEnvDir.c)
TARGET_LINK_LIBRARIES(prepareEnvDir cutils)

add_executable(mounts src/mounts.c src/utils.c)
TARGET_LINK_LIBRARIES(mounts cutils)
