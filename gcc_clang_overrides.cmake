set( TNUN_disabled_warnings "" )
list( APPEND TNUN_compiler_optimize_for_speed -funroll-loops )

# https://gcc.gnu.org/legacy-ml/gcc-help/2016-10/msg00023.html
list( APPEND TNUN_compiler_release_flags -fno-unwind-tables -fno-asynchronous-unwind-tables )

# do not throw error when using deprecated functions - treat this still as warnings
list( APPEND TNUN_disabled_warnings -Wno-error=deprecated-declarations )

if( CLANG )
    list( APPEND TNUN_disabled_warnings "-Wno-error=#warnings" -Wno-error=unknown-attributes )

    # Adding -Oz to Xcode generator makes it place to OTHER_CPLUSPLUSFLAGS property, which is always
    # appended to the clang command line *after* GCC_OPTIMIZATION_LEVEL. Since officially only Xcode 11
    # will get full support for -Oz within GCC_OPTIMIZATION_LEVEL property, we first need to wait for
    # a version of CMake that will detect -Oz flag and place it correctly into the GCC_OPTIMIZATION_LEVEL
    # property. By putting it to OTHER_CPLUSPLUSFLAGS it is not possible to override -Oz with -O3 or -Ofast
    # for certain projects, as this flag is correctly placed into GCC_OPTIMIZATION_LEVEL which Xcode puts
    # *before* OTHER_CPLUSPLUSFLAGS property during clang command line invocation.
    # This is tested with both Xcode 10.2 and Xcode 11.0 beta using CMake 3.14.5.
    #
    #                   (Nenad Miksa) (2019-07-08)
    # Additional note: also tested with CMake 3.16.3 and Xcode 11.3.1 - still the same bug appears
    #                   (Nenad Miksa) (2020-01-29)
    # Additional note: also tested with CMake 3.17.2 and Xcode 11.4.1 - still the same bug appears
    #                   (Nenad Miksa) (2020-05-21)
    # Additional note: also tested with CMake 3.19.0 and Xcode 12.2.0 - still the same bug appears
    #                   (Nenad Miksa) (2020-11-20)
    # Additional note: also tested with CMake 3.21.3 and Xcode 13.0.0 - still the same bug appears
    #                   (Nenad Miksa) (2021-09-22)

    if ( NOT CMAKE_GENERATOR STREQUAL "Xcode" )
        # https://github.com/android-ndk/ndk/issues/133#issuecomment-323468161
        # https://stackoverflow.com/a/15548189/213057
        # https://gitlab.kitware.com/cmake/cmake/-/issues/22665
        set( TNUN_compiler_optimize_for_size -Oz )
    endif()

    if ( CMAKE_GENERATOR STREQUAL "Xcode" )
        set( ARCH "[arch=x86_64]" )
        # enable SSE3 and SSE4 on Intel
        set( CMAKE_XCODE_ATTRIBUTE_OTHER_CFLAGS${ARCH}         "${CMAKE_XCODE_ATTRIBUTE_OTHER_CFLAGS${ARCH}}         $(OTHER_CFLAGS)         -msse3 -msse4" )
        set( CMAKE_XCODE_ATTRIBUTE_OTHER_CPLUSPLUSFLAGS${ARCH} "${CMAKE_XCODE_ATTRIBUTE_OTHER_CPLUSPLUSFLAGS${ARCH}} $(OTHER_CPLUSPLUSFLAGS) -msse3 -msse4" )
    else()
        if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
            # enable SSE3 and SSE4 on Intel
            add_compile_options( -msse3 -msse4 )
        endif()
    endif()

    # Note: vptr sanitizer causes linker errors in MVToolsetTest and false positives
    # in NeuralNetworkModelBuilder (reports errors within STL's iostream)
    list( APPEND TNUN_compiler_runtime_sanity_checks -fno-sanitize=vptr )

    if ( CLANG AND ( ( ANDROID AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12.0.0" ) OR ( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "13.0.0" ) ) )
        # enable LLVM Polly
        list( APPEND TNUN_compiler_optimize_for_speed -mllvm -polly )
    endif()
else()
    list( APPEND TNUN_disabled_warnings -Wno-error=cpp )
endif()
