include_guard()

include( ${CMAKE_CURRENT_LIST_DIR}/../SweatShop/SweatShop.cmake )

# Obtain all source files
set( SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/Source/SweatShopTest.cpp
)

add_executable( SweatShopTest ${SOURCES} )

target_link_libraries( SweatShopTest PRIVATE SweatShop gtest gtest_main )
