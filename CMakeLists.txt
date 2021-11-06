cmake_minimum_required( VERSION 3.10 )

project( EmscriptenUnreachable )

include( ${CMAKE_CURRENT_LIST_DIR}/build/build_options.cmake )
include( ${CMAKE_CURRENT_LIST_DIR}/emscripten.toolchain-override.cmake )

set( gtest_disable_pthreads      ON CACHE BOOL INTERNAL FORCE )
set( gtest_hide_internal_symbols ON CACHE BOOL INTERNAL FORCE )

add_compile_options( -Wno-unused-command-line-argument ${TNUN_compiler_LTO} )
add_link_options( ${TNUN_linker_LTO} )

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}/boost/include
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/config_ex/include
    ${CMAKE_CURRENT_LIST_DIR}/functionoid/include
    ${CMAKE_CURRENT_LIST_DIR}/sweater/include
)

add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/googletest googletest )

include( ${CMAKE_CURRENT_LIST_DIR}/SweatShopTest/SweatShopTest.cmake )
