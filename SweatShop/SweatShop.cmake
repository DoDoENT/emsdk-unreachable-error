include_guard()

include( ${CMAKE_CURRENT_LIST_DIR}/SweatShop.srcs.cmake )

add_library( SweatShop STATIC ${SOURCES} )

target_include_directories( SweatShop PUBLIC ${CMAKE_CURRENT_LIST_DIR}/../sweater/include ${CMAKE_CURRENT_LIST_DIR}/Include )

option( SweatShop_SWEATER_EXACT_WORKER_SELECTION "Enable support for exact worker selection" OFF )
option( SweatShop_SWEATER_SPIN_BEFORE_SUSPENSION "Spin before suspension"                    OFF )
option( SweatShop_SWEATER_USE_CALLER_THREAD      "Use caller thread for work as well"        ON  )

if ( SweatShop_SWEATER_EXACT_WORKER_SELECTION )
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_EXACT_WORKER_SELECTION=1" )
else()
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_EXACT_WORKER_SELECTION=0" )
    # when disabling worker selection, on ARM64 we also need to disable HMP
    if ( ANDROID AND ANDROID_ABI STREQUAL "arm64-v8a" )
        target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_HMP=0" )
    endif()
endif()

if ( SweatShop_SWEATER_SPIN_BEFORE_SUSPENSION )
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_SPIN_BEFORE_SUSPENSION=1" )
else()
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_SPIN_BEFORE_SUSPENSION=0" )
endif()

if ( SweatShop_SWEATER_USE_CALLER_THREAD )
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_USE_CALLER_THREAD=1" )
else()
    target_compile_definitions( SweatShop PUBLIC "BOOST_SWEATER_USE_CALLER_THREAD=0" )
endif()

